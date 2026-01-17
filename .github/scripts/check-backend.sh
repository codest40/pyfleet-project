#!/usr/bin/env bash
# Exit 2 if backend missing, 0 if exists
# To distinguise pipeline failure from state existende

BUCKET_NAME="$1"
LOCK_TABLE="$2"
REGION="$3"

BACKEND_EXISTS=true

# Check S3 bucket
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" --region "$REGION" >/dev/null 2>&1; then
  echo "⚠️  Terraform S3 backend bucket '$BUCKET_NAME' does not exist. Skipping drift check."
  BACKEND_EXISTS=false
fi

echo "backend_exists=$BACKEND_EXISTS" >> "$GITHUB_ENV"
echo "✅ Done checking backend"
exit 0
