#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo 'When a MUPIP INTRRPT (SIGUSR1) is received by YottaDB while it is in direct mode and the'
echo 'executed code fragment stored in $ZINTERRUPT gets a runtime error (such as LVUNDEF), verify'
echo 'the output contains the ERRWZINTR error and no repeated errors like it was doing before YDB#712'
echo
# Using an expect script because this operates differently when output is to/from a terminal or not
(expect -d $gtm_tst/$tst/u_inref/ydb712.exp > expect.outx) >& xpect.dbg
if ($status) then
	echo "Expect failed"
else
	echo "Expect succeeded"
endif
$echoline
# The below leaves the output file in a readable format for debugging or further validation if needed
echo "Create readable form of output from expect"
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx
$echoline
echo "Output from expect:"
echo
cat expect_sanitized.outx
