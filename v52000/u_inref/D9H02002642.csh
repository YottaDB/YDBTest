#!/usr/local/bin/tcsh
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
#
# D9H02-002642 PROFILE screen function keys do not work with GT.M V5.2 on AIX/Solaris/HPUX
#

setenv TERM xterm
cat $gtm_tst/$tst/u_inref/D9H02002642.exp | sed 's,$gtm_dist,'$gtm_dist',g' > D9H02002642.exp
# Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
(expect -d -f D9H02002642.exp > expect.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
perl $gtm_tst/com/expectsanitize.pl expect.out > expect_sanitized.out
cat expect_sanitized.out
