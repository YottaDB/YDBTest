#!/usr/local/bin/tcsh -f
#################################################################
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
# This module is derived from FIS GT.M.
#################################################################

if (-X expect) then
	setenv TERM xterm
	echo "Beginning Job Interrupt and terminal testing"
	$gtm_tst/com/dbcreate.csh mumps
	echo "Now call the expect script"
	# Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
	(expect -d -f $gtm_tst/$tst/u_inref/D9G12002636.exp > expect.out) >& expect.dbg
	if ($status) then
		echo "EXPECT-E-FAIL : expect returned non-zero exit status"
	endif
	perl $gtm_tst/com/expectsanitize.pl expect.out > expect_sanitized.out
	cat expect_sanitized.out
	$gtm_tst/com/dbcheck.csh
	echo "Done..."
else
	echo "No expect in PATH, please install"
endif
