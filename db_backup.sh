#!/bin/bash
# Runs every day at 02:00
# This script makes a backup from the wordpress_db

DATE=$(date +%Y%m%d_%H%M)
BACKUP_DIR="/home/ubuntu/backup/database"
MYSQL_USER="  "
MYSQL_PASS=" "
MYSQL_DB=" "
LOG_FILE="/var/log/backup.log"

# Create dir if doesnt exists
mkdir -p $BACKUP_DIR

# Starting Log 
echo "$(date): Starting database backup for $MYSQL_DB" >> $LOG_FILE

# dump with standard erreur
if mysqldump -u $MYSQL_USER -p$MYSQL_PASS $MYSQL_DB 2>>$LOG_FILE | gzip > $BACKUP_DIR/backup_db_$DATE.sql.gz; then
    echo "$(date): SUCCESS - Database backup completed: backup_db_$DATE.sql" >> $LOG_FILE
else
    echo "$(date): ERROR - Database backup failed for $MYSQL_DB" >> $LOG_FILE
    exit 1
fi

# Delete some backups (keep last 30 days)
    find $BACKUP_DIR -name "backup_db_*.sql.gz" -mtime +30 -delete 2>/dev/null

    echo "$(date): Old database backups cleaned up" >> $LOG_FILE
