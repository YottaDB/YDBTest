#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#
echo '# New r128/V63006C subtest to test that mupip trigger -select prints a newline (just a newline) after being ran interactively'

$gtm_tst/com/dbcreate.csh mumps

echo '# Running expect script'
(expect -d $gtm_tst/$tst/u_inref/v63006C.exp > expect.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
mv expect.out expect.outx	# move .out to .outx to avoid -E- from being caught by test framework
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx
echo '# expect output:'
cat expect_sanitized.outx
echo

$gtm_tst/com/dbcheck.csh
