DATE=$(date +"%Y-%m-%d");
# Files to compress
FILES="/path/to/files/"
# Backup file 
BACKUPFILE="/tmp/backup-$DATE.tar.gz"
# S3 Bucket Name
BUCKET=bucketname

tar czf $BACKUPFILE $FILES

#s3 start
DESTINATION=`date +%F`
MAXDAYS=30
/usr/bin/s3cmd -r put "/tmp/nagios-$DATE.tar.gz" s3://${BUCKET}/${DESTINATION}/
DELETENAME=$(date --date="${MAXDAYS} days ago" +%F)
/usr/bin/s3cmd -r --force del s3://${BUCKET}/${DELETENAME}

rm -rf $BACKUPFILE
