#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps
$gtm_exe/mumps -run %XCMD 'for i=1:1:1000 set @("^a"_i)=1'

setenv TERM xterm
echo "# Running expect (output: expect.out)"
expect $gtm_tst/$tst/inref/gtm8232.exp > expect.out

if ($status) then
    echo "TEST-E-FAIL Expect error check expect.out"
else
    echo "TEST-I-PASS"
endif
$gtm_tst/com/dbcheck.csh
