#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Since the reference file for this test has "SUSPEND_OUTPUT 4G_ABOVE_DB_BLKS" usage, it needs to fixate
# the value of the "ydb_test_4g_db_blks" env var in case it is randomly set by the test framework to a non-zero value.
if (0 != $ydb_test_4g_db_blks) then
	echo "# Setting ydb_test_4g_db_blks env var to a fixed value as reference file has 4G_ABOVE_DB_BLKS usages" >> settings.csh
	setenv ydb_test_4g_db_blks 8388608
endif

setenv test_reorg NON_REORG
setenv gtm_test_mupip_set_version "V5"
$gtm_tst/com/dbcreate.csh mumps 3 -block_size=1024	# The truncate tests below are sensitive to block layout
$gtm_dist/mumps -run truncatehasht

# Truncate each database file
$MUPIP reorg -truncate |& $grep -E "Truncated|TRUNC|#t"

$gtm_tst/com/dbcheck.csh
