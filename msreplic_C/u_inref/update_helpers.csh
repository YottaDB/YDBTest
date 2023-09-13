#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#=====================================================================

$echoline
echo "# use an external filter in the source servers:"
source $gtm_tst/com/random_extfilter.csh	# sets gtm_tst_ext_filter_src and gtm_tst_ext_filter_rcvr env vars
# Do the above BEFORE MULTISITE_REPLIC_PREPARE that way these env vars are automatically transported to the remote sites
# in case of a -multisite (i.e. multi-host) run.

$MULTISITE_REPLIC_PREPARE 3
# due to -different_gld option, the gld layout will be different in INST1 and [INST2 and INST3]
$gtm_tst/com/dbcreate.csh . 5 125 1000 4096 2000 4096 2000 -different_gld

# Copy gtm_tst_ext_filter_* env vars to INST2 and INST3 in case this is a -multisite test
$MSR RUN INST2 "set msr_dont_trace ; echo setenv gtm_test_spanreg 0 >> env_supplementary.csh"

# The above makes this test also an ext_filter_stress test since a lot of data is pushed
$MSR STARTSRC INST1 INST2

$echoline
echo "# Start the updates"
setenv gtm_test_tptype "ONLINE"
setenv gtm_test_tp "TP"
setenv gtm_process  5
setenv tst_buffsize 33000000
setenv test_tn_count 3000
setenv test_sleep_sec 30
$gtm_tst/com/imptp.csh $gtm_process >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1

$echoline
echo "# Create a backlog, and a couple of history records:"
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "" noerror
setenv gtm_test_other_bg_processes
echo "# Stop the updates"
$gtm_tst/com/endtp.csh >>&! imptp.out
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2
echo "# Start the updates"
$gtm_tst/com/imptp.csh $gtm_process >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "" noerror
echo "# Stop the updates"
$gtm_tst/com/endtp.csh >>&! imptp.out
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2
echo "# Start the updates"
$gtm_tst/com/imptp.csh $gtm_process >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "" noerror
echo "# Stop the updates"
$gtm_tst/com/endtp.csh >>&! imptp.out
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2
echo "# Start the updates"
$gtm_tst/com/imptp.csh $gtm_process >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "" noerror
echo "# Stop the updates"
$gtm_tst/com/endtp.csh >>&! imptp.out
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2
echo "# Start the updates"
$gtm_tst/com/imptp.csh $gtm_process >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "" noerror
echo "# Stop the updates"
$gtm_tst/com/endtp.csh >>&! imptp.out
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2
echo "# Start the updates"
$gtm_tst/com/imptp.csh $gtm_process >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "" noerror
echo "# Stop the updates"
$gtm_tst/com/endtp.csh >>&! imptp.out
unsetenv gtm_test_other_bg_processes
set cur_seqno = `$gtm_tst/com/compute_src_seqno_from_showbacklog_file.csh wait_for_transaction_seqno.backlog`
$echoline
echo "#Start the source server to INST3:"
$MSR STARTSRC INST1 INST3

$echoline
# slow down the updates
if (20000 < $cur_seqno) then
	setenv gtm_test_dbfill SLOWFILL
	setenv test_tn_count 1000
	setenv test_sleep_sec 10
endif
echo "#Start the receivers:"
$MSR STARTRCV INST1 INST2
echo "# Start the updates"
$gtm_tst/com/imptp.csh $gtm_process >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
# give INST2 some time to partially catch-up
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "INSTANCE2" noerror
$MSR STARTRCV INST1 INST3
echo "#- Start helpers on INST3:"
$MSR RUN RCV=INST3 SRC=INST1 '$MUPIP  replicate -receive -start -helpers >& helpers_start.out'
echo "# Stop the updates"
$gtm_tst/com/endtp.csh >>&! imptp.out

$echoline
$MSR SYNC ALL_LINKS
$gtm_tst/com/dbcheck.csh -extract INST1 INST2 INST3
#=====================================================================
