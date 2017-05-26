#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# D9C10-000234 - Check $QLENGTH() and $QSUBSCRIPT() handling of $[Z]CHAR() representations of non-graphic characters
echo Starting D9C10002234
setenv D9C10002234_reset_jnl $gtm_test_jnl
# turn off journaling as it doesn't really add anything to this test and it avoids block size - align size conflicts
setenv gtm_test_jnl NON_SETJNL
$gtm_tst/com/dbcreate.csh mumps 1 255 16368 16384
#
# Do test in UTF8 mode (if applicable) and M mode
#
if ( "TRUE" == $gtm_test_unicode_support ) then
	$switch_chset "UTF-8"
	$gtm_exe/mumps -run D9C10002234
	$gtm_tst/com/dbcheck.csh -extract mumps
	mkdir utf8
	mv *.o utf8
	cp mumps.dat utf8
endif
$switch_chset "M"
$gtm_exe/mumps -run D9C10002234
$gtm_tst/com/dbcheck.csh -extract mumps
setenv gtm_test_jnl $D9C10002234_reset_jnl
unsetenv D9C10002234_reset_jnl
echo Ending D9C10002234
