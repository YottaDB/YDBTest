#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-DE534846 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-002_Release_Notes.html#GTM-DE534846)

\$ZTIMEOUT presents the time remaining value to microsecond precision; previously it only showed time with precision in milliseconds or less. (GTM-DE534846)

CAT_EOF
echo

# Create a database for the `do ^incretrap` call in $ETRAP in the test routine,
# which may execute if a YDB-W-ZTIMEOUT occurs.
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out

echo '# Test $ZTIMEOUT shows time remaining to microsecond resolution'
echo '# Also test YDB#1151 : $ZTIMEOUT returns correct millisecond/microsecond value'
echo '# Run [gtmde534846.m] to:'
echo '# 1. Set $ZTIMEOUT to 0.1 seconds'
echo '# 2. Hang for 0.045678 seconds'
echo '# 3. ZWRITE the new value of $ZTIMEOUT'
echo '# Expect the resulting value of $ZTIMEOUT to be less than 0.1 minus 0.45678 = 0.054322 seconds.'
echo '# Test case derived from discussion threads at:'
echo '# 1. https://gitlab.com/YottaDB/DB/YDBTest/-/issues/682#note_2515828547'
echo '# 2. https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2345#note_2551769584'
# The test may fail inadvertently due to transient system load issues. In that case, retry the test up to 3 times to avoid false test failures.
set try = 0
while ($try < 3)
	@ try = $try + 1
	set outfile = "try${try}.outx"
	$gtm_dist/mumps -r gtmde534846 >&! $outfile
	grep -q FAIL $outfile
	if ($status > 0) then
		break
	endif
end
cat $outfile

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
