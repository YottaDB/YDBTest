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

# Since the reference file for this test has "SUSPEND_OUTPUT 4G_ABOVE_DB_BLKS" usage, it needs to fixate
# the value of the "ydb_test_4g_db_blks" env var in case it is randomly set by the test framework to a non-zero value.
if (0 != $ydb_test_4g_db_blks) then
	echo "# Setting ydb_test_4g_db_blks env var to a fixed value as reference file has 4G_ABOVE_DB_BLKS usages" >> settings.csh
	setenv ydb_test_4g_db_blks 8388608
endif

source $gtm_tst/com/gtm_test_setbgaccess.csh	# TRUNCATE requires BG access method
setenv gtm_test_mupip_set_version "disable"	# TRUNCATE requires no V4 format blocks
setenv gtm_test_spanreg     0		# Test requires traditional global mappings, so disable spanning regions
echo "Create TWO database files a.dat and mumps.dat"
$gtm_tst/com/dbcreate.csh mumps 2	# creates a.dat and mumps.dat
echo ""
echo "Execute : mumps -run gtm8187 to populate two database files before truncation"
$gtm_exe/mumps -run gtm8187
echo ""
echo "cp a.dat abak.dat"
cp a.dat abak.dat
echo ""
echo "Run MUPIP reorg -truncate"
$MUPIP reorg -truncate
echo ""
echo "Run MUPIP reorg -truncate one more time and verify no more truncation happens (i.e. previous truncate was optimal)"
$MUPIP reorg -truncate
echo ""
echo "Remove write permissions on a.dat and redo MUPIP reorg -truncate to ensure it does not SIG-11 etc. on a read-only database file"
cp abak.dat a.dat
chmod a-w a.dat
$MUPIP reorg -truncate
echo ""
echo "Do a dbcheck to ensure db integs clean"
chmod a+w a.dat
$gtm_tst/com/dbcheck.csh
