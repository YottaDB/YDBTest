#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 125

$gtm_tst/com/dbcreate.csh mumps 1 125 10000
echo "# Write 3 globals in to database"
$gtm_exe/mumps -run %XCMD 'for i=1:1:3 kill val set $piece(val,i,10000)="" set ^x(i)=val'
echo "# Extract in zwr format. The white box test waits for 10 seconds to for foreground job to kill ^x(2)"
echo "$MUPIP extract -format=zwr ext.zwr" >> $PWD/bg_mupip_extract.csh
(source $PWD/bg_mupip_extract.csh >& mupip_extract.out & ; echo $! >& bgextr.pid) >& bg_mupip_extract.out
$gtm_exe/mumps -run %XCMD 'kill ^x(2)'
echo "# Wait for background extract to finish"
set extract_pid = `cat bgextr.pid`
$gtm_tst/com/wait_for_proc_to_die.csh $extract_pid
$tail -2 ext.zwr
mv mumps.dat mumps.dat.ext
$gtm_tst/com/dbcreate.csh mumps 1 125 10000
$MUPIP load ext.zwr >>& mupip_load.out
echo "# Due to the white box test case, after loading the extract file ^x(2) shouldn't exist in the database"
$gtm_exe/mumps -run %XCMD 'write ^x(2)'

unset gtm_white_box_test_case_enable
unset gtm_white_box_test_case_number
$gtm_tst/com/dbcheck.csh
