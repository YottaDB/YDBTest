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

#### testA ####
echo "# Create a single region DB with region DEFAULT"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt

echo '# Run testA^gtm8699.m to test $VIEW("STATSHARE") with V[IEW] "STATSHARE"'
$ydb_dist/mumps -run testA^gtm8699


$gtm_tst/com/dbcheck.csh >>& dbcreate_log.txt

#### testB ####
echo ''
echo "# Create a two region DB with regions DEFAULT"
$gtm_tst/com/dbcreate.csh mumps 2 >>& dbcreate_log.txt

echo '# Run testB^gtm8699.m to test $VIEW("STATSHARE") with V[IEW] "STATSHARE":"DEFAULT"'
$ydb_dist/mumps -run testB^gtm8699

$gtm_tst/com/dbcheck.csh >>& dbcreate_log.txt

#### testC ####
echo ''
echo "# Create a single region DB with region DEFAULT"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt

echo '# Disable DB stat sharing'
$MUPIP set -NOSTAT  -reg "DEFAULT" #>>& dbcreate_log.txt

echo '# Run testC^gtm8699.m to test $VIEW("STATSHARE") when DB sharing is disabled'
$ydb_dist/mumps -run testC^gtm8699

$gtm_tst/com/dbcheck.csh >>& dbcreate_log.txt

