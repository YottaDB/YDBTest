#! /usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2010, 2013 Fidelity Information Services, Inc	#
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

echo "Testing D9E02002419"

setenv ydb_test_4g_db_blks 0	# Disable debug-only huge db scheme as this white-box test is sensitive to block layout
				# and the huge HOLE in bitmap block 512 onwards disturbs the assumptions in this test.

# Get a random white box test for interrupted file extension, between 35 and 40, which are the values
# for WBTEST_FILE_EXTEND_INTERRUPT_xxx.
set randwbt = `$gtm_exe/mumps -run rand 6`
@ randwbt = $randwbt + 35
echo "GTM_TEST_DEBUGINFO white box test case " $randwbt

# Get a random number of block to add, between 100 and 10,000 blocks.
set randblocks = `$gtm_exe/mumps -run rand 9901`
@ randblocks = $randblocks + 100
echo "GTM_TEST_DEBUGINFO Number of blocks added : " $randblocks

# Get a random 'read only' mupip journal command.
set mupjnl_ro = ( "-show=all -backward" "-verify -backward" "-extract -backward" )
set mupjnl_ro_cmd = `$gtm_exe/mumps -run rand 3`
@ mupjnl_ro_cmd = $mupjnl_ro_cmd + 1
echo "GTM_TEST_DEBUGINFO mupip journal ro commandd is : " $mupjnl_ro[$mupjnl_ro_cmd]

# Get a random epoch interval, between 5 and 20 seconds, which is a little bit longer than the time we sleep
# before killing mupip extend.
set epoch = `$gtm_exe/mumps -run rand 16`
@ epoch = $epoch + 5
echo "GTM_TEST_DEBUGINFO epoch interval : " $epoch

# Get a random extension count value, between 0 and 65535
set extension = `$gtm_exe/mumps -run rand 65536`
echo "GTM_TEST_DEBUGINFO extension_count : " $extension

# Get a random allocation value, between 10 and 1000
set alloc = `$gtm_exe/mumps -run rand 991`
@ alloc = $alloc + 10
echo "GTM_TEST_DEBUGINFO allocation : " $alloc

# Create database
$gtm_tst/com/dbcreate.csh mumps -extension_count=$extension -allocation=$alloc

# Turn on journaling
$MUPIP set -journal=enable,on,before,epoch_interval=$epoch -reg DEFAULT

# Turn on white box test, randomizing where, in the file extension process, GT.M will wait.
setenv gtm_white_box_test_case_number $randwbt
setenv gtm_white_box_test_case_enable 1

# Extend the database file, and kill the process to have an interrupted database extension.
($MUPIP extend -block=$randblocks DEFAULT >& extend.txt & ; echo $! >! extend_pid.log) >&! bg_extend.out
set pid=`cat extend_pid.log`
sleep 15
$kill9 $pid

# Backup crashed db.  It will be restored before mupip journal recover, otherwise the code that should
# do the file extension may not be called.
mkdir crashed
cp -p mumps.mjl mumps.dat mumps.gld crashed
# Do an INTEG now and save the exit status for later use. Name the output file with outx extension
# as we expect errors as a result of the interrupted extension
# Use -noonline so that we don't see asserts due to ONLINE INTEG checking for total blocks integrity
$MUPIP integ -reg -noonline DEFAULT >&! integ1.outx
set integ_stat = $status

# We can now disable white box testing.
unsetenv gtm_white_box_test_case_number
unsetenv gtm_white_box_test_case_enable

# mupip journal show/verify/extract shouldn't fix the database.  mupip integ should fail.
$MUPIP journal $mupjnl_ro[$mupjnl_ro_cmd] '*' >& mupjnl_ro_output.txt
if ($status != 0) then
	cat mupjnl_ro_output.txt
endif
# Do an INTEG now to ensure the above non-invasive journal command did NOT fix the error. Name the output file
# with outx extension as we expect errors as a result of the interrupted extension
# Use -noonline so that we don't see asserts due to ONLINE INTEG checking for total blocks integrity
$MUPIP integ -reg -noonline DEFAULT >&! integ2.outx
set stat = $status
if ($integ_stat != $stat) then
	echo "INTEG status before ($integ_stat) and after ($stat) the non-invasive command $mupjnl_ro[$mupjnl_ro_cmd] is not same."
	echo "Please check integ1.outx and integ2.outx for more details"
endif

# Recover the database.
cp -p crashed/* .
$MUPIP journal -recover -backward '*'
$gtm_tst/com/dbcheck.csh

