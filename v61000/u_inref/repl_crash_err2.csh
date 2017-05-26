#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test verifies REPLREQROLLBACK is issued properly
setenv acc_meth "BG" # Before image journaling does not work with MM
# Online rollback does not do backward processing without before image
setenv gtm_test_jnl_nobefore 0
setenv tst_jnl_str "-journal=enable,on,before"
# Online rollback does not process V4 format
setenv gtm_test_mupip_set_version "disable"

$gtm_tst/com/dbcreate.csh mumps 8 125 1000

setenv gtm_test_jobcnt 10
setenv gtm_test_crash 1

echo "# GTM Process starts in background..."
$gtm_tst/com/imptp.csh >>&! imptp.out

# Waiting 2000 updates to happen.
$gtm_exe/mumps -run %XCMD 'for  quit:2000<=$get(^cntloop(0),0)  hang 0.5'

# This test does kill -9 followed by a MUPIP RUNDOWN. A kill -9 could hit the running GT.M process while it
# is in the middle of executing wcs_wtstart. This could potentially leave some dirty buffers hanging in the shared
# memory. So, set the white box test case to avoid asserts in wcs_flu.c
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 29

# PRIMARY SIDE (A) CRASH
$gtm_tst/com/primary_crash.csh

# RECEIVER SIDE (B) CRASH
$sec_shell "$sec_getenv; $gtm_tst/com/receiver_crash.csh"

echo "# Start a rollback"
setenv gtm_white_box_test_case_number 100
$MUPIP journal -rollback -backward "*" >& rollback1.out		# BYPASSOK("-rollback")
	# mupip_rollback.csh is not used above because the test relies on the "Killed" message printed inside
	# white-box code to show up in rollback1.out which it does not if the rollback goes through a .csh script.
unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number

# Check for errors
$MUPIP replic -source -shut -time=0 >& replic_shut.out1
$gtm_tst/com/check_error_exist.csh replic_shut.out1 "NOJNLPOOL"

$MUPIP replic -source -shut -time=0 >& replic_shut.out2
$gtm_tst/com/check_error_exist.csh replic_shut.out2 "REPLREQROLLBACK"

$MUPIP replic -source -start -passive -log=passive_source.log -buf=$tst_buffsize -instsecondary=INSTA >& replic_start.out1
$gtm_tst/com/check_error_exist.csh replic_start.out1 "REPLREQROLLBACK"

echo "# Do a healthy rollback"
$gtm_tst/com/mupip_rollback.csh "*" >& rollback2.out
$sec_shell "$sec_getenv ; cd $SEC_SIDE; $gtm_tst/com/mupip_rollback.csh '*' >& rollback2.out"

$gtm_tst/com/dbcheck_filter.csh -noshut
