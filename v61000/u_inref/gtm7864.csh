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

setenv acc_meth "BG" # Before image journaling does not work with MM
# Online rollback does not do backward processing without before image
setenv gtm_test_jnl_nobefore 0
setenv tst_jnl_str "-journal=enable,on,before"
# Online rollback does not process V4 format
setenv gtm_test_mupip_set_version "disable"

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps
$MSR START INST1 INST2

sed -n 's/.*pid \[\([0-9]*\)\].*/\1/p' SRC_checkhealth_*.outx > src_pid.txt
echo "# Do one update"
$gtm_exe/mumps -run %XCMD 'set ^x=1 zsy "set pid=`cat src_pid.txt`; $kill9 $pid"'
$MSR REFRESHLINK INST1 INST2
echo "# Rollback"
# This should not cause REPLINSTDBMATCH error. If it does, it will be caught by the test framework
$gtm_tst/com/mupip_rollback.csh "*" >& rollback.out
$MSR STOP INST2
$gtm_tst/com/dbcheck.csh -noshut
