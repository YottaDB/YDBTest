#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test uses specific to block numbers and so will fail if used with the debug-only HOLE scheme to test > 4g db blocks.
# Therefore disable that scheme.
setenv ydb_test_4g_db_blks 0
# Disable V6 DB mode to prevent reference file differences with MUPIP and DSE command outputs
setenv gtm_test_use_V6_DBs 0

$gtm_tst/com/dbcreate.csh mumps

# create a database with a broken alignement
cp mumps.dat copy
cat copy >> mumps.dat
# integ should fail with DBMISALIGN
$MUPIP integ mumps.dat
# fix the issue by extending the database
$MUPIP extend -block=1124 DEFAULT
# integ should pass
$MUPIP integ mumps.dat

# create a database with correct alignment, but wrong block count
$DSE change -file -total=111
# integ should fail with DBTOTBLK
$MUPIP integ mumps.dat
# fix the issue
$DSE change -file -total=4CB
# integ should pass
$MUPIP integ mumps.dat

$gtm_tst/com/dbcheck.csh
