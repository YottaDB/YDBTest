#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

# This subtest test the mupip freeze behavior with standalone data base and
# while doing parallel GTM updates without gtm_passwd

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 22
setenv save_gtm_passwd $gtm_passwd
$gtm_tst/com/dbcreate.csh mumps 1

setenv gtm_test_dbfill "SLOWFILL"
setenv gtm_test_jobcnt 1
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep 5

echo "------------------------------------------------------------------------------------------"
echo "Issue mupip freeze while parallel GTM updates with out gtm_passwdand expect error message"
echo "------------------------------------------------------------------------------------------"
echo "unsetenv gtm_passwd"
unsetenv gtm_passwd
echo "mupip freeze -ON DEFAULT"
$MUPIP freeze -ON DEFAULT

echo "------------------------------------------------------------------------------------------"
echo "Issue mupip freeze while parallel GTM updates with bad gtm_passwd and expect error message"
echo "------------------------------------------------------------------------------------------"
setenv gtm_passwd `echo "badvalue" | $gtm_dist/plugin/gtmcrypt/maskpass | cut -d " " -f3`
$gtm_tst/com/reset_gpg_agent.csh
echo "mupip freeze -ON DEFAULT"
$MUPIP freeze -ON DEFAULT

setenv gtm_passwd $save_gtm_passwd
$gtm_tst/com/reset_gpg_agent.csh
$gtm_tst/com/endtp.csh >>&! imptp.out

echo "------------------------------------------------------------------------------------------"
echo "Issue mupip freeze after GTM updates without gtm_passwd and expect to work"
echo "------------------------------------------------------------------------------------------"
echo "unsetenv gtm_passwd"
unsetenv gtm_passwd
echo "mupip freeze -ON DEFAULT"
$MUPIP freeze -ON DEFAULT

echo "------------------------------------------------------------------------------------------"
echo "Issue mupip freeze after GTM updates with bad gtm_passwd and expect to work"
echo "------------------------------------------------------------------------------------------"
setenv gtm_passwd `echo "badvalue" | $gtm_dist/plugin/gtmcrypt/maskpass | cut -d " " -f3`
$gtm_tst/com/reset_gpg_agent.csh
echo "mupip freeze -ON DEFAULT"
$MUPIP freeze -ON DEFAULT

setenv gtm_passwd $save_gtm_passwd
$gtm_tst/com/reset_gpg_agent.csh

# Unfreeze the database since we are about to perform INTEG and it doesn't like frozen databases
$MUPIP freeze -OFF DEFAULT >&! mupip_freeze_off.log

$gtm_tst/com/dbcheck.csh
