#!/usr/local/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

echo '# This test runs an expect script that runs the following $ztimeout command that produces a GTMASSERT2 failure in'
echo '# upstream versions V6.3-006 to V6.3-009 but produces a ERRWZTIMEOUT error message from V6.3-010 onwards if run from'
echo '# a direct mode prompt in a terminal session. This affected every $ztimeout command where the code executed after'
echo '# the timeout (the "ztimeout vector") results in a runtime error. Due to YDB#712, this did not produce an assert'
echo '# failure in YottaDB versions r1.26 through r1.30. Due to the fix for YDB#712, YottaDB now produces the expected'
echo '# YDB-E-ERRWZTIMEOUT message.'
echo '# The specific $ztimeout command run by the expect script is set $ztimeout="1:write c,!" which produces a'
echo '# runtime error because the local variable c is not set.'

$echoline
(expect -d $gtm_tst/$tst/u_inref/gtm9178.exp > expect.outx) >& xpect.dbg
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
