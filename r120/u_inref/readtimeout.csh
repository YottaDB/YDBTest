#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv TERM xterm
echo "# Running expect with readtimeout.exp (unfiltered output: expect.out) : Expecting ZWRITE output following timed READ"
setenv gtm_prompt "GTM>" # needed by expect script to look for GTM> prompt. We use this instead of YDB> to be able to run
			 # this test against GT.M V63002 (which does not know about gtm_prompt but instead uses a prompt of GTM>
# Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
(expect -d $gtm_tst/$tst/u_inref/readtimeout.exp > expect.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
perl $gtm_tst/com/expectsanitize.pl expect.out > expect_sanitized.out
$grep -E '^GTM|^\$TEST|^x|^y' expect_sanitized.out
