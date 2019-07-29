#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
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

# rollback can only be done on replic tests
unsetenv gtm_db_counter_sem_incr
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
	# replication needs to be shutdown before attempting a rollback
	if ($?test_replic == 1) then
		$gtm_tst/com/RF_SHUT.csh >&! replicStop$type.outx
	endif
	$gtm_dist/mumps -run %XCMD 'set st=$h for i=0:1  quit:($$^difftime($h,st))>5  set ^a(i)=i'
	($gtm_dist/mupip journal -$type mumps$type.mjl -backward -since=\"$time1\" &; echo $! >&! mupip$type.pid) >&! mupip$type.outx
	# Busy wait till the correct string apears in the output file
	# This is to ensure that the process is interupted at the correct step regardless of the speed of the system
	set foundStr = 1
	while (0 != $foundStr)
		grep 'Backward' mupip$type.outx > /dev/null
		set foundStr = $status
	end

	set pipPid = `cat mupip$type.pid`
	kill -9 $pipPid # sigkill the pid
	$gtm_tst/com/wait_for_proc_to_die.csh $pipPid

	$gtm_dist/mupip rundown -reg "*" >&! rundown$type.outx
	$gtm_dist/mupip integ -reg "*" >&! integ$type.outx
	echo '# greping integ output for "Recover Interrupted.*TRUE"'
	grep "Recover Interrupted\.*TRUE" integ$type.outx
	if (0 != $status) then
		echo 'PASS'
	else
		echo 'FAIL'
	endif
	# clear the shared memory
	setenv ftok_key `$gtm_exe/ftok -id=43 *.dat| $tst_awk '/dat/{print $5}'`
	set dbipc_private = `$gtm_tst/com/db_ftok.csh`
	$gtm_tst/com/ipcrm $dbipc_private
	$gtm_tst/com/rem_ftok_sem.csh $ftok_key
end
