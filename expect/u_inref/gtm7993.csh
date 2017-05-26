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

# Use $define_term to get terminal emulator. Otherwise, randomize between xterm and vt220
if ($?define_term) then
    setenv TERM $define_term
else
    setenv TERM `$gtm_exe/mumps -run %XCMD 'write $select($random(2)=1:"xterm",1:"vt220"),!'`
endif
echo "setenv define_term $TERM" >> settings.csh

set kcubval = "`infocmp | sed -n 's/.*kcub1=\([^,]*\).*/\1/p'`"
if ('\EOD' == $kcubval) then
    setenv alternate 1
else
    setenv alternate 0
endif

echo "# Running expect (output: expect.out)"
expect $gtm_tst/$tst/inref/gtm7993.exp > expect.out

if ($status) then
    echo "TEST-E-FAIL Expect error check expect.out"
else
    echo "TEST-I-PASS"
endif
