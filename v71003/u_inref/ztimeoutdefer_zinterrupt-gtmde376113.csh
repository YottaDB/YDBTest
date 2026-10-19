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
echo '# Expect a PASS message showing that the LAST ZTIMEOUT fired in the final part of the 10 second window.'
echo '# Prior to GT.M V7.1-003 the $ZTIMEOUT stops part way through the routine, so the last one fires early. The'
echo '# count of timeouts is not used to decide PASS, because the vector re-arms $ZTIMEOUT itself and so a loaded'
echo '# machine lowers the count with no defect present.'
echo '# This test case is based on the discussion at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/698#note_2657097388.'
echo
echo '### Start test routine [$gtm_dist/mumps -r gtmde376113], once per run below'
echo '# EVERY run must report that its last $ZTIMEOUT fired in the final part of its 10 second window.'
echo '# The defect appears in only some runs of a build that carries it: on V7.1-002, 3 of 10 and later 4 of 10'
echo '# runs stopped early, at 1.4 to 3.8 seconds, while the others ran to 9.1 to 10.0 seconds and looked correct. The'
echo '# earlier version of this subtest stopped at the first run that passed, so a build carrying the defect'
echo '# passed as soon as any one run behaved. Requiring all of the runs below to keep firing makes such a'
echo '# build fail far more often; at 3 bad runs in 10, all 10 runs look clean only 0.7^10 = 3 percent of the time.'
echo '# On a build with the fix all 10 of 10 runs measured had their last $ZTIMEOUT at 9.998 to 10.006'
echo '# seconds, so requiring every run to pass adds no sensitivity to machine load.'
set runs = 10
set fails = 0
set run = 0
while ($run < $runs)
	@ run = $run + 1
	($gtm_dist/mumps -r gtmde376113 >&! run${run}-mumps.out & ; echo $! >&! run${run}-mumps.pid) >&! run${run}-mumps-bg.out
	$gtm_tst/com/wait_for_proc_to_die.csh `cat run${run}-mumps.pid`
	grep -q '^PASS' run${run}-mumps.out
	if (0 != $status) then
		@ fails = $fails + 1
		echo "WRONG : run $run did not keep the timeout firing to the end of its window"
		grep -E '^(PASS|FAIL)' run${run}-mumps.out
	endif
end
if (0 == $fails) then
	echo "PASS : every run kept its last timeout in the final part of the 10 second window"
else
	echo "WRONG : $fails of $runs runs stopped early"
endif

$gtm_tst/com/dbcheck.csh >& dbcheck.out
