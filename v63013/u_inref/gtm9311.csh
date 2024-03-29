#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Turn off statshare related env var as it affects test output and is not considered worth the trouble to maintain
# the reference file with SUSPEND/ALLOW macros for STATSHARE and NON_STATSHARE
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

echo '# Test for GTM-9311 - Test that the variables x and d are preserved across a call to %YGBLSTAT. Start'
echo '# with no values in either var, drive ^%YGBLSTAT, then check $data() values for both and if either is'
echo '# non-zero, we have a failure.'
echo
echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps
echo
echo '# Drive gtm9311 test routine'
$ydb_dist/yottadb -run gtm9311 << EOF




EOF
echo
echo "# Verify database we (very lightly) used"
$gtm_tst/com/dbcheck.csh
