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

setenv TERM vt320
echo "# Running expect (output: expect.outx)"
expect $gtm_tst/$tst/u_inref/gtm8003.exp > expect.outx

if ($status) then
    echo "TEST-E-FAIL Expect error; check expect.outx"
else
    $grep -c CTRL_C expect.outx
    $grep -c CTRAP expect.outx
endif

