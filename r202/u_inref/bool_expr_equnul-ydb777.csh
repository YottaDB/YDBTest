#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set backslash_quote	# needed for backslash usages in various places below

echo "###########################################################################################################"
echo '# Test various aspects of YDB#777 where s="" and s\'="" in simple boolean expressions were speeded up'
echo "###########################################################################################################"

echo ""
echo "# ---------------------------------------------------------------------------"
echo "# Test1 : Verify correctness of various s="" and s'="" simple boolean expressions"
echo "# ---------------------------------------------------------------------------"
echo "# Run [mumps -run ydb777] to generate [boolexpr.m] with various simple boolean expressions"
echo "# Run [mumps -run boolexpr] and verify the output of the various boolean expressions against the reference file"
echo '# The output in the reference file was verified as correct by comparing it against the output with $gtm_curpro'
echo '# Using $gtm_curpro would have avoided a huge reference file but I chose not to because the pipeline currently'
echo '# does not have $gtm_curpro available which would make this subtest fail there.'
$gtm_dist/mumps -run ydb777 > boolexpr.m
$gtm_dist/mumps -run boolexpr

echo ""
echo "# ---------------------------------------------------------------------------"
echo "# Test2 : Verify that all generated s="" and s'="" simple boolean expressions in boolexpr.m get optimized"
echo "# with no OC_BOOLINIT/OC_BOOLFINI/OC_BOOLEXPRSTART/OC_BOOLEXPRFINISH opcodes in the mumps machine listing"
echo "# ---------------------------------------------------------------------------"
echo "# Run [mumps -machine -lis=boolexpr.lis boolexpr.m]"
$gtm_dist/mumps -machine -lis=boolexpr.lis boolexpr.m
set filter = "OC_LINESTART|OC_EXTCALL|OC_LINEFETCH|OC_JMPEQU|OC_STOLIT|OC_LVZWRITE|OC_SVGET|OC_LITC|OC_RET"
echo '# Run [grep -E OC_ boolexpr.lis | grep -vE '$filter' | awk \'{print $NF}\']'
echo '# Expect to see only OC_EQUNUL_RETMVAL, OC_NEQUNUL_RETMVAL, OC_EQUNUL_RETBOOL or OC_NEQUNUL_RETBOOL opcodes'
echo '# Do not expect to see any OC_BOOL* opcodes (implies optimization did not happen)'
$grep -E "OC_" boolexpr.lis | $grep -vE $filter | $tst_awk '{print $NF}'

# Only run the below perf related stage of the subtest if "perf" executable exists and is the YottaDB
# build is not a DBG or ASAN build (both are slow). Also restrict the test to only be on x86_64 linux.
# And only with GCC builds (not CLANG builds which use up 10% more instructions, greater than the 5% allowance).
# This lets us keep strong limits for performance comparison. That helps us quickly determine if any
# performance regression occurs. Also restrict the test to run only if M-profiling is not turned on by
# the test framework (i.e. gtm_trace_gbl_name env var is not defined) as otherwise a lot more instructions get used.
set perf_missing = `which perf >/dev/null; echo $status`
source $gtm_tst/com/is_libyottadb_asan_enabled.csh	# detect asan build into $gtm_test_libyottadb_asan_enabled
if (! $perf_missing && ! $gtm_test_libyottadb_asan_enabled && ("pro" == "$tst_image") && ("x86_64" == `uname -m`)	\
		&& ("GCC" == $gtm_test_yottadb_compiler) && ! $?gtm_trace_gbl_name) then
	echo ""
	echo "# ---------------------------------------------------------------------------"
	echo '# Test3 : Test the actual number of instructions for a s="" and s\'="" test case'
	echo "# ---------------------------------------------------------------------------"
	echo "# This is a test of https://gitlab.com/YottaDB/DB/YDB/-/issues/777#note_2008124130"
	echo "# [limit] variable contains number of instructions (from perf) when tested with the YDB#777 fixes."
	echo "# The test allows for up to 5% more instructions. And signals failure if it exceeds even that."
	set limit = (3184000000 2734000000 2734000000 2663000000 2713000000)
	# Allow for 5% more than this.
	@ cnt = 1
	foreach cmd ('s x=$zlength(s)' 's x=(s="")' 's x=(s\'="")' 's:(s="") x=1' 's:(s\'="") x=1')
		set maxlimit = `$gtm_dist/mumps -run %XCMD 'write '$limit[$cnt]'*1.05\1'`
		@ cnt = $cnt + 1
		set fullcmd = "s s=\$justify(1,1000000) for i=1:1:10000000 $cmd"
		set instructions = `echo $fullcmd | $gtm_tst/com/perfstat.csh $gtm_dist/mumps -direct`
		if ( "$instructions[3]" == "" ) echo "No instruction count produced by perf: $instructions"`false` || continue
		if ( "$instructions[3]" > $maxlimit ) echo "FAIL: [Actual=$instructions[3]] more than [Maxlimit=$maxlimit] instructions"`false` || continue
		echo "PASS: Test of [$cmd]"
	end
endif
