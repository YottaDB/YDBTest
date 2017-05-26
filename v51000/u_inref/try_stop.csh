#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2009, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# have multibyte character directory created. Base this decision on gtm_chset value
set dir="baktmp"
if ($?gtm_chset) then
        if ("UTF-8" == $gtm_chset) set dir="b~A~K~T~M~P~D" # overwrite with multibytes if UTF-8 is enabled
endif
mkdir $dir
setenv GTM_BAKTMPDIR `pwd`/$dir
setenv skip_permission_check 1
$gtm_tst/$tst/u_inref/createdb_start_updates.csh 10
@ timer = `date +%s`
@ maxtime = $timer + 300
set exit_status = 0
# source a small script for online backup which will help in PID identification for MUPIP stop
unset bkgrnd_bkup_ts	# Timestamp backup output, set/unset to enable/disable
source $gtm_tst/com/bkgrnd_bkup.csh -dbg >&! mu_back_bg.log
while ($maxtime > $timer)
	set dse_bkup=`$DSE dump -fileheader -backup|& $tst_awk '/Backup Process ID/ {print $1" "$2" "$3" "$4}'`
	if ("" != "$dse_bkup") then
		if (4 <= $#dse_bkup) then
			set dse_bkup_pid=$dse_bkup[4]
			if ( ("" != "$dse_bkup_pid") && (0 != "$dse_bkup_pid")) then
				set backup_started = $dse_bkup_pid
				echo "check for temp files created by MUPIP and written to by GT.M processes."
				ls ./$dir >& prevtempfiles.logx
				break
			endif
		endif
	endif
	echo "$dse_bkup" > dse_bkup.out
	$grep -q "BACKUP COMPLETED" online1.out
	if (! $status) then
		echo "TEST-E-ERROR backup completed before stop could be attempted."
		exit 1
	endif
	# No sleep in the loop to keep from missing quick backups
	#sleep 1
	@ timer = `date +%s`
end
if ($maxtime == $timer) then
	echo "TEST-E-ERROR backup not seemed to have been trigerred(from dse dump) even after $maxtime seconds."
	echo "No temp files will be seen"
	exit 1
endif
$MUPIP stop $backup_started
if ($status) set exit_status = 1
echo "$dse_bkup" > dse_bkup.out
$gtm_tst/com/wait_for_proc_to_die.csh $backup_started
$grep -q "BACKUP COMPLETED" online1.out
if (! $status) then
	echo "TEST-E-ERROR backup completed before stop could be attempted."
	exit 1
endif
$gtm_tst/com/check_error_exist.csh online1.out FORCEDHALT >&! forcedhalt_online1.outx
if ($?bkgrnd_bkup_ts) then
	$gtm_tst/com/check_error_exist.csh online1_ts.out FORCEDHALT >&! forcedhalt_online1_ts.outx
endif
if ($status) set exit_status = 2
set filecnt=`ls ./$dir/|wc -l`
if ( $filecnt ) then
	echo "TEST-E-ERROR. temporary files still exist inspite of MUPIP STOP of backup process. Deleting the files."
	# This step is actually for old software cases where the temp files will not be removed and the user
        # will advertenetly or inadvertently remove them causing the backup error bits to be set
        rm -f ./$dir/*
	set exit_status = 3
else
	echo "PASS! Temporary files are cleaned up after MUPIP STOP"
endif
echo "exit status: $exit_status"
exit $exit_status
