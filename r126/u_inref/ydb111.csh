#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#

# Turn off statshare related env var as it affects test output and is not considered worth the trouble to maintain
# the reference file with SUSPEND/ALLOW macros for STATSHARE and NON_STATSHARE
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

echo '# Test that mupip rundown does not hang indefinitely after abnormal process shutdown'

echo '# Enabling before journalling which is needed to see the failure'
setenv acc_meth "BG"
setenv gtm_test_jnl "SETJNL"
setenv tst_jnl_str '-journal="enable,on,before"'
$gtm_tst/com/dbcreate.csh mumps
echo '# Enabling whitebox test case 145 with count 80'
setenv ydb_white_box_test_case_enable 1
setenv ydb_white_box_test_case_number 145
setenv ydb_white_box_test_case_count 80
$ydb_dist/mumps -run %XCMD 'for i=1:1:80 set ^x=$justify(i,20)'
echo '# Disabling whitebox testcase and doing rundown'
unsetenv ydb_white_box_test_case_enable
$ydb_dist/mupip rundown -reg "*" -override

$gtm_tst/com/dbcheck.csh
