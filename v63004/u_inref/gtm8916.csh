#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

# Avoid frozen instance (due to fake enospc) triggered by an update process which will never be unfrozen because it was kill -9ed by the test.
unsetenv gtm_test_freeze_on_error

$MULTISITE_REPLIC_PREPARE 2

echo "# Create a single region DB with region DEFAULT"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

echo "# Start replication"
$MSR START INST1 INST2
get_msrtime # store timestamp in time_msr

# Get update process ID

echo "# Start loop"
@ x = 1
while ($x <= 10)
	echo "\t# Iteration $x\:"

	# If this is the 2nd or a later iteration, we would have killed the update process in the previous iteration
	# and restarted it. It is possible the update process startup is not yet complete when we look for the
	# "Update Process started" message in the receiver log file. If so, searching for that string could instead
	# give us the update process pid from the previous iteration. To avoid such issues, we cound the number of
	# matching lines and make sure we have as many as the iteration number and only in that case do we proceed
	# to note down the last matching line as containing the latest update process pid.
	while (1)
		$MSR RUN INST2 "cat RCVR_$time_msr.log" > RCVR.log
		set cnt = `$grep -e "Update Process started." RCVR.log | wc -l`
		if ($cnt == $x) then
			break
		endif
		sleep 1
	end
	set updatePID=`$grep -e "Update Process started." RCVR.log | tail -1 | $tst_awk '{ print $11 }'`
	#echo "updatePID: $updatePID"

	sleep 1s
	$MSR RUN INST2 "kill -9 $updatePID# Kill update process"
	sleep 1s
	$MSR RUN INST2 "$MUPIP REPLIC -RECEIVE -START -UPDATEONLY # Restart update process"

	echo ""
	echo "----------------------------------------------------------------------------"
	echo ""
	@ x = $x + 1
end

echo "# Sync source and replicating servers"
$MSR SYNC INST1 INST2

echo "# Stop replication"
$MSR STOP INST1 INST2

#setenv gtm_test_norfsync
echo "# Check the DB"
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif

