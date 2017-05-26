#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Recreate a customer issue where processes were SIGTERM'd while the instance was frozen,
# leading to the hang of processes which should have been read-only, represented by the
# checkhealth and second freeze check below.

# We need custom errors to enable the policy, but no actual errors, so set it to /dev/null and disable fake enospc.
setenv gtm_custom_errors /dev/null
setenv gtm_test_fake_enospc 0

$MULTISITE_REPLIC_PREPARE 2

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps 1 125 1000 4096 2000 4096 2000 								>& dbcreate.log
$MSR START INST1 INST2 RP												>& start.log
get_msrtime
set start_time=$time_msr

echo "# Freeze replication instance"
$MSR RUN INST2 '$MUPIP replic -source -freeze=on -comment=gtm8177'							>& freeze.log
$gtm_exe/mumps -run %XCMD 'set ^a=1'
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log RCVR_'${time_msr}'.log.updproc -message MUINSTFROZEN'

echo "# Kill all processes accessing the database file"
$MSR RUN INST2 '$kill -TERM `fuser mumps.dat`'										>& term.log
sleep 5
$MSR RUN INST2 '$MUPIP ftok mumps.dat'
$MSR RUN INST2 '$MUPIP ftok -jnlpool mumps.repl'
$MSR RUN INST2 '$MUPIP ftok -recvpool mumps.repl'

echo "# Check Freeze, expect frozen"
$MSR RUN INST2 '$MUPIP replic -source -freeze'

echo "# Check Passive Source Health, expect no hang"
$MSR RUN INST2 '$MUPIP replicate -source -checkhealth'

echo "# Check Freeze, expect no hang"
$MSR RUN INST2 '$MUPIP replic -source -freeze'

echo "# Unfreeze"
$MSR RUN INST2 '$MUPIP replic -source -freeze=off'

# Stop and restart the receiver. No particular reason besides the fact that it was in the original customer scenario.
echo "# Stop Receiver"
# The receiver shutdown sometimes returns an error status, depending on the shutdown order when killed, but otherwise succeeds,
# so filter out the status message.
$MSR RUN INST2 '$MUPIP replic -receiv -shutdown -timeout=0'	>& recv_shutdown.logx
$grep -v 'replic action failed' recv_shutdown.logx

echo "# Restart Receiver"
$MSR STARTRCV INST1 INST2

$gtm_tst/com/dbcheck.csh
