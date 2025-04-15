#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv gtm_test_jnlfileonly 1
unsetenv gtm_custom_errors		# We do a manual freeze, so avoid automatic ones.

source $gtm_tst/com/gtm_test_setbeforeimage.csh

$MULTISITE_REPLIC_PREPARE 1 1

echo ">>> Create Database"
$gtm_tst/com/dbcreate.csh mumps 5 125-425 1000-1050 512,768,1024 4096 1024 4096

setenv test_replic_suppl_type 1		# A->P
$MSR START INST1 INST2 RP
get_msrtime
unsetenv needupdatersync

echo ">>> Start imptp"
$MSR RUN INST1 "setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh" >&! imptp1.out

echo ">>> Sleep"
$gtm_tst/com/wait_for_transaction_seqno.csh +1500 SRC 120 INSTANCE2

echo ">>> Update secondary, freeze primary, update secondary again, and crash primary"
$gtm_tst/com/simplegblupd.csh -instance INST2 -count 1
$MSR RUN INST1 '$MUPIP replic -source -freeze=ON -comment=gtm7862'
$gtm_tst/com/simplegblupd.csh -instance INST2 -count 1
$MSR CRASH INST1

echo ">>> Do rollback"

$MSR RUN INST1 '$gtm_tst/com/mupip_rollback.csh -losttrans=ignore.glo "*"' >& rollback.log

echo ">>> Restart Source Server"

$MSR STARTSRC INST1 INST2 RP

# At this point, if the secondary is ahead of the rolled-back primary, the receiver will issue a "Manual ROLLBACK required"
# message and exit, causing subsequent operations below to fail because the receive pool is unavailable.  Because of timing,
# this won't always happen, but it happens most of the time without JNLFILEONLY.  With JNLFILEONLY, which is enabled above,
# the secondary should never be ahead of the primary, so the test should complete peacefully.

echo ">>> dbcheck"

$gtm_tst/com/dbcheck_filter.csh -extract

echo ">>> Done"
