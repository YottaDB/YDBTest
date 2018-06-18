#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test that MUPIP JOURNAL -EXTRACT does not issue JNLUNXPCTERR error in the face of concurrent udpates"

setenv gtm_test_jnl SETJNL
echo "# Create database with journaling turned on"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate.out
	exit -1
endif

echo "# Start MUPIP JOURNAL EXTRACT commands in background"
($gtm_tst/$tst/u_inref/jnlunxpcterr_jnlext_bg.csh & ; echo $! >&! jnlext_bg.pid) >&! jnlext_bg.out
set jnlextpid = `cat jnlext_bg.pid`

echo "# Update the journal file in the foreground so multiple EOF records get written (and overwritten)"
set starttime = `date +%s`
while (1)
	if (-e jnlext.ERROR) then
		# jnlunxpcterr_jnlext_background.csh encountered an error. Stop the test
		break
	endif
	# Do an update while MUPIP JOURNAL EXTRACT is concurrently running in the background
	$ydb_dist/mumps -run ^%XCMD 'set ^x=(+($get(^x))+1)_$justify(1,2+$random(20))'
	set currtime = `date +%s`
	set elapsedtime = `expr $currtime - $starttime`
	if (15 < $elapsedtime) then
		# If 15 seconds elapsed then stop the test
		break
	endif
end

echo "# Signal backgrounded MUPIP JOURNAL EXTRACT script to stop"
touch jnlext.STOP

echo "# Wait for backgrounded script to terminate"
$gtm_tst/com/wait_for_proc_to_die.csh $jnlextpid -1

echo "# Check for any errors in MUPIP JOURNAL EXTRACT"
$grep "\-E-" jnlext_bg.out

echo "# Do dbcheck on database"
$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck.out
	exit -1
endif
