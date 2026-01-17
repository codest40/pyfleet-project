#!/usr/bin/env bash
# scripts/check-backend.sh
# Exit 0 if backend does not exist, otherwise continue

set -e

BUCKET_NAME="$1"
LOCK_TABLE="$2"
REGION="$3"

# Check S3 bucket
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" --region "$REGION" >/dev/null 2>&1; then
  echo "⚠️  Terraform S3 backend bucket '$BUCKET_NAME' does not exist. Skipping drift check."
  exit 0
fi

# Check DynamoDB table
if ! aws dynamodb describe-table --table-name "$LOCK_TABLE" --region "$REGION" >/dev/null 2>&1; then
  echo "⚠️  Terraform DynamoDB lock table '$LOCK_TABLE' does not exist. Skipping drift check."
  exit 0
fi

echo "✅ Terraform backend exists, proceeding with drift detection."
exit 1  # special exit to indicate backend exists and workflow should continue
