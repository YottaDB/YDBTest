#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

# This subtest test the journal extract and show and behavior without gtm_passwd.

setenv save_gtm_passwd $gtm_passwd
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 22
setenv gtm_test_disable_randomdbtn
$gtm_tst/com/dbcreate.csh mumps 1
echo "Enable journaling"
echo "mupip set -journal=""on,enable,befor"" -reg DEFAULT"
$MUPIP set $tst_jnl_str -reg DEFAULT

setenv gtm_test_dbfill "SLOWFILL"
setenv gtm_test_jobcnt 1
$gtm_tst/com/imptp.csh >>&! imptp.out
sleep 5

echo "---------------------------------------------------------------------------------------------------"
echo "Try extracting journal file while doing GTM updates without gtm_passwd and expect to error out"
echo "---------------------------------------------------------------------------------------------------"
echo "unsetenv gtm_passwd"
unsetenv gtm_passwd
echo "mupip journal -extract -for mumps.mjl"
$MUPIP journal -extract -for mumps.mjl

echo "---------------------------------------------------------------------------------------------------"
echo "Try extracting journal file while doing GTM updates with bad gtm_passwd and expect to error out"
echo "---------------------------------------------------------------------------------------------------"
setenv gtm_passwd `echo "badvalue" | $gtm_dist/plugin/gtmcrypt/maskpass | cut -d " " -f3`
$gtm_tst/com/reset_gpg_agent.csh
echo "mupip journal -extract -for mumps.mjl"
$MUPIP journal -extract -for mumps.mjl

echo "---------------------------------------------------------------------------------------------------"
echo "journal show header with noverify while doing GTM updates without gtm_passwd and expect to work"
echo "---------------------------------------------------------------------------------------------------"
echo "unsetenv gtm_passwd"
unsetenv gtm_passwd
echo "mupip journal -show=header -noverify -forw mumps.mjl"
$MUPIP journal -show=header -noverify -forw mumps.mjl >&! jnlhdr.out
$gtm_tst/com/check_error_exist.csh jnlhdr.out "CRYPTINIT"
$grep "YDB-S-JNLSUCCESS" jnlhdr.out

echo "---------------------------------------------------------------------------------------------------"
echo "journal show header with verify while doing GTM updates without gtm_passwd and expect to error out"
echo "---------------------------------------------------------------------------------------------------"
echo "unsetenv gtm_passwd"
unsetenv gtm_passwd
echo "mupip journal -show=header -verify -forw mumps.mjl"
$MUPIP journal -show=header -verify -forw mumps.mjl

setenv gtm_passwd $save_gtm_passwd
$gtm_tst/com/reset_gpg_agent.csh
$gtm_tst/com/endtp.csh >>&! imptp.out
$gtm_tst/com/dbcheck.csh
