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
GTM-DE376113 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-003_Release_Notes.html#GTM-DE376113)

GT.M correctly defers executing the \$ZTIMEOUT vector when its timeout coincides with an invocation of \$ZINTERRUPT occurring during a long running command. Previously, due a regression introduced in V7.0-002, \$ZTIMEOUT did not execute its vector in this rare case. The workaround was to minimize the chance of using long running commands when \$ZTIMEOUT expiry and \$ZINTERRUPT processing overlap. This was only seen in development and not reported by a customer. (GTM-DE376113)

CAT_EOF
echo

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out


echo '### Overview of gtmde376113 test routine:'
echo '# 1. Sets $ZTIMEOUT to print a digit every 0.01 seconds and reset the timeout, so that approximately 100 ZTIMEOUTs occur in 1 second.'
echo '# 2. Repeats this process for 10 seconds, yielding a total of ~1000 ZTIMEOUTs'
echo '# Expect a PASS message showing that ~1000 ztimeouts occurred, but accept as few as 700, in case fewer occured due to transient system load.'
echo '# Prior to GT.M V7.1-003, much fewer than 1000 digits are output, regardless of system load, signifying that much fewer than 1000'
echo '# ztimeouts occur in the 10 second window. This means that the $ZTIMEOUT stops happening mid-way through the routine in that case.'
echo '# This test case is based on the discussion at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/698#note_2657097388.'
echo
echo '### Start test routine [$gtm_dist/mumps -r gtmde376113]'
set try = 0
while ($try < 7)
	@ try = $try + 1
	($gtm_dist/mumps -r gtmde376113 >&! try${try}-mumps.out & ; echo $! >&! try${try}-mumps.pid) >&! try${try}-mumps-bg.out
	$gtm_tst/com/wait_for_proc_to_die.csh `cat try${try}-mumps.pid`
	grep -q PASS try${try}-mumps.out
	if (0 == $status) then
		break
	endif
end
cat try${try}-mumps.out

$gtm_tst/com/dbcheck.csh >& dbcheck.out
