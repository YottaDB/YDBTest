#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

# Turn off statshare related env var as it affects test output and is not considered worth the trouble to maintain
# the reference file with SUSPEND/ALLOW macros for STATSHARE and NON_STATSHARE
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

echo "# ----------------------------------------------------------------------------"
echo "# Test that epoch_interval setting is honored even if an idle epoch is written"
echo "# ----------------------------------------------------------------------------"
#
echo "# Enable journaling on the database"
setenv gtm_test_jnl SETJNL
echo "# Set epoch_interval of 2 seconds"
setenv tst_jnl_str "$tst_jnl_str,epoch=2"
echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate.out
	exit -1
endif

echo "# Invoke : mumps -run ydb341"
$ydb_dist/mumps -run ydb341

echo "# Do dbcheck on database"
$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck.out
	exit -1
endif
