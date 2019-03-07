#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2012, 2013 Fidelity Information Services, Inc	#
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
# Test the generated snapshot file difference between online fast integrity check and online normal integrity check
setenv gtm_test_mupip_set_version "V5"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 26
setenv gtm_white_box_test_case_count 1
source $gtm_tst/com/switch_gtm_version.csh $tst_ver "dbg"
#key size:64, record size:1000, block size:2048
$gtm_tst/com/dbcreate.csh mumps 1 64 1000 2048

echo "Step1: Generate snapshot file for normal integ"
$echoline

$GTM <<EOF
for i=1:1:1000 set ^x(i)=i
EOF
echo "# Start the online integ while the background updaters are active"
($MUPIP integ -online -preserve -r "*" &; echo $! >! norm_oli.pid) >& norm_oli.out
set norm_pid = `cat norm_oli.pid`
$gtm_tst/com/waitforOLIstart.csh

echo "start database update"
$GTM <<EOF
for i=1:1:1000 set ^x(i)=i+1
EOF

echo "# Wait for background online integ to complete"
$gtm_tst/com/wait_for_proc_to_die.csh $norm_pid 120 >&! wait_for_OLI_die.out
if ($status) then
	echo "# TEST-E-TIMEOUT waiting for online integ to complete. $norm_pid did not exit even after 120 seconds of wait."
	echo "# Exiting the test now."
	exit
endif

$gtm_tst/com/dbcheck.csh

echo "Step2: Generate snapshot file for fast integ"
$echoline

rm mumps.dat
$gtm_tst/com/dbcreate.csh mumps 1 64 1000 2048
$GTM <<EOF
for i=1:1:1000 set ^x(i)=i
EOF
($MUPIP integ -online -fast -preserve -r DEFAULT  & ; echo $! >! fast_oli.pid ) >& fast_oli.out
set fast_pid=`cat fast_oli.pid`

$gtm_tst/com/waitforOLIstart.csh

echo "start database update"
$GTM <<EOF
for i=1:1:1000 set ^x(i)=i+1
EOF

echo "# Wait for background online integ to complete"
$gtm_tst/com/wait_for_proc_to_die.csh $fast_pid 120
if ($status) then
	echo "# TEST-E-TIMEOUT waiting for online integ to complete. $fast_pid did not exit even after 120 seconds of wait."
	echo "# Exiting the test now."
	exit
endif

setenv gtm_white_box_test_case_enable 0

set file_fast=`ls -lrt ydb_snapshot*|$tst_awk 'NR==2{print $9}'`
set file_norm=`ls -lrt ydb_snapshot*|$tst_awk 'NR==1{print $9}'`

@ size_fast=`du -s $file_fast|$tst_awk '{print $1}'|sed 's/[A-Za-z]*//g'`
@ size_norm=`du -s $file_norm|$tst_awk '{print $1}'|sed 's/[A-Za-z]*//g'`

if ($size_fast < $size_norm) then
	echo "Correct: Fast integ results in smaller snapshot file"
else
	echo "Error : Fast integ snapshot file is not smaller than normal integ snapshot"
	echo "size of   fast integ snapshot, $file_fast (from du -s output) : $size_fast"
	echo "size of normal integ snapshot, $file_norm (from du -s output) : $size_norm"
	set bkupdir = "../testfiles/fast_integ_snapshot_bkup"
	mkdir $bkupdir ; mv $file_fast $file_norm $bkupdir/  # prevent compression by framework to preserve the sparseness of the files
	ln -s $bkupdir/* .
endif

$gtm_tst/com/dbcheck.csh
