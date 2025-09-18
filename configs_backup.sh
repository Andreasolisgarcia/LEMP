#!/bin/bash
# Runs at 04:00 the 1st of every month
# Contains configs from Nginx, PHP and SSL certificates

DATE=$(date +%Y%m%d_%H%M)
BACKUP_DIR="/home/ubuntu/backup/configs"
LOG_FILE="/var/log/backup.log"

# Create backup directory
mkdir -p $BACKUP_DIR

# Starting log
echo "$(date): Starting configuration backup" >> $LOG_FILE

# Create tar archive with configurations
if sudo tar -czf $BACKUP_DIR/backup_configs_$DATE.tar.gz \
  /etc/nginx/conf.d/wordpress.conf \
  /etc/nginx/nginx.conf \
  /etc/php/8.3/fpm/php.ini \
  /etc/letsencrypt/ 2>>$LOG_FILE; then
    echo "$(date): SUCCESS - Configuration backup completed: backup_configs_$DATE.tar.gz" >> $LOG_FILE
else
    echo "$(date): ERROR - Configuration backup failed" >> $LOG_FILE
    exit 1
fi

# Clean old config backups (keep last 6 months)
find $BACKUP_DIR -name "backup_configs_*.tar.gz" -mtime +180 -delete 2>/dev/null
echo "$(date): Old configuration backups cleaned up" >> $LOG_FILE
