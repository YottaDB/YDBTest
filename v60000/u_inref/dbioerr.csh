#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013 Fidelity Information Services, Inc		#
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
# ============> Test 1 <=============
# Ensures disk I/O errors while writing to the database file (during commit) are handled correctly by wcs_flu by reporting a runtime error.
# For MM, DBIOERR is not applicable, at least in this test's context. This is because, wcs_wtstart (the one that tests dbioerr) doesn't do anything for MM.
setenv gtm_test_jnl "SETJNL"
source $gtm_tst/com/gtm_test_setbgaccess.csh

$gtm_tst/com/dbcreate.csh mumps 1

# set a very small EPOCH interval to trigger wcs_flu invocations during transactions
$MUPIP set -journal=enable,on,before,epoch=1 -reg "*"

# set a longer flush timer interval to ensure wcs_wtstart gets invoked ONLY from wcs_flu (and not from wcs_stale)
$MUPIP set -flush=00:10:00 -reg "*"

# Set white box test case to trigger disk I/O errors in wcs_flu
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 64
setenv gtm_white_box_test_case_count 1		# every invocation of wcs_flu will trigger the white box test case logic

# Do some updates with a sleep of 1 second in-between that will eventually trigger wcs_flu
$gtm_exe/mumps -run %XCMD 'for i=1:1:10  hang 1  set ^a(i)=$j(i,10)' >&! wcs_flu_errs.out

unsetenv gtm_white_box_test_case_enable

# Check for DBIOERR
$gtm_tst/com/check_error_exist.csh wcs_flu_errs.out DBIOERR ENO

$gtm_tst/com/dbcheck.csh

# Copy all artifacts to temporary directory before the next test
$gtm_tst/com/backup_dbjnl.csh test1

# ============> Test 2 <=============
# Ensures disk I/O errors while writing to the database file (at any point, not just during commit) are handled correctly by
# wcs_wtstart by issuing DBIOERR to the operator log

$gtm_tst/com/dbcreate.csh mumps 1

# Set a longer EPOCH interval to avoid wcs_wtstart being invoked during commit time (as that might cause runtime errors).
$MUPIP set -journal=enable,on,before,epoch=300 -reg "*"

set syslog_before = `date +"%b %e %H:%M:%S"` # note down the time to check for error message in syslog
echo $syslog_before >&! syslog_before.txt

# set whitebox test case to trigger disk I/O errors in wcs_wtstart
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 65
setenv gtm_white_box_test_case_count 1		# every invocation of wcs_wtstart will trigger the white box test case logic

# Do some updates with a sleep of 1 second in-between to trigger wcs_wtstart (as part of periodic flush timers)
$gtm_exe/mumps -run %XCMD 'for i=1:1:10  hang 1  set ^a(i)=$j(i,10)' >&! wcs_wtstart_errs.out

echo "Return status from MUMPS is:" $status

unsetenv gtm_white_box_test_case_enable

# Check for DBIOERR
$gtm_tst/com/check_error_exist.csh wcs_wtstart_errs.out DBIOERR ENO YDB-E-NOTALLDBRNDWN YDB-E-GVRUNDOWN

# Check for DBIOERR in the operator log
$gtm_tst/com/getoper.csh "$syslog_before" "" syslog.txt "" DBIOERR

set stat = $status
if (0 == $stat) then
	$gtm_tst/com/check_error_exist.csh syslog.txt "DBIOERR.*`pwd`" | sed 's/^.*YDB-E-/%YDB-E-/g' | sed 's/generated.*//g'
else
	echo "TEST-E-FAILED: DBIOERR not found in the syslog. Please check syslog1.txt for more details"
endif

$gtm_tst/com/dbcheck.csh
