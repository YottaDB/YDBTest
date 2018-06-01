#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
# Test -noresync rollback between A and P (non-supplementary and supplementary respectively)
#	where where A seqno < P seqno and history matches
#

source $gtm_tst/com/gtm_test_setbeforeimage.csh
$MULTISITE_REPLIC_PREPARE 2 2

# Randomly choose the 1, 2 or 3 regions.
@ db_num = `$gtm_exe/mumps -run rand 3`
@ db_num = $db_num + 1

echo
echo "Check the output of dbcreate in dbcreate.log"
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

echo
echo "Take the backup on A"
echo
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_1.out
$MSR SYNC INST1 INST2
$MSR STOPSRC INST1 INST2
$MSR STOPSRC INST1 INST3
$MSR RUN  INST1 "mkdir bak1; $MUPIP backup -replinstance=bak1 "'"*" bak1' >&! inst1_bkup.log
$MSR STARTSRC INST1 INST2 RP
$MSR STARTSRC INST1 INST3 RP
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst1_2.out
# Following sleep along with environment variable gtm_test_wait_factor ensures that there will be reasonable updates on instance A and P before switchover
sleep 1

echo
echo "Take the backup on B"
echo
$MSR STOPRCV INST1 INST2
$MSR RUN  INST2 "mkdir bak1; $MUPIP backup -replinstance=bak1 "'"*" bak1' >&! inst2_bkup.log
$MSR STARTRCV INST1 INST2

#Stop updates on A and P
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_2.out
$MSR RUN INST3 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/endtp.csh' >&! endtp_inst3_1.out

#wait for zero backlog on links from non-supplementary group
$MSR SYNC INST1 INST2
$MSR SYNC INST1 INST3

#--- test case 1 -----
echo
echo "test case 1:Test -noresync operation with an older former state of B "
echo
$MSR STOP INST1 INST3
#$MSR STOPSRC INST3 INST4
$MSR STOP INST1 INST2
# Because we are going to restore db from a backup, the database file will have replication turned off
# and so we need to make sure any leftover ipcs are cleaned up before then.
$MSR RUN INST2 'source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh '$0'; cp -p bak1/* .'
#$MSR RUN INST3 "cp -p bak1/* ."
$MSR RUN INST1 'source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh '$0'; cp -p bak1/*.dat bak1/*.mjl bak1/*.repl .'

# A <-> B
# Test -noresync operation with one former state of B
$MSR STOPRCV INST3 INST4
$MSR STARTSRC INST2 INST3 RP
$MSR STARTRCV INST2 INST3 noresync

echo
echo "test case 2:Test -noresync operation with an even older former state of A "
echo
$MSR STOPRCV INST2 INST3
$MSR STOPSRC INST2 INST3
$MSR STARTSRC INST1 INST3 RP
$MSR STARTRCV INST1 INST3 noresync

# Since receiver is started with  noresync, it is expected that all the datasebase could be differ in globals
$gtm_tst/com/dbcheck.csh
