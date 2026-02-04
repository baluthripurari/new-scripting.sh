#!/bin/bash
# Usage:
# ./deploy.sh <micro> <release_branch> <artifact_dir> <artifact_jar>

set -e

MICRO="$1"
RELEASE="$2"
ARTIFACT_DIR="$3"
ARTIFACT_JAR="$4"

BASE="/app"
MICRO_DIR="$BASE/microservices"
CONFIG="$BASE/config/$MICRO.properties"
START_SCRIPT="$BASE/scripts/start.py"

RUNTIME_JAR="${MICRO}.jar"

URL="https://oneartifatory.company.com/articatory/b6ov_microservices/vzw/b6ov/release/${RELEASE}/${ARTIFACT_DIR}/${ARTIFACT_JAR}"

# -------- validation --------
if [[ $# -ne 4 ]]; then
  echo "Usage: ./deploy.sh <micro> <release_branch> <artifact_dir> <artifact_jar>"
  exit 1
fi

if [[ ! -f "$CONFIG" ]]; then
  echo "Config file not found: $CONFIG"
  exit 1
fi

if [[ ! -f "$MICRO_DIR/$RUNTIME_JAR" ]]; then
  echo "Existing jar not found: $MICRO_DIR/$RUNTIME_JAR"
  exit 1
fi

echo "----------------------------------"
echo "Deploying micro : $MICRO"
echo "Release branch : $RELEASE"
echo "Artifact jar   : $ARTIFACT_JAR"
echo "Runtime jar    : $RUNTIME_JAR"
echo "----------------------------------"

# -------- stop old process --------
PID=$(pgrep -f "java.*$RUNTIME_JAR" || true)
if [[ -n "$PID" ]]; then
  echo "Stopping old process PID=$PID"
  kill -9 "$PID"
  sleep 2
else
  echo "No running process found"
fi

# -------- download jar --------
echo "Downloading new jar..."
curl -f -L "$URL" -o "$MICRO_DIR/$RUNTIME_JAR"

# -------- start micro --------
echo "Starting micro..."
python3 "$START_SCRIPT" "$CONFIG"

echo "Deployment successful for $MICRO"
