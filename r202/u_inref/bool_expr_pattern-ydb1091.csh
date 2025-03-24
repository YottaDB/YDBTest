#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
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
echo '# Test various aspects of YDB#1091 where y?."1" and y\'?."1" in simple boolean expressions were speeded up'
echo "###########################################################################################################"

echo ""
echo "# ---------------------------------------------------------------------------"
echo '# Test1 : Verify correctness of various y?."1" and y\'?."1" simple boolean expressions'
echo "# ---------------------------------------------------------------------------"
echo "# Run [mumps -run ydb1091pattern] to generate [boolexpr.m] with various simple boolean expressions"
$gtm_dist/mumps -run ydb1091pattern > boolexpr.m
echo "# Run [mumps -run boolexpr] and verify the output of the various boolean expressions against the reference file"
echo '# The output in the reference file was verified as correct by comparing it against the output with $gtm_curpro'
echo '# Using $gtm_curpro would have avoided a huge reference file but I chose not to because the pipeline currently'
echo '# does not have $gtm_curpro available which would make this subtest fail there.'
$gtm_dist/mumps -run boolexpr

echo ""
echo "# ---------------------------------------------------------------------------"
echo "# Test2 : Verify that all generated y?.\"1\" and y'?.\"1\" simple boolean expressions in boolexpr.m get optimized"
echo "# with no OC_BOOLINIT/OC_BOOLFINI/OC_BOOLEXPRSTART/OC_BOOLEXPRFINISH opcodes in the mumps machine listing"
echo "# ---------------------------------------------------------------------------"
echo "# Run [mumps -machine -lis=boolexpr.lis boolexpr.m]"
$gtm_dist/mumps -machine -lis=boolexpr.lis boolexpr.m
set filter = "OC_LINESTART|OC_EXTCALL|OC_LINEFETCH|OC_JMPEQU|OC_STOLIT|OC_LVZWRITE|OC_SVGET|OC_LITC|OC_RET"
echo '# Run [grep -E OC_ boolexpr.lis | grep -vE '$filter' | awk \'{print $NF}\']'
echo '# Expect to see only OC_PATTERN_RETMVAL, OC_NPATTERN_RETMVAL, OC_PATTERN_RETBOOL or OC_NPATTERN_RETBOOL opcodes'
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
	echo '# Test3 : Test the actual number of instructions for a y?."1" and y\'?."1" test case'
	echo "# ---------------------------------------------------------------------------"
	echo "# [limit] variable contains number of instructions (from perf) when tested with the YDB#1091 fixes."
	set limit = (5144301344 5144307466 5024303185 5094307197)
	echo "# The test allows for up to 10% more instructions. And signals failure if it exceeds even that."
	echo "# Note that other \"r202/bool_expr*\" subtests allow for only up to 5% more instructions. But this"
	echo "# subtest has been noticed to show as much as a 6% difference across different x86_64 system processors."
	echo "# Not sure why so we allow for up to 10% in just this subtest."
	# Allow for 10% more than this.
	@ cnt = 1
	foreach cmd ('s x=(y?."1")' 's x=(y\'?."1")' 's:(y?."1") x=1' 's:(y\'?."1") x=1')
		set maxlimit = `$gtm_dist/mumps -run %XCMD 'write '$limit[$cnt]'*1.10\1'`
		@ cnt = $cnt + 1
		set fullcmd = "s y=\$justify(1,10) for i=1:1:10000000 $cmd"
		set instructions = `echo "$fullcmd" | perf stat --log-fd 1 "-x " -e instructions $gtm_dist/mumps -direct`
		if ( "$instructions[3]" == "" ) echo "No instruction count produced by perf: $instructions"`false` || continue
		if ( "$instructions[3]" > $maxlimit ) echo "FAIL: [Actual=$instructions[3]] more than [Maxlimit=$maxlimit] instructions"`false` || continue
		echo "PASS: Test of [$cmd]"
	end
endif
