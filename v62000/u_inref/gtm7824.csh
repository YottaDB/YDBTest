#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# default to V5 database
setenv gtm_test_mupip_set_version "disable"

$gtm_tst/com/dbcreate.csh mumps 1

# Extend the database to contain 511 blocks.
$MUPIP extend -blocks=411 DEFAULT
$DSE change -f -rec=900

# Do updates that fills up the first 511 blocks causing any more update to result in an extension.
$gtm_exe/mumps -run %XCMD 'for i=1:1:502 s ^x(i)=$j(i,800)'

# Setup white box test cases to cause INTEG to wait immediately after setting up the snapshot structures.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 26
setenv gtm_white_box_test_case_count 1

# Start the INTEG in the background.
# set FASTINTEG = `$gtm_exe/mumps -run chooseamong "" "-fast"`
# echo $FASTINTEG >&! fastinteg_choice.out
($MUPIP integ -online -preserve -r DEFAULT >&! online_integ.out & ; echo $! >! mupip1_pid.log)	>&! background_pid.txt

$gtm_tools/offset.csh node_local gtm_main.c >&! offset.out
setenv hexoffset `$grep -w wbox_test_seq_num offset.out | sed 's/\].*//g;s/.*\[0x//g'`
echo $hexoffset >! hexoffset.out

# Wait for it to have reached a rendezvous point.
$gtm_tst/com/waitforOLIstart.csh

# Setup white box test case to force GT.M to error out during first phase of the commit logic.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 4
setenv gtm_white_box_test_case_count 1

# Do one update that causes an extension.
$gtm_exe/mumps -run %XCMD 'set ^x(503)=$j("",800)'

unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number
unsetenv gtm_white_box_test_case_count

set mupip_pid = `cat mupip1_pid.log`
$gtm_tst/com/wait_for_proc_to_die.csh $mupip_pid 1200 >&! wait_for_OLI_die.out

#
$gtm_tst/com/dbcheck.csh
