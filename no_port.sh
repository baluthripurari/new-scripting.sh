#!/bin/bash

############################
# Configuration
############################

MICRO_NAME="mybiztools"
JAR_NAME="mybiztools.jar"
CONFIG="/app/config/mybiztools.properties"
START_SCRIPT="/app/scripts/start.py"
LOG_FILE="/app/logs/monitor.log"
EMAIL="yourmail@company.com"
LOCK_FILE="/tmp/${MICRO_NAME}_alert.lock"

############################
# Ensure log directory exists
############################

mkdir -p /app/logs

############################
# Function: Send Email
############################

send_mail() {
    SUBJECT="$1"
    MESSAGE="$2"
    echo "$MESSAGE" | mail -s "$SUBJECT" $EMAIL
}

############################
# Check if Process Running
############################

PROCESS_COUNT=$(ps -ef | grep ${JAR_NAME} | grep -v grep | wc -l)

############################
# If Service is DOWN
############################

if [ "$PROCESS_COUNT" -eq 0 ]; then

    echo "$(date) - $MICRO_NAME is DOWN." >> $LOG_FILE

    # Prevent email spam
    if [ ! -f $LOCK_FILE ]; then
        touch $LOCK_FILE

        echo "$(date) - Restarting $MICRO_NAME..." >> $LOG_FILE
        $START_SCRIPT $CONFIG

        sleep 15

        # Recheck after restart
        PROCESS_AFTER=$(ps -ef | grep ${JAR_NAME} | grep -v grep | wc -l)

        if [ "$PROCESS_AFTER" -gt 0 ]; then
            SUBJECT="SUCCESS: $MICRO_NAME Restarted on $(hostname)"
            MESSAGE="$MICRO_NAME was DOWN and restarted successfully at $(date)"
            echo "$(date) - Restart successful." >> $LOG_FILE
        else
            SUBJECT="CRITICAL: $MICRO_NAME Restart FAILED on $(hostname)"
            MESSAGE="$MICRO_NAME restart FAILED at $(date). Immediate action required."
            echo "$(date) - Restart FAILED." >> $LOG_FILE
        fi

        send_mail "$SUBJECT" "$MESSAGE"
    fi

############################
# If Service is RUNNING
############################

else
    echo "$(date) - $MICRO_NAME running healthy." >> $LOG_FILE
    rm -f $LOCK_FILE
fi
