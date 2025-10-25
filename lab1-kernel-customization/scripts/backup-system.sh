#!/bin/bash
# Automated Backup System
# Performs incremental backups with rotation

set -euo pipefail

# Configuration
BACKUP_ROOT="/opt/backups"
BACKUP_SOURCES=(
    "/etc"
    "/home"
    "/var/www"
    "/opt/data"
)
RETENTION_DAYS=30
BACKUP_SERVER="backup.example.com"
BACKUP_USER="backup"

# Create backup directory structure
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/$BACKUP_DATE"
LOG_FILE="/var/log/custom/backup-$(date +%Y%m%d).log"

mkdir -p "$BACKUP_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting backup process..."

# Function to perform backup
perform_backup() {
    local source=$1
    local dest=$2
    local name=$(basename $source)
    
    log "Backing up $source..."
    
    if [ -d "$source" ]; then
        tar -czf "$dest/${name}.tar.gz" \
            --exclude='*.tmp' \
            --exclude='*.cache' \
            --exclude='lost+found' \
            "$source" 2>> "$LOG_FILE"
        
        if [ $? -eq 0 ]; then
            log "✓ Successfully backed up $source"
            
            # Calculate checksum
            sha256sum "$dest/${name}.tar.gz" > "$dest/${name}.tar.gz.sha256"
        else
            log "✗ Failed to backup $source"
            return 1
        fi
    else
        log "⚠ Source $source does not exist, skipping..."
    fi
}

# Perform backups
for source in "${BACKUP_SOURCES[@]}"; do
    perform_backup "$source" "$BACKUP_DIR"
done

# Database backup (if MySQL/PostgreSQL is installed)
if command -v mysqldump &> /dev/null; then
    log "Backing up MySQL databases..."
    DATABASES=$(mysql -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys)")
    
    for db in $DATABASES; do
        mysqldump --single-transaction --routines --triggers "$db" | \
            gzip > "$BACKUP_DIR/mysql_${db}.sql.gz"
        log "✓ Backed up database: $db"
    done
fi

if command -v pg_dumpall &> /dev/null; then
    log "Backing up PostgreSQL databases..."
    sudo -u postgres pg_dumpall | gzip > "$BACKUP_DIR/postgresql_all.sql.gz"
    log "✓ Backed up PostgreSQL databases"
fi

# Create backup manifest
log "Creating backup manifest..."
cat > "$BACKUP_DIR/manifest.txt" << MANIFEST_EOF
Backup Date: $(date)
Hostname: $(hostname)
Kernel: $(uname -r)
Files Backed Up:
MANIFEST_EOF

find "$BACKUP_DIR" -type f -exec ls -lh {} \; >> "$BACKUP_DIR/manifest.txt"

# Calculate total size
TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
log "Total backup size: $TOTAL_SIZE"

# Sync to remote backup server (optional)
if [ -n "${BACKUP_SERVER:-}" ]; then
    log "Syncing backup to remote server..."
    rsync -avz --progress "$BACKUP_DIR" \
        "${BACKUP_USER}@${BACKUP_SERVER}:/backups/" 2>> "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        log "✓ Successfully synced to remote server"
    else
        log "✗ Failed to sync to remote server"
    fi
fi

# Cleanup old backups
log "Cleaning up old backups (older than $RETENTION_DAYS days)..."
find "$BACKUP_ROOT" -maxdepth 1 -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \;

log "Backup process completed successfully!"

# Send notification (optional)
if command -v mail &> /dev/null; then
    echo "Backup completed successfully on $(hostname)" | \
        mail -s "Backup Report - $(date +%Y-%m-%d)" admin@example.com
fi
