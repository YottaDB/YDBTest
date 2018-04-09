#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test that READ X:TIMEOUT works correctly if TIMEOUT is a fraction with more than 3 decimal digits

setenv TERM xterm
echo '# Expecting ZWRITE output of x and y to be "" after timeouts from timed READ of 1.234 and 1.2345 seconds'
echo '# With YottaDB r110 and GTM V63002, the timed READ of 1.2345 seconds would not timeout thus causing y to not be "" below'
# Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
(expect -d $gtm_tst/$tst/u_inref/readtimeout.exp > expect.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
perl $gtm_tst/com/expectsanitize.pl expect.out > expect_sanitized.out
$grep -E '^YDB|^\$TEST|^x|^y' expect_sanitized.out
