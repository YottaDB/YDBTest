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
echo '# Testing'


echo "# Create a 3 region DB with gbl_dir mumps.gld and regions DEFAULT, AREG, and BREG"
$gtm_tst/com/dbcreate.csh mumps 3 >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif
echo ""
echo ""

echo '# Run test1a^gtm8980.m and test1b^gtm8980.m'
$ydb_dist/mumps -run test1a^gtm8980
echo ""
$ydb_dist/mumps -run test1b^gtm8980
echo ""

echo '# Run test2^gtm8980.m'
$ydb_dist/mumps -run test2^gtm8980
echo ""

echo '# Run test3^gtm8980.m'
$ydb_dist/mumps -run test3^gtm8980
echo ""

echo '# Run test4^gtm8980.m'
$ydb_dist/mumps -run test4a^gtm8980
echo ""
$ydb_dist/mumps -run test4b^gtm8980
echo ""
#####MAKE SURE TEST 3 IS IMPLEMENTED CORRECTLY#####

echo '# Shut down the DB and backup necessary files to sub directory'
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
