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
$gtm_tst/com/dbcreate.csh mumps >>& db_create_log.txt
if ($status) then
	echo "DB Create has failed, Output Below "
	cat db_check_log.txt
endif

echo "# Test that LKE does not fail with sig-11 after <ctrl-Z>"
## Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
(expect -d $gtm_tst/$tst/u_inref/gtm8791.exp > expect.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
mv expect.out expect.outx	# move .out to .outx to avoid -E- from being caught by test framework

perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx
# The output is variable on slow vs fast systems and so filter out just the essential part of it to keep it deterministic.
# We want to ensure that a Ctrl-Z did happen and hence we check the below.
$grep -E "\^Z|Suspended" expect_sanitized.outx

$gtm_tst/com/dbcheck.csh >>& db_check_log.txt
if ($status) then
	echo "DB Check has failed, Output Below "
	cat db_check_log.txt
endif
