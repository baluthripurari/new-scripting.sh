#!/bin/bash
# Usage:
# ./deploy-multiple.sh deploy-list.txt

LIST_FILE=$1
DEPLOY_SCRIPT="/app/scripts/deploy.sh"

if [[ -z "$LIST_FILE" || ! -f "$LIST_FILE" ]]; then
  echo "Usage: ./deploy-multiple.sh deploy-list.txt"
  exit 1
fi

while read -r MICRO RELEASE DIR JAR; do
  [[ "$MICRO" =~ ^#|^$ ]] && continue

  echo
  echo "=================================="
  echo "Deploying $MICRO"
  echo "=================================="

  $DEPLOY_SCRIPT "$MICRO" "$RELEASE" "$DIR" "$JAR"

done < "$LIST_FILE"
