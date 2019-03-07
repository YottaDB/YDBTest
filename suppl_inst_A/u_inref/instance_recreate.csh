#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2012, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that even though its instance file was recreated, Q has knowledge of A and its LMS group the moment
#       the first A update gets propagated from P. Without this knowledge, a switchover in the P<->Q LMS
#       group will cause errors when A and Q connect.
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

$MSR STOPRCV INST3 INST4
$MSR RUN INST4 "mv mumps.repl mumps.repl_bak"

#start receiver with updateresync and and create mumps.repl as it does not exists
$MSR RUN INST3 '$MUPIP backup -replinstance=instbak.repl; mv srcinstback.repl bak_srcinstback.repl' >&! inst3_bkup.log
$MSR RUN SRC=INST3 RCV=INST4 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/instbak.repl _REMOTEINFO___RCV_DIR__/srcinstback.repl' >>&! cp_remote_file.logx
setenv needupdatersync 1
$MSR STARTRCV INST3 INST4
unsetenv needupdatersync

#Stop updates on A and P
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_1.out
$MSR RUN INST3 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/endtp.csh' >&! endtp_inst3_1.out

#switchover from P to Q
$MSR STOP INST1 INST3
$MSR STOP INST3 INST4
$MSR START INST4 INST3 RP
$MSR STARTSRC INST1 INST4
$MSR STARTRCV INST1 INST4

$MSR SYNC ALL_LINKS
$MSR STOP ALL_LINKS

$gtm_tst/com/dbcheck.csh -extract
