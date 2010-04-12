#!/bin/bash

# CONFIGURATION

# the directories you'd like to backup daylie
DAYLY_ROTATING=""
# the directories you'd like to backup weekly
WEEKLY=""
#how many rotating backups? (eg. after how many iterations should we replace the oldest one?)
ROTATE_COUNT="7"
# where to backup
BACKUPDIR=""
# what day of the week should the weekly update be done?
BACKUPDAY="1"


#-----------------------------------


DAYOFFWEEK=`date +%u`

if [ "$1" == "--full-backup" ]
then
 	BACKUPDAY=$DAYOFFWEEK	
fi

TODAY=`date +%d%m%Y`
echo $TODAY

#DAYLY ROTATING

for FILE in $DAYLY_ROTATING
do

	echo "processing $FILE"
	#create the backupdirectorys if they dont exist
	if [ -e "$BACKUPDIR$FILE" ]
	then
		echo "yes"
	else
		mkdir -p "$BACKUPDIR$FILE"
		echo "created"
	fi

	backup_rotating

done
	

#WEEKLY BACKUP
if [ "$DAYOFFWEEK" == "$BACKUPDAY" ]
then
	for FILE in $WEEKLY
	do
		
		#tar it
		TARNAME="/backup/tmp/backup_$TODAY.tgz"
		tar -czf $TARNAME $FILE
		# encrypt it
		gpg --batch --yes -r 0x089082BF  --encrypt $TARNAME
		GPGNAME="$TARNAME.gpg"

		#simply shove it there	
		mv $GPGNAME "$BACKUPDIR$FILE"	

	done
fi


function backup_rotating
{

	#tar it
	TARNAME="/backup/tmp/backup_$TODAY.tgz"
	tar -czf $TARNAME $FILE
	# encrypt it
	gpg --batch --yes -r 0x089082BF  --encrypt $TARNAME
	GPGNAME="$TARNAME.gpg"

	#replace the oldest one if tehre are more then ROTATE_COUNT

	DIRCOUNT=`ls $BACKUPDIR$FILE | wc -l`
	if [ $DIRCOUNT -gt $ROTATE_COUNT ]
	then
		#find the oldest file
		OLDFILE=`ls -tr $BACKUPDIR$FILE | head -n 1`
	        rm "$BACKUPDIR$FILE$OLDFILE"
			
	fi
	#simply shove it there	
	mv $GPGNAME "$BACKUPDIR$FILE"	

}

function backup_weekly
{

}
