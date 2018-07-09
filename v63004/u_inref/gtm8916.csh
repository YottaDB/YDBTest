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
#

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
foreach x (1 2 3 4 5 6 7 8 9 10)
	echo "\t# Iteration $x\:"

	$MSR RUN INST2 "cat RCVR_$time_msr.log" > RCVR.log
	set updatePID=`$grep -e "Update Process started." RCVR.log | tail -1 | $tst_awk '{ print $11 }'`
	#echo "updatePID: $updatePID"

	sleep 1s
	$MSR RUN INST2 "kill -9 $updatePID# Kill update process"
	sleep 1s
	$MSR RUN INST2 "$MUPIP REPLIC -RECEIVE -START -UPDATEONLY # Restart update process"

	echo ""
	echo "----------------------------------------------------------------------------"
	echo ""
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

