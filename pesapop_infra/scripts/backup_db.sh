#!/bin/bash
# Daily PostgreSQL backup — add to cron: 0 2 * * * /opt/pesapop/scripts/backup_db.sh
set -euo pipefail

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=/opt/pesapop/backups
BACKUP_FILE="$BACKUP_DIR/pesapop_$TIMESTAMP.sql.gz"
RETENTION_DAYS=30

mkdir -p "$BACKUP_DIR"

echo "[$TIMESTAMP] Starting backup..."
docker exec pesapop_postgres pg_dump -U pesapop pesapop_db | gzip > "$BACKUP_FILE"
echo "[$TIMESTAMP] Backup saved: $BACKUP_FILE ($(du -sh $BACKUP_FILE | cut -f1))"

# Remove old backups
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
echo "[$TIMESTAMP] Cleaned backups older than $RETENTION_DAYS days."

# Optional: upload to S3
# aws s3 cp "$BACKUP_FILE" "s3://pesapop-backups/db/$TIMESTAMP.sql.gz"
