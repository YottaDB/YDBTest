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
echo "-------------------------------------------------------------------------------------"
echo "# Test various MUPIP SET JOURNAL scenarios when BEFORE or NOBEFORE is not specified."
echo "-------------------------------------------------------------------------------------"

# Need to unset test_system given setting so that access method can be changed throughout the test
unsetenv acc_meth

# mupip set -acc_meth=MM does not work with V4 databases.
setenv gtm_test_mupip_set_version "disable"

# disable test-system dictated journaling.
setenv gtm_test_jnl NON_SETJNL

# Using separate directories so each case has its own set of files
mkdir dir1; cd dir1

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate1.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate1.out
	exit -1
endif

echo ""
echo "# Test Case 1: Test that previously disallowed commands are now allowed"
echo "# These are commands that were removed from disallow/inref/mupip_cmd_disallow.txt as part of https://gitlab.com/YottaDB/DB/YDBTest/merge_requests/548of https://gitlab.com/YottaDB/DB/YDBTest/merge_requests/548"
echo ""
echo '$ydb_dist/mupip set -reg DEFAULT -journal="on"'
$ydb_dist/mupip set -reg DEFAULT -journal="on"
echo '$ydb_dist/mupip set -reg DEFAULT -journal="enable,on"'
$ydb_dist/mupip set -reg DEFAULT -journal="enable,on"
echo '$ydb_dist/mupip set -reg DEFAULT -journal="enable,on,filename=dummy.mjl"'
$ydb_dist/mupip set -reg DEFAULT -journal="enable,on,filename=dummy.mjl"
echo '$ydb_dist/mupip set -reg DEFAULT -journal="enable,on,allocation=4096"'
$ydb_dist/mupip set -reg DEFAULT -journal="enable,on,allocation=4096"
echo '$ydb_dist/mupip set -reg DEFAULT -journal="enable,on,extension=16"'
$ydb_dist/mupip set -reg DEFAULT -journal="enable,on,extension=16"
echo '$ydb_dist/mupip set -reg DEFAULT -journal="enable,on,buffer_size=2312"'
$ydb_dist/mupip set -reg DEFAULT -journal="enable,on,buffer_size=2312"
echo '$ydb_dist/mupip set -reg DEFAULT -journal="enable,on,alignsize=4096"'
$ydb_dist/mupip set -reg DEFAULT -journal="enable,on,alignsize=4096"
echo '$ydb_dist/mupip set -reg DEFAULT -journal="enable,on,epoch_interval=40"'
$ydb_dist/mupip set -reg DEFAULT -journal="enable,on,epoch_interval=40"
echo '$ydb_dist/mupip set -reg DEFAULT -journal="enable,on,autoswitchlimit=16384"'
$ydb_dist/mupip set -reg DEFAULT -journal="enable,on,autoswitchlimit=16384"

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck1.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck1.out
	exit -1
endif

cd ../
mkdir dir2; cd dir2
setenv acc_meth BG

echo "-----------------------------------------------------------------------------------------------------"
echo "# Test Case 2: Test that MUPIP SET -JOURNAL=ENABLE,ON creates journal file with BEFORE_IMAGE journaling for database with BG access method"
echo "# Create database with BG access method"
$gtm_tst/com/dbcreate.csh mumps -acc_meth=BG >& dbcreate2.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate2.out
	exit -1
endif

echo '$ydb_dist/mupip set -reg DEFAULT -journal="enable,on"'
$ydb_dist/mupip set -reg DEFAULT -journal="enable,on"

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck2.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck2.out
	exit -1
endif

cd ../
mkdir dir3; cd dir3
setenv acc_meth MM

echo "-----------------------------------------------------------------------------------------------------"
echo "# Test Case 3: Test that MUPIP SET -JOURNAL=ENABLE,ON creates journal file with NOBEFORE_IMAGE journaling for database with MM access method"
echo "# Create database with MM access method"
$gtm_tst/com/dbcreate.csh mumps -acc_meth=MM >& dbcreate3.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate3.out
	exit -1
endif

$ydb_dist/mupip set -reg DEFAULT -journal="enable,on"

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck3.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck3.out
	exit -1
endif

cd ../
mkdir dir4; cd dir4
setenv acc_meth BG

echo "-----------------------------------------------------------------------------------------------------"
echo "# Test Case 4: Test that MUPIP SET -REPLICATION=ON creates journal file with BEFORE_IMAGE journaling for database with BG access method"
echo "# Create database with BG access method"
$gtm_tst/com/dbcreate.csh mumps -acc_meth=BG >& dbcreate4.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate4.out
	exit -1
endif

echo '$ydb_dist/mupip set -reg DEFAULT -REPLICATION=ON'
$ydb_dist/mupip set -reg DEFAULT -REPLICATION=ON

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck4.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck4.out
	exit -1
endif

cd ../
mkdir dir5; cd dir5
setenv acc_meth MM

echo "-----------------------------------------------------------------------------------------------------"
echo "# Test Case 5: Test that MUPIP SET -REPLICATION=ON creates journal with NOBEFORE_IMAGE journaling for database with MM access method"
echo "# Create database with MM access method"
$gtm_tst/com/dbcreate.csh mumps -acc_meth=MM >& dbcreate5.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate5.out
	exit -1
endif

echo '$ydb_dist/mupip set -reg DEFAULT -REPLICATION=ON'
$ydb_dist/mupip set -reg DEFAULT -REPLICATION=ON

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck5.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck5.out
	exit -1
endif

cd ../
mkdir dir6; cd dir6
setenv acc_meth MM

echo "-----------------------------------------------------------------------------------------------------"
echo '# Test Case 6: Test that MUPIP SET -ACCESS_METHOD=BG -JOURNAL=ENABLE,ON -reg "*" creates a journal with BEFORE_IMAGE journaling for database with MM access method'
echo "# Create database with MM access method"
$gtm_tst/com/dbcreate.csh mumps -acc_meth=MM >& dbcreate6.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate6.out
	exit -1
endif

echo '$ydb_dist/mupip set -ACCESS_METHOD=BG -JOURNAL="enable,on" -reg "*"'
$ydb_dist/mupip set -ACCESS_METHOD=BG -JOURNAL="enable,on" -reg "*"

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck6.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck6.out
	exit -1
endif

cd ../
mkdir dir7; cd dir7
setenv acc_meth BG

echo "-----------------------------------------------------------------------------------------------------"
echo '# Test Case 7: Test that MUPIP SET -ACCESS_METHOD=MM -JOURNAL=ENABLE,ON -reg "*" creates journal with NOBEFORE_IMAGE journaling for database with BG access method'
echo "# Create database with BG access method"
$gtm_tst/com/dbcreate.csh mumps -acc_meth=BG >& dbcreate7.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate7.out
	exit -1
endif

echo '$ydb_dist/mupip set -ACCESS_METHOD=MM -JOURNAL="enable,on" -reg "*"'
$ydb_dist/mupip set -ACCESS_METHOD=MM -JOURNAL="enable,on" -reg "*"

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck7.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck7.out
	exit -1
endif

cd ../
mkdir dir8; cd dir8
setenv acc_meth MM

echo "-----------------------------------------------------------------------------------------------------"
echo '# Test Case 8: Test that MUPIP SET -ACCESS_METHOD=BG -REPLICATION=ON -reg "*" creates journal with BEFORE_IMAGE journaling for database with MM access method'
echo "# Create database with MM access method"
$gtm_tst/com/dbcreate.csh mumps -acc_meth=MM >& dbcreate8.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate8.out
	exit -1
endif

echo '$ydb_dist/mupip set -ACCESS_METHOD=BG -REPLICATION=ON -reg "*"'
$ydb_dist/mupip set -ACCESS_METHOD=BG -REPLICATION=ON -reg "*"

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck8.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck8.out
	exit -1
endif

cd ../
mkdir dir9; cd dir9
setenv acc_meth BG

echo "-----------------------------------------------------------------------------------------------------"
echo '# Test Case 9: Test that MUPIP SET -ACCESS_METHOD=MM -REPLICATION=ON -reg "*" creates journal with NOBEFORE_IMAGE journaling with BG access method'
echo "# Create database with BG access method"
$gtm_tst/com/dbcreate.csh mumps -acc_meth=BG >& dbcreate9.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate9.out
	exit -1
endif

echo '$ydb_dist/mupip set -ACCESS_METHOD=MM -REPLICATION=ON -reg "*"'
$ydb_dist/mupip set -ACCESS_METHOD=MM -REPLICATION=ON -reg "*"

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck9.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck9.out
	exit -1
endif

cd ../
mkdir dir10; cd dir10
setenv acc_meth MM

echo "-----------------------------------------------------------------------------------------------------"
echo "# Test Case 10: Test that MUPIP SET -ACCESS_METHOD=BG and MUPIP SET -JOURNAL=ENABLE,ON create journal with BEFORE_IMAGE journaling for database with MM access method"
echo "# Create database with MM access method"
$gtm_tst/com/dbcreate.csh mumps -acc_meth=MM >& dbcreate10.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate10.out
	exit -1
endif

echo '$ydb_dist/mupip set -FILE "mumps.dat" -ACCESS_METHOD=BG'
$ydb_dist/mupip set -FILE "mumps.dat" -ACCESS_METHOD=BG
echo '$ydb_dist/mupip set -reg "*" -JOURNAL="enable,on"'
$ydb_dist/mupip set -reg "*" -JOURNAL="enable,on"

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck10.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck10.out
	exit -1
endif

cd ../
mkdir dir11; cd dir11
setenv acc_meth BG

echo "-----------------------------------------------------------------------------------------------------"
echo "# Test Case 10: Test that MUPIP SET -ACCESS_METHOD=MM and MUPIP SET -JOURNAL=ENABLE,ON create journal with NOBEFORE_IMAGE journaling for database with BG access method"
echo "# Create database with BG access method"
$gtm_tst/com/dbcreate.csh mumps -acc_meth=BG >& dbcreate11.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate11.out
	exit -1
endif

echo '$ydb_dist/mupip set -FILE "mumps.dat" -ACCESS_METHOD=MM'
$ydb_dist/mupip set -FILE "mumps.dat" -ACCESS_METHOD=MM
echo '$ydb_dist/mupip set -reg "*" -JOURNAL="enable,on"'
$ydb_dist/mupip set -reg "*" -JOURNAL="enable,on"

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck11.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck11.out
	exit -1
endif

cd ../
mkdir dir12; cd dir12
setenv acc_meth MM

echo "-----------------------------------------------------------------------------------------------------"
echo "# Test Case 12: Test that MUPIP SET -ACCESS_METHOD=BG and MUPIP SET -REPLICATION=ON create journal with BEFORE_IMAGE journaling for database with MM access method"
echo "# Create database with MM access method"
$gtm_tst/com/dbcreate.csh mumps -acc_meth=MM >& dbcreate12.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate12.out
	exit -1
endif

echo '$ydb_dist/mupip set -FILE "mumps.dat" -ACCESS_METHOD=BG'
$ydb_dist/mupip set -FILE "mumps.dat" -ACCESS_METHOD=BG
echo '$ydb_dist/mupip set -reg "*" -REPLICATION=ON'
$ydb_dist/mupip set -reg "*" -REPLICATION=ON

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck12.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck12.out
	exit -1
endif

cd ../
mkdir dir13; cd dir13
setenv acc_meth BG

echo "-----------------------------------------------------------------------------------------------------"
echo "# Test Case 13: Test that MUPIP SET -ACCESS_METHOD=MM and MUPIP SET -REPLICATION=ON create journal with NOBEFORE_IMAGE journaling with BG access method"
echo "# Create database with BG access method"
$gtm_tst/com/dbcreate.csh mumps -acc_meth=BG >& dbcreate13.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate13.out
	exit -1
endif

echo '$ydb_dist/mupip set -FILE "mumps.dat" -ACCESS_METHOD=MM'
$ydb_dist/mupip set -FILE "mumps.dat" -ACCESS_METHOD=MM
echo '$ydb_dist/mupip set -reg "*" -REPLICATION=ON'
$ydb_dist/mupip set -reg "*" -REPLICATION=ON

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck13.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck13.out
	exit -1
endif

cd ../
mkdir dir14; cd dir14
setenv acc_meth BG

echo "-----------------------------------------------------------------------------------------------------"
echo "# Test Case 14: Test that MUPIP SET -JOURNAL=ON creates journal file with BEFORE_IMAGE journaling for database with BG access method"
echo "  even if access method was switched to MM temporarily while journaling was OFF"
echo "# Create database with BG access method"
$gtm_tst/com/dbcreate.csh mumps -acc_meth=BG >& dbcreate14.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate14.out
	exit -1
endif

echo '$ydb_dist/mupip set -journal="enable,on" -reg "*"'
$ydb_dist/mupip set -journal="enable,on" -reg "*"
echo '$ydb_dist/mupip set -journal=off -reg "*"'
$ydb_dist/mupip set -journal=off -reg "*"
echo '$ydb_dist/mupip set -acc=MM -reg "*"'
$ydb_dist/mupip set -acc=MM -reg "*"
echo '$ydb_dist/mupip set -acc=BG -reg "*"'
$ydb_dist/mupip set -acc=BG -reg "*"
echo '$ydb_dist/mupip set -journal=on -reg "*"'
$ydb_dist/mupip set -journal=on -reg "*"

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck14.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck14.out
	exit -1
endif

cd ../
mkdir dir15; cd dir15
setenv acc_meth MM

echo "-----------------------------------------------------------------------------------------------------"
echo "# Test Case 15: Test that MUPIP SET -JOURNAL=ON creates journal file with NOBEFORE_IMAGE journaling for database with MM access method"
echo "  even if access method was switched to BG temporarily while journaling was OFF"
echo "# Create database with MM access method"
$gtm_tst/com/dbcreate.csh mumps -acc_meth=MM >& dbcreate15.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate15.out
	exit -1
endif

echo '$ydb_dist/mupip set -journal="enable,on" -reg "*"'
$ydb_dist/mupip set -journal="enable,on" -reg "*"
echo '$ydb_dist/mupip set -journal=off -reg "*"'
$ydb_dist/mupip set -journal=off -reg "*"
echo '$ydb_dist/mupip set -acc=BG -reg "*"'
$ydb_dist/mupip set -acc=BG -reg "*"
echo '$ydb_dist/mupip set -acc=MM -reg "*"'
$ydb_dist/mupip set -acc=MM -reg "*"
echo '$ydb_dist/mupip set -journal=on -reg "*"'
$ydb_dist/mupip set -journal=on -reg "*"

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck15.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck15.out
	exit -1
endif

cd ../
mkdir dir16; cd dir16
setenv acc_meth BG

echo "-----------------------------------------------------------------------------------------------------"
echo "# Test Case 16: Test that DB File Header State is used to determine current BEFORE_IMAGE or NOBEFORE_IMAGE journaling status."
echo "# Create database with BG access method"
$gtm_tst/com/dbcreate.csh mumps -acc_meth=BG >& dbcreate16.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate16.out
	exit -1
endif

echo "# Turn on Journaling with NOBEFORE set, then turn off Journaling."
echo '$ydb_dist/mupip set -JOURNAL="enable,on,nobefore" -reg "*"'
$ydb_dist/mupip set -JOURNAL="enable,on,nobefore" -reg "*"
echo '$ydb_dist/mupip set -JOURNAL="off" -reg "*"'
$ydb_dist/mupip set -JOURNAL="off" -reg "*"

echo "# Turn on Journaling again, should be NOBEFORE_IMAGE Journaling"
echo '$ydb_dist/mupip set -JOURNAL="on" -reg "*"'
$ydb_dist/mupip set -JOURNAL="on" -reg "*"

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck16.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck16.out
	exit -1
endif

cd ../
mkdir dir17; cd dir17
setenv acc_meth BG

echo "-----------------------------------------------------------------------------------------------------"
echo "# Test Case 17: Test that a MUPIP SET -ACC=BG command that does not change access method does not reset the default journaling type to BEFORE_IMAGE"
echo "# Create database with BG access method"
$gtm_tst/com/dbcreate.csh mumps -acc_meth=BG >& dbcreate16.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate16.out
	exit -1
endif

echo '$ydb_dist/mupip set -journal="enable,on,nobefore" -reg "*"'
$ydb_dist/mupip set -journal="enable,on,nobefore" -reg "*"
echo '$ydb_dist/mupip set -journal=off -reg "*"'
$ydb_dist/mupip set -journal=off -reg "*"
echo '$ydb_dist/mupip set -acc=BG -reg "*"'
$ydb_dist/mupip set -acc=BG -reg "*"
echo '$ydb_dist/mupip set -journal=on -reg "*"'
$ydb_dist/mupip set -journal=on -reg "*"

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck16.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck16.out
	exit -1
endif
