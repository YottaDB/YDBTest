#! /usr/local/bin/tcsh -f
# $1 is destinition
# $2 is output file for this script
setenv bkdir $1
setenv logfile $2

pwd >>&! $logfile
# We used to see BACKUP2MANYKILL errors from MUPIP BACKUP occasionally in this test and had instituted a scheme
# to work around this by repeating the backup. As part of the changes to C9G04-002783, mupip backup no longer
# issues the BACKUP2MANYKILL error but instead issues a BACKUPKILLIP warning and proceeds. In addition it inhibits
# future kills during the time it waits for kill-in-progress to become 0. Therefore we dont expect BACKUPKILLIP messages
# in this test. If ever we see it in future testing, we need to use a scheme (similar to the previously handled
# BACKUP2MANYKILL errors) to handle it.
echo "Starting online backup at `date`..." >>&! $logfile
echo "$MUPIP backup -i -o -t=1 *  $bkdir"  >>&! $logfile
$MUPIP backup -i -o -t=1 "*"  $bkdir >>&! online_back_out.out
set stat = $status
if ($stat == 0) then
	cat online_back_out.out >>&! $logfile
	echo "Backup successful" >>&! $logfile
else
	cat online_back_out.out >>&! $logfile
	echo "ONLINEBAK-E-BACKUPFAIL : The return status is: $ret" >>&! $logfile
endif
echo "Mupip backup ends at `date`" >>&! $logfile
