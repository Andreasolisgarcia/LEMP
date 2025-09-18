#!/bin/bash
# Runs At 03:00 each Monday
# Backup from the WP directory (/var/www/html/wordpress/)

BACKUP_DIR="/home/ubuntu/backup/wordpress"
SOURCE_DIR="/var/www/html/wordpress/"
LOG_FILE="/var/log/backup.log"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR/wordpress

# Starting log
echo "$(date): Starting WordPress backup from $SOURCE_DIR" >> $LOG_FILE

# Sync WordPress files with rsync
if rsync -av --delete $SOURCE_DIR $BACKUP_DIR/wordpress/ 2>>$LOG_FILE; then
    echo "$(date): SUCCESS - WordPress backup completed" >> $LOG_FILE
else
    echo "$(date): ERROR - WordPress backup failed" >> $LOG_FILE
    exit 1
fi
