#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2012, 2013 Fidelity Information Services, Inc	#
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
# Test A->B, P->Q and A->P replication with multiple switchovers
# Following switchovers are done in the test,
# i) B->A, P->Q, B->P
# i) B->A, Q->P, B->Q
# i) A->B, Q->P, A->P
# i) A->B, P->Q, A->P
#

source $gtm_tst/com/gtm_test_setbeforeimage.csh
$MULTISITE_REPLIC_PREPARE 2 2

# Randomly choose the 1, 2 or 3 regions.
@ db_num = `$gtm_exe/mumps -run rand 3`
@ db_num = $db_num + 1

echo
echo "Check the output of dbcreate in dbcreate.log"
echo
setenv gtm_test_sprgde_id "ID${db_num}"	# to create/use different .sprgde files based on # of regions
$gtm_tst/com/dbcreate.csh mumps $db_num 125 1000 1024 4096 1024 4096 >&! dbcreate.log

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
echo "Switch over from A to B"
# Stop updates on A
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_1.out
$MSR SYNC INST1 INST2
$MSR STOP INST1 INST2
$MSR STOP INST1 INST3
$MSR START INST2 INST1 RP
$MSR START INST2 INST3 RP
$MSR RUN INST2 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst2_1.out
# Following sleep along with environment variable gtm_test_wait_factor ensures that there will be reasonable updates on instance A and P before switchover
sleep 1

# Switch over from P to Q
echo "Switch over from P to Q"
# Stop updates on B and P
$MSR RUN INST2 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst2_1.out
$MSR RUN INST3 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/endtp.csh' >&! endtp_inst3_1.out
$MSR SYNC INST3 INST4
$MSR STOP INST2 INST3
$MSR STOP INST3 INST4
$MSR START INST4 INST3 RP
$MSR START INST2 INST4 RP
$MSR RUN INST2 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst2_2.out
$MSR RUN INST4 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/imptp.csh' >&! imptp_inst4_1.out
# Following sleep along with environment variable gtm_test_wait_factor ensures that there will be reasonable updates on instance A and P before switchover
sleep 1

# Switch over back from B to A
echo "Switch over back from B to A"
# Stop updates on B
$MSR RUN INST2 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst2_2.out
$MSR SYNC INST2 INST1
$MSR STOP INST2 INST1
$MSR STOP INST2 INST4
$MSR START INST1 INST2 RP
$MSR START INST1 INST4 RP
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst1_2.out
# Following sleep along with environment variable gtm_test_wait_factor ensures that there will be reasonable updates on instance A and P before switchover
sleep 1

# Switch over back from Q to P
echo "Switch over back from Q to P"
# Stop updates on A and Q
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_2.out
$MSR RUN INST4 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/endtp.csh' >&! endtp_inst4_1.out
$MSR SYNC INST4 INST3
$MSR STOP INST1 INST4
$MSR STOP INST4 INST3
$MSR START INST3 INST4 RP
$MSR START INST1 INST3 RP
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst1_3.out
$MSR RUN INST3 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/imptp.csh' >&! imptp_inst3_2.out
# Following sleep along with environment variable gtm_test_wait_factor ensures that there will be reasonable updates on instance A and P before switchover
sleep 1

# Stop updates on A and P
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_3.out
$MSR RUN INST3 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/endtp.csh' >&! endtp_inst3_2.out

# wait for zero backlog on all links
$MSR SYNC ALL_LINKS

echo
echo "===>Do showbacklog on A->B side"
echo
$MSR SHOWBACKLOG INST1 INST2 SRC

echo
echo "===>Do showbacklog on P->Q side"
echo
$MSR SHOWBACKLOG INST3 INST4 SRC

echo
echo "===>Do showbacklog on A->P side"
echo
$MSR SHOWBACKLOG INST1 INST3 SRC

$gtm_tst/com/dbcheck.csh -extract
