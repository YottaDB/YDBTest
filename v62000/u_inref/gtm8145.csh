#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv gtm_test_mupip_set_version "disable"	# Prevent random usage of V4 database as that causes issues with using MM
$gtm_tst/com/dbcreate.csh mumps
setenv TERM vt320
echo "# Running expect (output: expect.outx)"	# expect.outex is not much use as the paging actions of gtmhelp output overwrite
expect $gtm_tst/$tst/u_inref/gtm8145.exp > expect.outx

if ($status) then
    echo "TEST-E-FAIL Expect error; check expect.outx"
else
    $grep -c "OPEN TERMINAL NOPAST NOESCA NOREADS TYPE WIDTH=" foo.txt
    $grep -n "foo.txt OPEN RMS" foo.txt
    $tst_awk 'END{print NR}' foo.txt
endif
$gtm_tst/com/dbcheck.csh
