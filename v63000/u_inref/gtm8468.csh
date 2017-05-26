#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test to verify that source server keeps its open jnl files minimal whether it starts with a non-zero or zero backlog

# Environment setup
setenv gtm_test_jnlfileonly 1	# The test is for -jnlfileonly related change
set test_tn_count = "1000"	# Wait for 1000 updates everytime
set test_sleep_sec = "10"	# Or a maximum sleep of 10 seconds

$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/com/dbcreate.csh mumps 3 125 1000 >&! dbcreate_output.out

$MSR START INST1 INST2
# start INST1-INST3 and shut it down before doing any updates.
# This is to workaround the framework always starting a first A->P replication with -updateresync and -initialize
# When INST1-INST3 is started for the first time after all the updates are done in INST1, doing the above is incorrect
$MSR STARTSRC INST1 INST3
$MSR STARTRCV INST1 INST3 waitforconnect
$MSR STOP INST1 INST3

$MSR RUN INST1 '$gtm_tst/com/imptp.csh >>&! imptp.out'
# Switch journal files thrice
@ i = 1
while ($i <= 3)
	$MSR RUN INST1 '$gtm_tst/com/wait_for_transaction_seqno.csh +'$test_tn_count' SRC '$test_sleep_sec' "" noerror'
	$MSR RUN INST1 '$gtm_tst/com/jnl_on.csh'
	@ i++
end
$MSR RUN INST1 '$gtm_tst/com/endtp.csh >>&! endtp.out'
$MSR SYNC ALL_LINKS

echo "# Get the pid of the source server replicating to INST2"
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_trace ; $gtm_tst/com/get_pid.csh src __RCV_INSTNAME__' >&! inst1_inst2_src.pid
set inst12pid = `cat inst1_inst2_src.pid`

echo "# fuser of *.mjl* should show only the latest generation mjl files open by INST1-INST2 source server"
$fuser *.mjl* >&! fuser_inst1_inst2.out
$tst_awk '/ '$inst12pid'/ {elems = split($1,path,"/"); print path[elems]}' fuser_inst1_inst2.out

$MSR START INST1 INST3
$MSR SYNC ALL_LINKS
echo "# Get the pid of the source server replicating to INST3"
$MSR RUN SRC=INST1 RCV=INST3 'set msr_dont_trace ; $gtm_tst/com/get_pid.csh src __RCV_INSTNAME__' >&! inst1_inst3_src.pid
set inst13pid = `cat inst1_inst3_src.pid`

echo "# fuser of *.mjl* should show only the latest generation mjl files open by INST1-INST3 source server"
$fuser *.mjl* >&! fuser_inst1_inst3.out
$tst_awk '/ '$inst13pid'/ {elems = split($1,path,"/"); print path[elems]}' fuser_inst1_inst3.out

$gtm_tst/com/dbcheck.csh -extract
