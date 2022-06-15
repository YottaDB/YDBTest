#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2019-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv gtm_test_mupip_set_version "disable"	# Prevent random usage of V4 database as that causes issues with using MM
$gtm_tst/com/dbcreate.csh mumps
setenv TERM ansi
echo "# Running expect (output: expect.outx)"
# Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
(expect -d $gtm_tst/$tst/u_inref/gtm8145.exp > expect.outx) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status. Check expect.outx and expect.dbg"
else
	$grep -c "OPEN TERMINAL NOPAST NOESCA NOREADONLY TYPE WIDTH=" foo.txt
	$grep -n "foo.txt OPEN RMS" foo.txt
	$tst_awk 'END{print NR}' foo.txt
endif
$gtm_tst/com/dbcheck.csh
