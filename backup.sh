#!/bin/bash

BACKUP_PASSWORD=$(grep "^BACKUP_PASSWORD" .env | cut -d "=" -f 2-)
BACKUP_DIR="backup/vw-data"
BACKUP_FILE_NAME="vw-data-$(date "+%d-%m-%Y")"

if [ ! -d "backup" ]; then
    mkdir backup
fi

find ./backup -type f -mtime +30 -name "*.tar.gz" -delete

if [ -d "$BACKUP_DIR" ]; then
    rm -rf $BACKUP_DIR
fi

mkdir $BACKUP_DIR

sqlite3 ./vw-data/db.sqlite3 ".backup './$BACKUP_DIR/db.sqlite3'"

find ./vw-data -name rsa_key* -exec cp {} ./$BACKUP_DIR \;

if [ -f "./vw-data/config.json" ]; then
    cp ./vw-data/config.json ./$BACKUP_DIR
fi

for dir in "./vw-data/attachments" "./vw-data/sends"
do
    if [ -d "$dir" ]; then
        cp -r $dir ./$BACKUP_DIR
    fi
done

cd backup
7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on -mhe=on -p$BACKUP_PASSWORD $BACKUP_FILE_NAME vw-data > /dev/null

if [ ! -f "$BACKUP_FILE_NAME.7z" ]; then
    echo "File $BACKUP_FILE_NAME.7z not found!"
    exit 1
fi

rclone copy $BACKUP_FILE_NAME.7z yadisk:/Backup
