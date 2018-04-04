#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "# Enable WHITE BOX TESTING"
# Since we are intentionally introducing a YDB-E-JNLCNTRL error,
# use this white box test case to avoid an assert failure in jnl_write_attempt.c.
# This white box test case does not induce this error it just prevents asserts.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 16

set syslog_before = `date +"%b %e %H:%M:%S"`

setenv gtm_test_dbfill "IMPTP"
setenv gtm_test_jobcnt 1
# Journaling is enabled below. To avoid reference file issues, disable randomly enabling journaling by dbcreate
setenv gtm_test_jnl NON_SETJNL

$gtm_tst/com/dbcreate.csh mumps 1 255 1000 1024 500 128 500

$MUPIP set $tst_jnl_str -reg "*" >&! jnl_on.out

echo "# Do some updates in background"
$gtm_tst/com/imptp.csh >&! imptp.out

sleep 10

$GTM << GTM_EOF
set var="AA"
write "Do some deep updates into journal file",!
for i=1:1:2500 set glo="^"_var_i s @glo=\$j(i,100)
write "Switch to journal file",!
zsystem "$MUPIP set $tst_jnl_str -reg ""*"" >&! jnl_on2.out"
VIEW "JNLFLUSH"
VIEW "JNLWAIT"
h
GTM_EOF
$gtm_tst/com/endtp.csh >>&! imptp.out
set syslog_after = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_before" "$syslog_after" syslog.txt
$gtm_tst/com/check_error_exist.csh syslog.txt "YDB-E-JNLCNTRL, Journal control unsynchronized" >>& Test.logx
if ($status) then
	echo "SUBTEST PASS"
else
	echo "SUBTEST FAIL"
	echo "Verify the error in Test.logx"
endif

$gtm_tst/com/dbcheck.csh
