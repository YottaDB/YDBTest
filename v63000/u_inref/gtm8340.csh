#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

# Test starting and stopping helpers while running.

# We are doing A>B>C, which doesn't work with SI
setenv test_replic_suppl_type 0
echo "# override test_replic_suppl_type in test"	>>! settings.csh
echo "setenv test_replic_suppl_type 0"			>>! settings.csh

# We manually start and stop helpers, so we don't need the random set.
setenv gtm_test_updhelpers 0
echo "# override gtm_test_updhelpers in test"		>>! settings.csh
echo "setenv gtm_test_updhelpers 0"			>>! settings.csh

$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/com/dbcreate.csh . 2 125 1000 4096 2000 4096 2000 >&! dbcreate.out
$MSR START INST1 INST2 RP
$MSR START INST2 INST3 PP

# Test stopping helpers while still updating on the primary
@ round=1
echo "# Round ${round}"
$gtm_tst/com/imptp.csh 1 >&! imptp${round}.out
source $gtm_tst/com/imptp_check_error.csh imptp${round}.out; if ($status) exit 1
$MSR RUN RCV=INST2 SRC=INST1 '$gtm_tst/com/wait_for_transaction_seqno.csh +100 SRC 120 "" noerror'
$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP  replicate -receive -start -helpers' >& helpers_start${round}.out
$MSR RUN RCV=INST2 SRC=INST1 '$gtm_tst/com/wait_for_transaction_seqno.csh +100 SRC 120 "" noerror'
$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP  replicate -receive -shutdown -helpers -timeout=0' >& helpers_shut${round}.out
$MSR RUN RCV=INST2 SRC=INST1 '$gtm_tst/com/wait_for_transaction_seqno.csh +100 SRC 120 "" noerror'
$gtm_tst/com/endtp.csh >&! endtp${round}.out
$MSR SYNC ALL_LINKS

# Test stopping helpers after source backlog gets to zero
@ round=2
echo "# Round ${round}"
$gtm_tst/com/imptp.csh 1 >&! imptp${round}.out
source $gtm_tst/com/imptp_check_error.csh imptp${round}.out; if ($status) exit 1
$MSR RUN RCV=INST2 SRC=INST1 '$gtm_tst/com/wait_for_transaction_seqno.csh +100 SRC 120 "" noerror'
$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP  replicate -receive -start -helpers' >& helpers_start${round}.out
$MSR RUN RCV=INST2 SRC=INST1 '$gtm_tst/com/wait_for_transaction_seqno.csh +100 SRC 120 "" noerror'
$gtm_tst/com/endtp.csh >&! endtp${round}.out
$gtm_tst/com/wait_until_src_backlog_below.csh 0
$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP  replicate -receive -shutdown -helpers -timeout=0' >& helpers_shut${round}.out
$MSR SYNC ALL_LINKS

# Test stopping helpers after receiver backlog gets to zero
@ round=3
echo "# Round ${round}"
$gtm_tst/com/imptp.csh 1 >&! imptp${round}.out
source $gtm_tst/com/imptp_check_error.csh imptp${round}.out; if ($status) exit 1
$MSR RUN RCV=INST2 SRC=INST1 '$gtm_tst/com/wait_for_transaction_seqno.csh +100 SRC 120 "" noerror'
$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP  replicate -receive -start -helpers' >& helpers_start${round}.out
$MSR RUN RCV=INST2 SRC=INST1 '$gtm_tst/com/wait_for_transaction_seqno.csh +100 SRC 120 "" noerror'
$gtm_tst/com/endtp.csh >&! endtp${round}.out
$MSR RUN RCV=INST2 SRC=INST1 '$gtm_tst/com/wait_until_rcvr_backlog_below.csh 0'
$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP  replicate -receive -shutdown -helpers -timeout=0' >& helpers_shut${round}.out
$MSR SYNC ALL_LINKS

$gtm_tst/com/dbcheck.csh -extract
