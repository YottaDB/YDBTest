#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test -noresync rollback between A and P (non-supplementary and supplementary respectively)
#	where where A seqno < P seqno and history matches
#

# Turn off statshare related env var as it affects test output (inside a backward rollback command with
# extra SHMREMOVED/SEMREMOVED messages and affects a diff of the backward rollback output with the forward
# rollback output. It is not considered worth the trouble to fix the test for STATSHARE and NON_STATSHARE.
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

source $gtm_tst/com/gtm_test_setbeforeimage.csh
$MULTISITE_REPLIC_PREPARE 2 2

# Randomly choose the 1, 2 or 3 regions.
@ db_num = `$gtm_exe/mumps -run rand 3`
@ db_num = $db_num + 1

echo
echo "Check the output of dbcreate in dbcreate.log"
setenv gtm_test_sprgde_id "ID${db_num}"	# to create/use different .sprgde files based on # of regions
# Use "-nostats" below to avoid statsdb from being opened by update process (which in turn would cause extra
# SHMREMOVED/SEMREMOVED messages in backward rollback command and affect a diff of the backward rollback output
# with the forward rollback output (same reason mentioned above where "ydb_statshare" env var is disabled).
$gtm_tst/com/dbcreate.csh mumps $db_num 125 1000 1024 4096 1024 4096 -nostats >&! dbcreate.log

echo
echo "===>Start replication A->B, P->Q and A->P"
echo
setenv needupdatersync 1
$MSR START INST1 INST2 RP
$MSR START INST3 INST4 RP
$MSR START INST1 INST3 RP
unsetenv needupdatersync

source $gtm_tst/com/set_gtm_test_wait_factor.csh	# set gtm_test_wait_factor env var to control SLOWFILL rate of updates

echo
echo "===>Do some updates on A and P and let them replicate to B, P and Q as appropriate"
echo
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst1_1.out
$MSR RUN INST3 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/imptp.csh' >&! imptp_inst3_1.out
# Following sleep along with environment variable gtm_test_wait_factor ensures that there will be reasonable updates on instance A and P before switchover
sleep 1

# Switch over from A to B
echo
echo "Switch over from A to B"
echo
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_1.out
$MSR SYNC INST1 INST2
$MSR STOP INST1 INST2
$MSR STOP INST1 INST3
$MSR START INST2 INST1 RP
$MSR START INST2 INST3 RP
$MSR RUN INST2 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst2_1.out
# Following sleep along with environment variable gtm_test_wait_factor ensures that there will be reasonable updates on instance A and P before switchover
sleep 1

echo
echo "Switch over back from B to A"
echo
$MSR RUN INST2 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst2_1.out
$MSR SYNC INST2 INST1
$MSR STOP INST2 INST1
$MSR STOP INST2 INST3
$MSR START INST1 INST2 RP
$MSR START INST1 INST3 RP
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst1_2.out
# Following sleep along with environment variable gtm_test_wait_factor ensures that there will be reasonable updates on instance A and P before switchover
sleep 1

#Stop updates on A and P
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_2.out
$MSR RUN INST3 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/endtp.csh' >&! endtp_inst3_1.out

#wait for zero backlog on links from non-supplementary group
$MSR SYNC INST1 INST2
$MSR SYNC INST1 INST3

$MSR STOP INST1 INST2
$MSR STOP INST1 INST3
$MSR STOPRCV INST3 INST4
$MSR STOPSRC INST3 INST4

# take snapshot at A
echo
echo take snapshot at A
echo

$MSR RUN INST1 'mkdir snapshot; cp *.dat *.mjl* *.repl snapshot/'	## BYPASSOK backup_dbjnl.csh

# Rollback B at different seqno
$MSR RUN INST1 '$MUPIP replic -edit -show mumps.repl >&! instance.out ; $grep "Start Sequence Number" instance.out' >&! seqno.out

set seqno = `$grep "HST" seqno.out | $tst_awk '{print $8}'`

foreach value (3 1 2)
	@ newseqno = $seqno[$value] + 5
	echo "# Database will be rolled back to GTM_TEST_DEBUGINFO $newseqno"
	$MSR RUN INST1 "mkdir state$value"
	$MSR RUN INST1 'mv *.dat *.mjl* *.repl '"state$value/"		## BYPASSOK backup_dbjnl.csh
	$MSR RUN INST1 'cp snapshot/* .'

	$MSR RUN INST1 "$gtm_tst/com/mupip_rollback.csh -resync=$newseqno -lost=x_$newseqno.los "'"*"' >&! rollback_$newseqno.log

	$MSR STARTSRC INST1 INST2 RP
	$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_$value.out
	$MSR STARTSRC INST3 INST4 RP
	$MSR STARTRCV INST1 INST3 noresync
	$MSR STARTSRC INST1 INST3 RP
	$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_$value.out
	$MSR SYNC INST1 INST3
	$MSR STOPRCV INST1 INST3
	$MSR STOPSRC INST3 INST4
	$MSR STOPSRC INST1 INST3
	$MSR STOPSRC INST1 INST2
end

echo
echo "===>Stop all links"
echo
$MSR STOP ALL_LINKS

# Since receiver is started with  noresync, it is expected that all the datasebase could be differ in globals
$gtm_tst/com/dbcheck_filter.csh
