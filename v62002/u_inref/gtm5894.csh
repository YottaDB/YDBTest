#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv gtm_test_defer_allocate 0

# rec_size = 512; blk_size = 512; alloc = 25; extension = 500
$gtm_tst/com/dbcreate.csh mumps 1 . 512 512 25 . 500

alias dusize '(set du_info = `du -k \!:1` ; @ du_bytes = $du_info[1] * 1024 ; echo $du_bytes)'

echo "# Checking if the database is fully allocated after the database creation"
if (-Z mumps.dat <= `dusize mumps.dat`) then
    echo "TEST-I-PASS database has been fully allocated."
else
    echo "TEST-E-FAIL database was not fully allocated. Check the size of the mumps.dat file."
    exit 1
endif

echo "# Triggering an auto extend and checking if the database is fully allocated"
set syslog_time1 = `date +"%b %e %H:%M:%S"`
$gtm_exe/mumps -run fillglo^gtm5894
$gtm_tst/com/getoper.csh "$syslog_time1" "" syslog1.txt "" "DBFILEXT"

if (-Z mumps.dat <= `dusize mumps.dat`) then
    echo "TEST-I-PASS database has been fully allocated."
else
    echo "TEST-E-FAIL database was not fully allocated. Check the size of the mumps.dat file."
    exit 1
endif

$gtm_tst/com/backup_dbjnl.csh dbbkup1 "*.dat *.mjl*" mv

$GDE change -segment DEFAULT -defer_allocate >& gde_change1.out

echo "# Create mumps.dat with -defer_allocate"
$MUPIP create

if (-Z mumps.dat > `dusize mumps.dat`) then
    echo "TEST-I-PASS The mumps.dat is sparse as expected during database creation with defer_allocate."
else
    # We call this small part of this test PASS if the file system is XFS the default allocation size can
    # be large. We have it as large as 64K. In addition, an XFS feature called dynamic speculative EOF preallocation
    # changes the allocation size based on the free space. The feature is enabled unless a fixed allocation is set.
    # This makes the disk preallocation size unpredictable.
    if (($gtm_test_os_machtype =~ "HOST_LINUX*") && (`df -T $tst_working_dir | & cat` =~ *xfs*)) then
	echo "TEST-I-PASS The mumps.dat is sparse as expected during database creation with defer_allocate."
    else
	echo "TEST-E-FAIL The mumps.dat appears to be fully allocated during database creation with defer_allocate."
	exit 1
    endif
endif

echo "# Fill the database, trigger autoextend"
$gtm_exe/mumps -run fillglo^gtm5894

if (-Z mumps.dat > `dusize mumps.dat`) then
    echo "TEST-I-PASS The mumps.dat is sparse as expected after filling the database with defer_allocate."
else
    echo "TEST-E-FAIL The mumps.dat appears to be fully allocated after filling the database with defer_allocate."
    exit 1
endif

echo "# Extend by 0 blocks should cause an error when defer_allocate is TRUE"
$MUPIP extend -block=0 DEFAULT

$MUPIP set -region DEFAULT -nodefer_allocate
$GDE change -segment DEFAULT -nodefer_allocate >& gde_change2.out

echo "# Fully allocate the database"
$MUPIP extend -block=0 DEFAULT

if (-Z mumps.dat <= `dusize mumps.dat`) then
    echo "TEST-I-PASS database has been fully allocated as expected with nodefer_allocate."
else
    echo "TEST-E-FAIL database was not fully allocated with nodefer_allocate. Check the size of the mumps.dat file."
    exit 1
endif

echo "# Verify the data is correct"

$gtm_exe/mumps -run verifyglo^gtm5894

echo "# Extend by 100 blocks and verfiy the data is still OK"

$MUPIP extend -block=100 DEFAULT

if (-Z mumps.dat <= `dusize mumps.dat`) then
    echo "TEST-I-PASS database has been fully allocated with nodefer_allocate."
else
    echo "TEST-E-FAIL database was not fully allocated with nodefer_allocate. Check the size of the mumps.dat file."
    exit 1
endif

$gtm_exe/mumps -run verifyglo^gtm5894

$gtm_tst/com/backup_dbjnl.csh dbbkup2 "*.dat *.mjl*" mv

$MUPIP create

echo "# Fill the database, trigger autoextend"
$gtm_exe/mumps -run fillglo^gtm5894

if (-Z mumps.dat <= `dusize mumps.dat`) then
    echo "TEST-I-PASS The mumps.dat is fully allocated after filling the database with nodefer_allocate."
else
    echo "TEST-E-FAIL The mumps.dat appears to be sparse after filling the database with nodefer_allocate."
    exit 1
endif

$MUPIP set -region DEFAULT -defer_allocate
$GDE change -segment DEFAULT -defer_allocate >& gde_change3.out

echo "# Extend by 100 blocks and verfiy the data is still OK"

$MUPIP extend -block=100 DEFAULT

if (-Z mumps.dat > `dusize mumps.dat`) then
    echo "TEST-I-PASS database has been sparse with defer_allocate."
else
    echo "TEST-E-FAIL database was fully allocated with defer_allocate. Check the size of the mumps.dat file."
    exit 1
endif

$gtm_exe/mumps -run verifyglo^gtm5894

$gtm_tst/com/dbcheck.csh
