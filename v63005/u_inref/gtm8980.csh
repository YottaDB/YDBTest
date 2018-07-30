#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# Running v63005/gtm8980.csh to test that rare uses of VIEW and $VIEW are handled correctly '
echo ''

echo "# Create a 3 region DB with gbl_dir mumps.gld and regions DEFAULT, AREG, and BREG"
$gtm_tst/com/dbcreate.csh mumps 3 >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif
echo ""
echo ""

echo '# GTM-8980 calls for testing calls of VIEW and $VIEW with an empty string'
echo '# This test case is already handled by r122/viewcmdfunc subtest and will be skipped'
echo '# (in test6^viewcmdfunc and test7^viewcmdfunc)'
echo ''

echo '# Run test1^gtm8980.m'
$ydb_dist/mumps -run test1^gtm8980
echo ""

echo '# Run test2^gtm8980.m'
$ydb_dist/mumps -run test2^gtm8980
echo ""

echo '# Run test3a^gtm8980.m, test3b^gtm8980.m, test3c^gtm8980.m'
$ydb_dist/mumps -run test3a^gtm8980
echo ""
$ydb_dist/mumps -run test3b^gtm8980
echo ""
$ydb_dist/mumps -run test3c^gtm8980
echo ""
#####MAKE SURE TEST 3 IS IMPLEMENTED CORRECTLY#####

echo '# Shut down the DB'
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
