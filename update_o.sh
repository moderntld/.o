#!/bin/bash
#Update script for ".o" on BIND9/Ubuntu 18.04

#Variables
CHECKCONF=/usr/sbin/named-checkconf
TMP_DEST='/tmp/db.o'
WORK_DIR='/opt/tld/o/'
FILE_NAME='db.o'
OUTPUT_DIR='/etc/bind/zone/master/o/'
FILES=${WORK_DIR}zone/*

cd $WORK_DIR
git fetch origin master > /dev/null
git reset --hard origin/master > /dev/null

for f in $FILES
do
  cp $WORK_DIR$FILE_NAME $TMP_DEST
  cat $f >> $TMP_DEST

  TEST=$($CHECKCONF "$TMP_DEST")
  if [ "$TEST" ]; then
    echo "Failed to add ${f}.o to the main zone!"
  else
    echo "Processed ${f}.o Successfully"
    echo ";`git log --oneline -- $f | tail -n 1`" >> $FILE_NAME
    cat $f >> $FILE_NAME
  fi

  VERIFY=$($CHECKCONF "$WORK_DIR$FILE_NAME")
  if [ "$VERIFY" ]; then
    echo "Some unknown error occured: $WORK_DIR$FILE_NAME"
    exit 1
  fi
done

rm ${OUTPUT_DIR}db*
cp $WORK_DIR$FILE_NAME /etc/bind/zone/master/o/

systemctl reload bind9
