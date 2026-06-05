#!/bin/bash

# T430 Homelab to AWS S3 Backup Script
# Aligned with B.S. Cloud & Network Engineering studies

# shellcheck disable=SC2034  # used in the sync command below once IAM is bound
BACKUP_DIR="/home/imadear/t430-homelab/configs"
S3_BUCKET="s3://your-wgu-homelab-bucket-name"
DATE=$(date +%Y-%m-%d)

echo "Starting automated homelab backup on $DATE..."

# Ensure AWS CLI is configured before running
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed. Script aborted."
    exit 1
fi

# Example sync command (commented out until AWS IAM is bound)
# aws s3 sync $BACKUP_DIR $S3_BUCKET/configs-$DATE/ --delete

echo "Backup workflow initialized successfully."
