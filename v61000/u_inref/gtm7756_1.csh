#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv gtm_test_jnl NON_SETJNL
setenv test_encryption NON_ENCRYPT	# Since -acc_meth=MM is passed to dbcreate
unsetenv acc_meth
# We need database extension to be 1 and access_method to be MM.
$gtm_tst/com/dbcreate.csh mumps 1 -extension=1 -acc_meth=MM -block_size=1024
$gtm_exe/mumps -run %XCMD 'do update^gtm7756'
@ updcnt = `$gtm_exe/mumps -run %XCMD 'write $order(^x(""),-1)'`
$MUPIP set -acc=BG -reg "*"
$MUPIP integ -reg "*" >&! integ1.out
$gtm_exe/mumps -run %XCMD 'for i=1:1:$order(^x(""),-1) kill ^x(i)'
$MUPIP integ -reg "*" >&! integ2.out
$MUPIP reorg -truncate >&! truncate.out
# The magic number 1985 below is determined only by experimentations.
# With above data base configuration, only with and above 1985 updates,
# reorg -truncate can free any blocks. Until then it should issue
# YDB-I-MUTRUNCNOSPACE error. verify that below.
if ($updcnt < 1985) then
	set string="MUTRUNCNOSPACE"
else
	set string="Truncated region"

endif
$grep "$string" truncate.out >&! grep.outx
if (0 != $status) then
	echo "TEST-E-FAIL: updates count = $updcnt"
endif
$MUPIP integ -reg "*" >&! integ2.out
$gtm_tst/com/dbcheck.csh
