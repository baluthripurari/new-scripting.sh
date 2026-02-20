#!/bin/bash

############################
# Configuration Section
############################

MICRO_NAME="mybiztools"
CONFIG="/app/config/mybiztools.properties"
START_SCRIPT="/app/scripts/start.py"
LOG_FILE="/app/logs/monitor.log"
EMAIL="yourmail@company.com"
PORT=8085
LOCK_FILE="/tmp/${MICRO_NAME}_alert.lock"

############################
# Create log directory if not exists
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
# Function: Restart Service
############################

restart_service() {
    echo "$(date) - Restarting $MICRO_NAME..." >> $LOG_FILE
    $START_SCRIPT $CONFIG
    sleep 15
}

############################
# Check 1: Process Running?
############################

PROCESS_COUNT=$(ps -ef | grep ${MICRO_NAME}.jar | grep -v grep | wc -l)

############################
# Check 2: Health Endpoint
############################

curl -s --max-time 5 http://localhost:${PORT}/actuator/health | grep "UP" > /dev/null
HEALTH_STATUS=$?

############################
# Decision Logic
############################

if [ "$PROCESS_COUNT" -eq 0 ] || [ "$HEALTH_STATUS" -ne 0 ]; then

    echo "$(date) - $MICRO_NAME is DOWN." >> $LOG_FILE

    if [ ! -f $LOCK_FILE ]; then
        touch $LOCK_FILE

        restart_service

        # Recheck after restart
        sleep 10
        PROCESS_AFTER=$(ps -ef | grep ${MICRO_NAME}.jar | grep -v grep | wc -l)
        curl -s --max-time 5 http://localhost:${PORT}/actuator/health | grep "UP" > /dev/null
        HEALTH_AFTER=$?

        if [ "$PROCESS_AFTER" -gt 0 ] && [ "$HEALTH_AFTER" -eq 0 ]; then
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

else
    echo "$(date) - $MICRO_NAME running healthy." >> $LOG_FILE
    rm -f $LOCK_FILE
fi
