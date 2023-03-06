#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2019-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#

echo '# MUPIP INTEG reports an interrupted MUPIP JOURNAL -RECOVER/-ROLLBACK operation on the database'
echo '# Previously, a MUPIP INTEG on such a database did not report an interrupted recovery'
echo '# Note: The "MUPIP dumpfhead" command already provided this information'
echo '# GT.M reports the "Recover interrupted" field with DSE DUMP -FILEHEADER even when journal is turned off'
echo '# Previously, GT.M reported the "Recovery interrupted" field only with DSE DUMP -FILEHEADER -ALL and only when journaling was turned ON'

echo '# Enabling journaling as it is needed for the test'
setenv acc_meth "GC"
setenv gtm_test_jnl "SETJNL"
setenv tst_jnl_str '-journal="enable,on,before"'

# these two environment variables can cause the test to hang so unset them
unsetenv gtm_db_counter_sem_incr
unsetenv gtm_test_fake_enospc
# rollback can only be done on replic tests
if ($?test_replic == 1) then
	set types = "recover rollback"
else
	set types = "recover"
endif
foreach type ($types)
	echo "# Testing -$type switch"
	$gtm_tst/com/dbcreate.csh mumps$type
	setenv gtmgbldir mumps$type
	echo "# Interrupting $type"
	set format="%d-%b-%Y %H:%M:%S"
	set time1=`date +"$format"`
	($gtm_dist/mumps -run %XCMD 'for i=0:1 set ^a(i)=i' &; echo $! >! ydb$type.pid) >&! ydb$type.outx
	sleep 5
	if($type == "rollback") then
		# replication needs to be crashed before attempting a rollback
		# fuser prints out the file name to stderr for some reason. It's junk so filter out
		(fuser mumps$type.dat | cut -d ' ' -f 1- >! ydb$type.pid) >&! /dev/null
		set ydbPid=`cat ydb$type.pid`
		tcsh $gtm_tst/com/gtm_crash.csh "PID_" $ydbPid # crash the pid
	else
		# if it is a recover just stop the yottadb process
		# and shut replication down normally
		set ydbPid=`cat ydb$type.pid`
		kill -15 $ydbPid
		if($?test_replic == 1) then
			$gtm_tst/com/RF_SHUT.csh >&! replicStop$type.outx
			if($status != "0") then
				echo "Replication shut down failed exiting"
				exit
			endif
		endif
	endif
	# wait for all mumps processes to die
	foreach pid ($ydbPid)
		$gtm_tst/com/wait_for_proc_to_die.csh $pid
	end
	($gtm_dist/mupip journal -$type -backward -since=\"$time1\" -verbose "*" &; echo $! >&! mupip$type.pid) >&! mupip$type.outx
	# Busy wait till the correct string apears in the output file
	# This is to ensure that the process is interrupted at the correct step regardless of the speed of the system
	set foundStr = 1
	while (0 != $foundStr)
		grep 'Backward' mupip$type.outx > /dev/null
		set foundStr = $status
	end

	set pipPid = `cat mupip$type.pid`
	kill -9 $pipPid # sigkill the pid
	$gtm_tst/com/wait_for_proc_to_die.csh $pipPid
	if ($type == "rollback" ) then
		$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh '.' < /dev/null >>& $SEC_SIDE/SHUT_A.out"
	endif
	$gtm_dist/mupip rundown -reg "*" >&! rundown$type.outx
	$gtm_dist/mupip integ -reg "*" >&! integ$type.outx
	echo '# greping integ output for "Recover Interrupted.*TRUE"'
	grep "Recover Interrupted.*TRUE" integ$type.outx
	if (0 == $status) then
		echo 'PASS'
	else
		echo 'FAIL'
	endif
	# clear the shared memory
	setenv ftok_key `$MUPIP ftok -id=43 *.dat |& grep ".dat" | $tst_awk '/dat/{print substr($10, 2, 10);}'`
	set dbipc_private = `$gtm_tst/com/db_ftok.csh`
	$gtm_tst/com/ipcrm $dbipc_private
	$gtm_tst/com/rem_ftok_sem.csh $ftok_key
end
