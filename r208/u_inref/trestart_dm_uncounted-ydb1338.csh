#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "#----------------------------------------------------------------------------------------------------#"
echo '# [YDB#1338] TRESTART after a TPQUIT or BREAK in Direct Mode, a TSTART and an argumentless NEW issues #'
echo '# TRESTNEW and TRESTLOC, and without the NEW issues TRESTNOT and TRESTLOC                            #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# A TSTART in Direct Mode uses the frame under the Direct Mode frame as its restart frame. When Direct'
echo '# Mode was entered by a BREAK in $ZTRAP, that is the $ZTRAP frame, which is not a counted frame. A'
echo '# restart cannot resume in that frame, and an argumentless NEW puts its new symbol table below it, where'
echo '# a restart cannot undo it. TRESTART now issues TRESTNEW and TRESTLOC, before it unwinds anything, if a'
echo '# TSTART is such a TSTART and an argumentless NEW followed it, and TRESTNOT and TRESTLOC, also before it'
echo '# unwinds anything, if the outermost TSTART is such a TSTART with no NEW after it.'
echo '# A QUIT with an argument that issues TPQUIT in Direct Mode leaves Direct Mode running in such a frame.'
echo '# Direct Mode prompts and blank lines are removed from the output below. Each check prints PASS or FAIL.'
echo

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows"
	cat dbcreate.out
	exit 1
endif
cp $gtm_tst/$tst/inref/ydb1338.m .
foreach stage (1 2 3 4 5 6 7 8 10 11 12)
	cp $gtm_tst/$tst/inref/ydb1338_stage$stage.inp stage$stage.inp
end

echo '# Stage 1 : Direct Mode, TSTART and QUIT 1 (TPQUIT), then TSTART (d) and an argumentless NEW, then TRESTART'
echo '# Before the fix : GTMASSERT2 in tp_unwind.c (curr_symval == tp_pointer->sym)'
echo '# With the fix   : expect TPQUIT, then TRESTNEW and TRESTLOC, with $TLEVEL still 2'
echo '# Input :'
cat stage1.inp
echo '# Command : $gtm_dist/mumps -direct < stage1.inp'
$gtm_dist/mumps -direct < stage1.inp |& grep -v -e '^YDB>$' -e '^$'
echo

echo '# Stage 2 : a routine divides by zero with $ZTRAP="break", then in Direct Mode TSTART (d) and an argumentless'
echo '#           NEW, then TRESTART'
echo '# Before the fix : the same result'
echo '# With the fix   : expect DIVZERO, then TRESTNEW and TRESTLOC, with $TLEVEL still 1, and TROLLBACK works'
echo '# Input :'
cat stage2.inp
echo '# Command : $gtm_dist/mumps -run ztrap^ydb1338 < stage2.inp'
$gtm_dist/mumps -run ztrap^ydb1338 < stage2.inp |& grep -v -e '^YDB>$' -e '^$'
echo

echo '# Stage 3 : as stage 2, but with no NEW'
echo '# Before the fix : the TRESTART never completed (bounded here by "timeout 60")'
echo '# With the fix   : expect DIVZERO, then TRESTNOT and TRESTLOC, with $TLEVEL still 1 and d unchanged'
echo '# Input :'
cat stage3.inp
echo '# Command : timeout 60 $gtm_dist/mumps -run ztrap^ydb1338 < stage3.inp'
timeout 60 $gtm_dist/mumps -run ztrap^ydb1338 < stage3.inp |& grep -v -e '^YDB>$' -e '^$'
echo

echo '# Stage 4 : as stage 1, but with an argumentless QUIT, which is allowed in Direct Mode'
echo '# Before the fix : the same result'
echo '# With the fix   : expect TRESTNOT and TRESTLOC, as the first TSTART is not restartable, with $TLEVEL 1'
echo '# Input :'
cat stage4.inp
echo '# Command : $gtm_dist/mumps -direct < stage4.inp'
$gtm_dist/mumps -direct < stage4.inp |& grep -v -e '^YDB>$' -e '^$'
echo

echo '# Stage 5 : as stage 1, but NEW d instead of an argumentless NEW'
echo '# Before the fix : the same result'
echo '# With the fix   : expect TPQUIT, then TRESTNOT and TRESTLOC, as the first TSTART is not restartable, with $TLEVEL 1'
echo '# Input :'
cat stage5.inp
echo '# Command : $gtm_dist/mumps -direct < stage5.inp'
$gtm_dist/mumps -direct < stage5.inp |& grep -v -e '^YDB>$' -e '^$'
echo

echo '# Stage 6 : Direct Mode, TSTART (a), QUIT 1 (TPQUIT), then TSTART (d) with no NEW, then TRESTART'
echo '# Before the fix : the same result'
echo '# With the fix   : expect TPQUIT, then the transaction to restart from the first TSTART, whose restart frame is'
echo '#                  counted, with a restored'
echo '# Input :'
cat stage6.inp
echo '# Command : $gtm_dist/mumps -direct < stage6.inp'
$gtm_dist/mumps -direct < stage6.inp |& grep -v -e '^YDB>$' -e '^$'
echo

echo '# Stage 7 : Direct Mode with no $ZTRAP frame, TSTART (d), an argumentless NEW and TRESTART on one line'
echo '# Before the fix : the same result'
echo '# With the fix   : expect the transaction to restart once, with d restored'
echo '# Input :'
cat stage7.inp
echo '# Command : $gtm_dist/mumps -direct < stage7.inp'
$gtm_dist/mumps -direct < stage7.inp |& grep -v -e '^YDB>$' -e '^$'
echo

echo '# Stage 8 : a BREAK in a routine (a counted frame under Direct Mode), then in Direct Mode TSTART (d), an'
echo '#           argumentless NEW and TRESTART'
echo '# Before the fix : the same result'
echo '# With the fix   : expect the transaction to restart once, resuming the routine after the BREAK, with d restored'
echo '# Input :'
cat stage8.inp
echo '# Command : $gtm_dist/mumps -run brk^ydb1338 < stage8.inp'
$gtm_dist/mumps -run brk^ydb1338 < stage8.inp |& grep -v -e '^YDB>$' -e '^$'
echo

echo '# Stage 9 : TSTART (d), an argumentless NEW and TRESTART in a routine (no Direct Mode)'
echo '# Before the fix : the same result'
echo '# With the fix   : expect the transaction to restart twice, with d restored each time'
echo '# Command : $gtm_dist/mumps -run rtn^ydb1338'
$gtm_dist/mumps -run rtn^ydb1338
echo

echo '# Stage 10 : Direct Mode, TSTART (a), QUIT 1 (TPQUIT), then TSTART (d) and a DO of a routine that does an'
echo '#            argumentless NEW and a TRESTART'
echo '# Before the fix : the same result'
echo '# With the fix   : expect the transaction to restart from the first TSTART, as the NEW is in a counted frame that'
echo '#                  the restart unwinds, with a and d restored'
echo '# Input :'
cat stage10.inp
echo '# Command : $gtm_dist/mumps -direct < stage10.inp'
$gtm_dist/mumps -direct < stage10.inp |& grep -v -e '^YDB>$' -e '^$'
echo

echo '# Stage 11 : a BREAK in Direct Mode, then at the prompt that the BREAK starts, TSTART (d) with no NEW, then TRESTART'
echo '# Before the fix : TPQUIT twice, as the restart resumes at the end of the break line, and d restored'
echo '# With the fix   : expect TRESTNOT and TRESTLOC, as the restart cannot resume at the TSTART, with $TLEVEL still 1'
echo '#                  and d unchanged'
echo '# Input :'
cat stage11.inp
echo '# Command : $gtm_dist/mumps -direct < stage11.inp'
$gtm_dist/mumps -direct < stage11.inp |& grep -v -e '^YDB>$' -e '^$'
echo

echo '# Stage 12 : a routine does a TSTART, then divides by zero with $ZTRAP="break", then in Direct Mode TSTART (d) and'
echo '#            an argumentless NEW, then TRESTART'
echo '# Before the fix : GTMASSERT2, as only the outermost TSTART, which the NEW does not affect, was checked'
echo '# With the fix   : expect DIVZERO, then TRESTNEW and TRESTLOC, with $TLEVEL still 2, and TROLLBACK works. TRESTLOC'
echo '#                  reports the outermost TSTART in the routine (ztrapo+3) as the transaction start, not the inner'
echo '#                  TSTART at the prompt'
echo '# Input :'
cat stage12.inp
echo '# Command : $gtm_dist/mumps -run ztrapo^ydb1338 < stage12.inp'
$gtm_dist/mumps -run ztrapo^ydb1338 < stage12.inp |& grep -v -e '^YDB>$' -e '^$'
echo

echo '# Stage 13 : as stage 3, but with Direct Mode entered by a BREAK in a ZBREAK action'
echo '# Before the fix : ERRWZBRK with TPQUIT, as the restart resumes in the ZBREAK action frame, and d restored'
echo '# With the fix   : expect TRESTNOT and TRESTLOC, with $TLEVEL still 1 and d unchanged'
echo '# Input : as stage 3'
echo '# Command : timeout 60 $gtm_dist/mumps -run zbrk^ydb1338 < stage3.inp'
timeout 60 $gtm_dist/mumps -run zbrk^ydb1338 < stage3.inp |& grep -v -e '^YDB>$' -e '^$'
echo

echo '# Stage 14 : as stage 3, but with Direct Mode entered by a BREAK in a ZSTEP action'
echo '# Before the fix : ERRWEXC with TPQUIT, as the restart resumes in the ZSTEP action frame, and d restored'
echo '# With the fix   : expect TRESTNOT and TRESTLOC, with $TLEVEL still 1 and d unchanged'
echo '# Input : as stage 3'
echo '# Command : timeout 60 $gtm_dist/mumps -run zstp^ydb1338 < stage3.inp'
timeout 60 $gtm_dist/mumps -run zstp^ydb1338 < stage3.inp |& grep -v -e '^YDB>$' -e '^$'
echo

echo '# Stage 15 : as stage 3, but with Direct Mode entered by a BREAK in a device EXCEPTION action (a READ past the end of a file)'
echo '# Before the fix : the TRESTART never completed (bounded here by "timeout 60")'
echo '# With the fix   : expect TRESTNOT and TRESTLOC, with $TLEVEL still 1 and d unchanged'
echo '# Input : as stage 3'
echo '# Command : timeout 60 $gtm_dist/mumps -run devex^ydb1338 < stage3.inp'
timeout 60 $gtm_dist/mumps -run devex^ydb1338 < stage3.inp |& grep -v -e '^YDB>$' -e '^$'
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows"
	cat dbcheck.out
endif
echo "# Done"
