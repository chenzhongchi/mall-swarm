#!/usr/bin/env bash
LIST=""
TXT=/root/tmp.txt
BAKDIR=/usr/local/bak
LOGDIR=/usr/local/bak/log
LOGFILE=$LOGDIR/bak.`date +%Y%m%d`.log

[ ! -d $BAKDIR ] && mkdir -p $BAKDIR
[ ! -d $LOGDIR ] && mkdir -p $LOGDIR

if [ -n "$LIST" ]
then
        for list in $LIST
        do
                RESLIST=`docker images |grep $list | awk '{print $1}'`
                for reslist in $RESLIST
                do
                RESTAG=`docker images |grep "$reslist" |awk '{a=$1":"$2;print a }'`
                BAKNAME=`docker images |grep "$reslist" |awk '{a=$1":"$2;print a }'|sed 's/\//_/g'`
                /usr/bin/docker save $RESTAG -o $BAKDIR/$BAKNAME.tar  >> $LOGFILE 2>&1
                done
        done
else
        REC=`docker images |awk '{print $1,$2,$3}'|sed 1d >> $TXT`
        RESLIST=`cat $TXT|awk '{print $1}'`
        for reslist in $RESLIST
        do
                RESTAG=`docker images |grep "$reslist" |awk '{a=$1":"$2;print a }'`
                BAKNAME=`docker images |grep "$reslist" |awk '{a=$1":"$2;print a }'|sed 's/\//_/g'`
                /usr/bin/docker save $RESTAG -o $BAKDIR/$BAKNAME.tar  >> $LOGFILE 2>&1
        done
        /usr/bin/rm -f $TXT
fi

if [ -s $LOGFILE ]
then
        echo -e "\033[31mERROR:Images Backup Failed!\033[0m"
        echo -e "\033[31mPlease View The Log Lile : $LOGFILE\033[0m"
else
        /usr/bin/rm -f $LOGFILE
fi