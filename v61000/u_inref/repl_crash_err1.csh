#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test verifies REPLINSTDBMATCH is not issued incorrectly
setenv acc_meth "BG" # Before image journaling does not work with MM
# Online rollback does not do backward processing without before image
setenv gtm_test_jnl_nobefore 0
setenv tst_jnl_str "-journal=enable,on,before"
# Online rollback does not process V4 format
setenv gtm_test_mupip_set_version "disable"

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps

$MSR START INST1 INST2

$tst_awk '/PID/{print $2}' SRC_checkhealth_*.outx > src_pid.txt

$gtm_exe/mumps -run replcrasherr

$gtm_tst/com/mupip_rollback.csh "*" >& rollback.out

$MSR REFRESHLINK INST1 INST2
$MSR STOPRCV INST1 INST2
$gtm_tst/com/dbcheck.csh -noshut
