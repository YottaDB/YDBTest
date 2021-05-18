#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                     #
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
(expect -d $gtm_tst/$tst/inref/gtm8232.exp > expect.out) >& expect.dbg

if ($status) then
	echo "TEST-E-FAIL Expect error check expect.out"
else
	echo "TEST-I-PASS"
endif

# In rare cases, it is possible the mupip reorg process is interrupted by the Ctrl-C (inside gtm8232.exp above)
# in which case it would issue a sequence of "%YDB-I-REORGCTRLY" and "%YDB-E-MUNOFINISH" messages which would show
# up in "expect.out". The MUNOFINISH message would get caught by the test framework because of the "-E-" severity
# and cause a test failure. So filter that out. Note that we need to redirect output to a .logx (not .log) file to avoid
# test framework from catching a potential TEST-E-ERRORNOTSEEN message from the check_error_exist.csh script.
$gtm_tst/com/check_error_exist.csh expect.out "%YDB-E-MUNOFINISH" >& munofinish.logx

# The below leaves the output file in a readable format for debugging or further validation if needed
# Create readable form of output from expect
perl $gtm_tst/com/expectsanitize.pl expect.out > expect_sanitized.out
echo "# Verify that exit command did get echoed in the terminal after [mupip reorg] and [more] returned back to the shell"
echo '# Count number of lines in expect.out containing the string "NEXT_COMMexit". We expect a value of 1.'
grep -c "NEXT_COMMexit" expect_sanitized.out

$gtm_tst/com/dbcheck.csh
