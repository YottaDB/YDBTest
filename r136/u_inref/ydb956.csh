#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '----------------------------------------------------------------------------'
echo '# Test 1 : Test that VIEW "GBLDIRLOAD" reloads gld in current process'
echo '----------------------------------------------------------------------------'

echo "## Create 1-region gld file (1reg.gld) using dbcreate.csh"
$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate1.out
mv mumps.gld 1reg.gld

# Remove database files as we are going to recreate them in the next step
rm -f *.dat

echo "## Create 2-region gld file (2reg.gld) using dbcreate.csh"
$gtm_tst/com/dbcreate.csh mumps 2 >& dbcreate2.out
mv mumps.gld 2reg.gld

echo "## Restore 1-region gld file as mumps.gld"
cp 1reg.gld mumps.gld

echo "## Keep the 2-region database files (mumps.dat and a.dat) created by dbcreate.csh above as is"

$ydb_dist/yottadb -run test1^ydb956

$gtm_tst/com/dbcheck.csh

echo '----------------------------------------------------------------------------------------'
echo '# Test 2 : Test that VIEW "GBLDIRLOAD":GLD with an empty GLD works like SET $ZGBLDIR=""'
echo '----------------------------------------------------------------------------------------'

$ydb_dist/yottadb -run test2^ydb956

echo '-----------------------------------------------------------------------------------------------------------------'
echo '# Test 3 : Test that VIEW "GBLDIRLOAD":GLD with an invalid GLD issues GDINVALID error and $ZGBLDIR is unaffected'
echo '-----------------------------------------------------------------------------------------------------------------'

$ydb_dist/yottadb -run test3^ydb956

