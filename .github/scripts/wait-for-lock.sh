#!/usr/bin/env bash
set -e

LOCK_TABLE="${1:-pyfleet-lock-tf}"
STATE_PATH="${2:-pyfleet/terraform.tfstate}"
MAX_WAIT="${3:-300}"       # seconds
SLEEP_INTERVAL="${4:-10}"  # seconds

echo "Checking if Terraform state is locked..."

ELAPSED=0
while true; do
  LOCK=$(aws dynamodb get-item \
    --table-name "$LOCK_TABLE" \
    --key "{\"LockID\":{\"S\":\"$STATE_PATH\"}}" \
    --query "Item" \
    --output json 2>/dev/null)

  if [[ -z "$LOCK" || "$LOCK" == "null" ]]; then
    echo "✅ Terraform state is free"
    echo "state_free=true" >> $GITHUB_ENV
    break
  else
    WHO=$(echo "$LOCK" | jq -r '.Info.S // "unknown"')
    CREATED=$(echo "$LOCK" | jq -r '.Created.S // "unknown"')
    echo "⚠️ Terraform state is currently locked!"
    echo "   Locked by: $WHO"
    echo "   Created at: $CREATED"

    if (( ELAPSED >= MAX_WAIT )); then
      echo "❌ Timeout reached. Terraform state still locked. Exiting."
      echo "state_free=false" >> $GITHUB_ENV
      exit 1
    fi

    echo "Waiting $SLEEP_INTERVAL seconds before retrying..."
    sleep $SLEEP_INTERVAL
    ((ELAPSED+=SLEEP_INTERVAL))
  fi
done
