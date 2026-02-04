#!/bin/bash
# Usage:
# ./deploy.sh <micro> <release_branch> <artifact_dir> <artifact_jar>

MICRO=$1
RELEASE=$2
ARTIFACT_DIR=$3
ARTIFACT_JAR=$4

BASE="/app"
MICRO_DIR="$BASE/microservices/$MICRO"
CONFIG="$BASE/config/$MICRO.properties"
START_SCRIPT="$BASE/scripts/start.py"

RUNTIME_JAR="$MICRO.jar"

URL="https://oneartifatory.company.com/articatory/b6ov_microservices/vzw/b6ov/release/${RELEASE}/${ARTIFACT_DIR}/${ARTIFACT_JAR}"

# -------- validation --------
if [[ $# -ne 4 ]]; then
  echo "Usage: ./deploy.sh <micro> <release_branch> <artifact_dir> <artifact_jar>"
  exit 1
fi

if [[ ! -d "$MICRO_DIR" ]]; then
  echo "Micro directory not found: $MICRO_DIR"
  exit 1
fi

if [[ ! -f "$CONFIG" ]]; then
  echo "Config file not found: $CONFIG"
  exit 1
fi

echo "----------------------------------"
echo "Deploying micro : $MICRO"
echo "Release branch : $RELEASE"
echo "Jar file       : $ARTIFACT_JAR"
echo "----------------------------------"

# -------- stop old process --------
PID=$(ps -ef | grep java | grep "$RUNTIME_JAR" | grep -v grep | awk '{print $2}')
if [[ -n "$PID" ]]; then
  echo "Stopping old process PID=$PID"
  kill -9 "$PID"
  sleep 2
fi

# -------- download jar (AUTH via .netrc) --------
echo "Downloading jar..."
curl -f -L "$URL" -o "$MICRO_DIR/$RUNTIME_JAR" || {
  echo "Jar download failed"
  exit 1
}

# -------- start micro --------
echo "Starting micro..."
python3 "$START_SCRIPT" "$CONFIG"

echo "Deployment successful for $MICRO"
