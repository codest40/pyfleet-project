#!/usr/bin/env bash
# To Ensure lock is free before apply, destroy else things may hang forever

set -e

LOCK_TABLE="${1:-pyfleet-lock-tf}"
STATE_PATH="${2:-pyfleet/terraform.tfstate}"
AWS_REGION="${3:-us-east-1}"
MAX_WAIT="${4:-300}"       # seconds
SLEEP_INTERVAL="${5:-10}"  # seconds

echo "Checking if Terraform state is locked..."

ELAPSED=0
while true; do
  LOCK=$(aws dynamodb get-item \
    --region "$AWS_REGION" \
    --table-name "$LOCK_TABLE" \
    --key "{\"LockID\":{\"S\":\"$STATE_PATH\"}}" \
    --query "Item" \
    --output json 2>/dev/null)

  if [[ -z "$LOCK" || "$LOCK" == "null" ]]; then
    echo "✅ Terraform state is free"
    export state_free="true"
    return 0
  else
    WHO=$(echo "$LOCK" | jq -r '.Info.S // "unknown"')
    CREATED=$(echo "$LOCK" | jq -r '.Created.S // "unknown"')
    echo "⚠️ Terraform state is currently locked!"
    echo "   Locked by: $WHO"
    echo "   Created at: $CREATED"

    if (( ELAPSED >= MAX_WAIT )); then
      echo "❌ Timeout reached. Terraform state still locked. Exiting."
      export state_free="false"
      return 1
    fi

    echo "Waiting $SLEEP_INTERVAL seconds before retrying..."
    sleep $SLEEP_INTERVAL
    ((ELAPSED+=SLEEP_INTERVAL))
  fi
done
