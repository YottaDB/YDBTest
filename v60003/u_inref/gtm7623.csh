#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-7623: Give DBFILERR instead of GVxxxFAIL 'qqqq' when dsk_read returns -1
#
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run %XCMD 'set ^x=1'
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 94	# WBTEST_PREAD_SYSCALL_FAIL
$gtm_exe/mumps -run %XCMD 'set %=^x'
unsetenv gtm_white_box_test_case_enable
$gtm_tst/com/dbcheck.csh
