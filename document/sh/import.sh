#!/usr/bin/env bash
STATE=""
RECEIVE=$1
TARDIR="/mydata/docker"
SUFFIX="*.tar"
LIST=`ls $TARDIR/$SUFFIX`
LOGFILE=$TARDIR/import.error.`date +%Y%m%d`.log
BAKLOGFILE=$TARDIR/bak.`date +%Y%m%d`.log

STATEIMPORT() {
for i in $STATE
do
/usr/bin/docker load -i $i >/dev/null 2>>$LOGFILE
done
}

RECEIVEIMPORT() {
for i in $RECEIVE
do
/usr/bin/docker load -i $i >/dev/null 2>>$LOGFILE
done
}

LISTIMPORT() {
for i in $LIST
do
/usr/bin/docker load -i $i >/dev/null 2>>$LOGFILE
done
}

IMAGESBAK(){
IMGINFO=`docker images |awk '{print $1,$2,$3}'|sed 1d >> $TARDIR/tmp.txt`
RESLIST=`/usr/bin/cat $TARDIR/tmp.txt |awk '{print $1}' `
for i in $RESLIST
do
    RESTAG=`docker images |grep "$i" |awk '{a=$1":"$2;print a }'`
    BAKNAME=`docker images |grep "$i" |awk '{a=$1":"$2;print a }'|sed 's/\//_/g'`
    /usr/bin/docker save $RESTAG -o $TARDIR/$BAKNAME_`date +%Y%m%d`.tar >/dev/null 2>>$BAKLOGFILE
done
if [ -s $BAKLOGFILE ]
then
    echo -e "\033[31mERROR:Images Backup Failed!\033[0m"
    echo -e "\033[31mPlease View The Log Lile : $BAKLOGFILE\033[0m"
else
    /usr/bin/rm -f $BAKLOGFILE
fi
/usr/bin/rm -f $TARDIR/tmp.txt
}

/usr/bin/rm -f $TARDIR/*.log
read -p "Whether to backup the current images[y/n]:" INPUT
if [[ $INPUT = "y" ]] || [[ $INPUT = "Y" ]]
then
    IMAGESBAK
else
    if [[ -n "$RECEIVE" ]] || [[ -n "$STATE" ]]
    then
        if [ -n "$RECEIVE" ]
        then
                RECEIVEIMPORT
        else
                STATEIMPORT
        fi
    else
        LISTIMPORT
    fi
fi

##ERROR Output
if [ -s $LOGFILE ]
then
    echo -e "\033[31mERROR:Images Import Failed!\033[0m"
    echo -e "\033[31mPlease View The Log Lile : $LOGFILE\033[0m"
else
    /usr/bin/rm -f $LOGFILE
fi