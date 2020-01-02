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

echo 'Test that $VIEW("REGION","^*") returns the name of the region mapped to by the `*` namespace'

echo "# Test 1-region case where '*' is mapped to DEFAULT region"
$gtm_tst/com/dbcreate.csh mumps 1
$ydb_dist/mumps -run ydb513
$gtm_tst/com/dbcheck.csh

echo "#----------------------------------------------------------------------------------------------"
echo "# Test 2-region case where '*' is mapped to DEFAULT region"
$gtm_tst/com/dbcreate.csh mumps 2
$ydb_dist/mumps -run ydb513
$gtm_tst/com/dbcheck.csh

echo "#----------------------------------------------------------------------------------------------"
echo "# Test 2-region case where '*' is mapped to AREG region"
$gtm_tst/com/dbcreate.csh mumps 2
$ydb_dist/mumps -run GDE change -name '*' -region=AREG
$ydb_dist/mumps -run ydb513
$gtm_tst/com/dbcheck.csh

echo "#----------------------------------------------------------------------------------------------"
echo "# Test 4-region case where '*' is mapped to DEFAULT region"
$gtm_tst/com/dbcreate.csh mumps 4
$ydb_dist/mumps -run ydb513
$gtm_tst/com/dbcheck.csh

echo "#----------------------------------------------------------------------------------------------"
echo "# Test 4-region case where '*' is mapped to AREG region"
$gtm_tst/com/dbcreate.csh mumps 4
$ydb_dist/mumps -run GDE change -name '*' -region=AREG
$ydb_dist/mumps -run ydb513
$gtm_tst/com/dbcheck.csh

echo "#----------------------------------------------------------------------------------------------"
echo "# Test 4-region case where '*' is mapped to BREG region"
$gtm_tst/com/dbcreate.csh mumps 4
$ydb_dist/mumps -run GDE change -name '*' -region=BREG
$ydb_dist/mumps -run ydb513
$gtm_tst/com/dbcheck.csh

echo "#----------------------------------------------------------------------------------------------"
echo "# Test 4-region case where '*' is mapped to CREG region"
$gtm_tst/com/dbcreate.csh mumps 4
$ydb_dist/mumps -run GDE change -name '*' -region=CREG
$ydb_dist/mumps -run ydb513
$gtm_tst/com/dbcheck.csh

echo "#----------------------------------------------------------------------------------------------"
echo "# Test 4-region case where '*' is mapped to CREG region (and LOCAL LOCKS is mapped to BREG region)"
$gtm_tst/com/dbcreate.csh mumps 4
$ydb_dist/mumps -run GDE change -name '*' -region=CREG
$ydb_dist/mumps -run GDE add -name 'dummy' -region=DEFAULT
$ydb_dist/mumps -run GDE locks -region=BREG
$ydb_dist/mumps -run ydb513
$gtm_tst/com/dbcheck.csh

echo "#----------------------------------------------------------------------------------------------"
echo "# Test 4-region case where '*' is mapped to BREG region (and LOCAL LOCKS is mapped to CREG region)"
$gtm_tst/com/dbcreate.csh mumps 4
$ydb_dist/mumps -run GDE change -name '*' -region=BREG
$ydb_dist/mumps -run GDE add -name 'dummy' -region=DEFAULT
$ydb_dist/mumps -run GDE locks -region=CREG
$ydb_dist/mumps -run ydb513
$gtm_tst/com/dbcheck.csh

echo "#----------------------------------------------------------------------------------------------"
echo "# Test 4-region case where '*' is mapped to BREG region, LOCAL LOCKS is mapped to CREG region AND z* is mapped to DEFAULT"
$gtm_tst/com/dbcreate.csh mumps 4
$ydb_dist/mumps -run GDE change -name '*' -region=BREG
$ydb_dist/mumps -run GDE add -name 'z*' -region=DEFAULT
$ydb_dist/mumps -run GDE locks -region=CREG
$ydb_dist/mumps -run ydb513
$gtm_tst/com/dbcheck.csh

