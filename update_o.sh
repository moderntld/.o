#!/bin/bash
#Update script for ".o" on BIND9/Ubuntu 18.04

#Variables
TLD='o'
NS='ns11.opennic.glue.'
EMAIL='jonah.opennic.org.'
CHECKZONE=/usr/sbin/named-checkzone
TMP_DEST='/tmp/db.o'
WORK_DIR='/opt/tld/o/'
FILE_NAME='db.o'
OUTPUT_DIR='/etc/bind/zone/master/o/'
FILES=${WORK_DIR}zone/*

cd $WORK_DIR
git fetch origin master > /dev/null
git reset --hard origin/master > /dev/null

# ADD NEW SOA!
{ echo "@		IN	SOA	$NS $EMAIL ("
  echo "        `date +%s`  ; serial"
  echo "        4H    ; refresh (4 hours)"
  echo "        1H    ; retry (1 hour)"
  echo "        1W    ; expire (1 week)"
  echo "        1H    ; minimum (1 hour)"
  echo "        )"
} >> $WORK_DIR$FILE_NAME

# ADD NAMESERVERS!
{ echo "; TLD information"
  echo "		IN	NS	ns11.opennic.glue."
  echo "		IN	NS	ns2.opennic.glue."
  echo "		IN	NS	ns5.opennic.glue."
  echo "		IN	NS	ns6.opennic.glue."
  echo "		IN	NS	ns8.opennic.glue."
  echo ";"
  echo "; Additional zones"
  echo ";"
} >> $WORK_DIR$FILE_NAME


for f in $FILES
do
  cp $WORK_DIR$FILE_NAME $TMP_DEST
  cat $f >> $TMP_DEST

  TEST=$($CHECKZONE $TLD "$TMP_DEST" | tail -n 1)
  if [ "$TEST" != "OK" ]; then
    echo "Failed to add ${f}.o to the main zone!"
  else
    echo "Processed ${f}.o Successfully"
    echo "; `git log --oneline -- $f | tail -n 1`" >> $FILE_NAME
    cat $f >> $FILE_NAME
  fi

  VERIFY=$($CHECKZONE $TLD "$WORK_DIR$FILE_NAME" | tail -n 1)
  if [ "$VERIFY" != "OK" ]; then
    echo "Some unknown error occured: $WORK_DIR$FILE_NAME"
    exit 1
  fi
done

rm ${OUTPUT_DIR}db*
cp $WORK_DIR$FILE_NAME $OUTPUT_DIR

systemctl reload bind9
