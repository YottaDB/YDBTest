#!/usr/local/bin/tcsh -f
#################################################################
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
#
$gtm_tst/com/dbcreate.csh mumps >>& create.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat create.out
endif

## Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
(expect -d $gtm_tst/$tst/u_inref/gtm8909.exp > expect.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
mv expect.out expect.outx	# move .out to .outx to avoid -E- from being caught by test framework

perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx
# The output is variable on slow vs fast systems and so filter out just the essential part of it to keep it deterministic.

$grep -v '^$' expect_sanitized.outx
# The output, stripped of all blank lines, is output
# On slower systems, a rare failure occurs because some blank lines are being omitted from the output log.
# The cause of the issue is not clear yet, but these blank lines are unnecessary and are filtered out to
# avoid false failures on slower systems.

$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
endif
