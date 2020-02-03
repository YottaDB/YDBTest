#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test verifies that the DRD is not incremented for databases in MM mode
# and that the DRD is incremented for databases in BG mode.

# disable test-system dictated journaling.
setenv gtm_test_jnl NON_SETJNL

# MM mode first
echo "Validating MM mode does not increase DRD"
setenv acc_meth MM
setenv test_encryption NON_ENCRYPT
$gtm_tst/com/dbcreate.csh .
$ydb_dist/mumps -r ^ydb503
$gtm_tst/com/dbcheck.csh
# BG mode second
echo ""
echo "-------------------------------------"
echo ""
echo "Validating BG mode still increments DRD"
setenv acc_meth BG
$gtm_tst/com/dbcreate.csh .
$ydb_dist/mumps -r ^ydb503
$gtm_tst/com/dbcheck.csh
