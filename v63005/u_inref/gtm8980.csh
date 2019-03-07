#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
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

echo '# GTM-8980 calls for testing calls of VIEW and $VIEW with an empty string: '
echo '#     VIEW and $VIEW() with a empty string or inappropriate region-list works appropriately;'
echo '#      in V6.3-004 these could cause inappropriate results, including a segmentation violation (SIG-11)'
echo '# This test case is already handled by r122/viewcmdfunc subtest and will be skipped'
echo '# (in test6^viewcmdfunc and test7^viewcmdfunc)'
echo ''

echo '# Run test1^gtm8980.m'
$ydb_dist/mumps -run test1^gtm8980
echo ""

echo '# Run test2^gtm8980.m'
echo '# $VIEW("statshare","") works appropriately even if the region had been selectively disabled'
echo '# when full sharing is disabled and the region had not been opened.'
echo '# In V6.3-004, this set of conditions produced a segmentation violation (SIG-11)'
$ydb_dist/mumps -run test2^gtm8980
echo ""

echo '# Run test3a^gtm8980.m, test3b^gtm8980.m, test3c^gtm8980.m'
echo '# The error messages when invalid parameters are passed to VIEW/$VIEW() print the name of the parameter;'
echo '# previously such error messages did not have the name of the parameter.'
$ydb_dist/mumps -run test3a^gtm8980
echo ""
$ydb_dist/mumps -run test3b^gtm8980
echo ""
$ydb_dist/mumps -run test3c^gtm8980
echo ""

echo '# Shut down the DB'
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
