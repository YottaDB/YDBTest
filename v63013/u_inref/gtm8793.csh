#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test for GTM-8793 - Verify that when the script defined by ydb_procstuckexec env var fails is driven, if we"
echo "# get back a non-zero return code, this then drives a (new for V63013) EXITSTATUS error message. So we use DSE"
echo "# to grab crit, then try an update (which hangs on crit) until 30 seconds later when the MUTEXLCKALERT warning"
echo "# is triggered which also drives the procstuckexec script defined by ydb_procstucexec. In our case, the script"
echo "# won't exist triggering the error we need to get the EXITSTATUS error. Note the EXITSTATUS error is associated"
echo "# with other messages as well (STUCKACT and MUTEXLCKALERT) so we verify we get those too so while the main"
echo "# reason for this test is to see EXITSTATUS, we look for all three of the errors (STUCKACT, EXITSTATUS, and"
echo "# MUTEXLCKALERT)."
echo
echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps
echo
echo "# Drive gtm8793 test routine"
# Set up an attempt to execute a non-exisitent procstuck script when it fires
setenv ydb_procstuckexec noexistPSE.sh
$ydb_dist/yottadb -run gtm8793
echo
echo "# Verify database we (lightly) used"
$gtm_tst/com/dbcheck.csh
