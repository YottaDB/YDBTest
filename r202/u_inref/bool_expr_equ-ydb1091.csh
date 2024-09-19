#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
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
echo '# Test various aspects of YDB#1091 where y=z and y\'=z in simple boolean expressions were speeded up'
echo "###########################################################################################################"

echo ""
echo "# ---------------------------------------------------------------------------"
echo "# Test1 : Verify correctness of various y=z and y'=z simple boolean expressions"
echo "# ---------------------------------------------------------------------------"
echo "# Run [mumps -run ydb1091equ] to generate [boolexpr.m] with various simple boolean expressions"
$gtm_dist/mumps -run ydb1091equ > boolexpr.m
echo "# Run [mumps -run boolexpr] and verify the output of the various boolean expressions against the reference file"
echo '# The output in the reference file was verified as correct by comparing it against the output with $gtm_curpro'
echo '# Using $gtm_curpro would have avoided a huge reference file but I chose not to because the pipeline currently'
echo '# does not have $gtm_curpro available which would make this subtest fail there.'
$gtm_dist/mumps -run boolexpr

# Only run Test2 if Debug build. As mumps -machine -lis only works with Debug builds.
if ("dbg" == "$tst_image") then
	echo ""
	echo "# ---------------------------------------------------------------------------"
	echo "# Test2 : Verify that all generated y=z and y'=z simple boolean expressions in boolexpr.m get optimized"
	echo "# with no OC_BOOLINIT/OC_BOOLFINI/OC_BOOLEXPRSTART/OC_BOOLEXPRFINISH opcodes in the mumps machine listing"
	echo "# ---------------------------------------------------------------------------"
	echo "# Run [mumps -machine -lis=boolexpr.lis boolexpr.m]"
	$gtm_dist/mumps -machine -lis=boolexpr.lis boolexpr.m
	set filter = "OC_LINESTART|OC_EXTCALL|OC_LINEFETCH|OC_JMPEQU|OC_STOLIT|OC_LVZWRITE|OC_SVGET|OC_LITC|OC_RET"
	echo '# Run [grep -E OC_ boolexpr.lis | grep -vE '$filter' | awk \'{print $NF}\']'
	echo '# Expect to see only OC_EQU_RETMVAL, OC_NEQU_RETMVAL, OC_EQU_RETBOOL or OC_NEQU_RETBOOL opcodes'
	echo '# Do not expect to see any OC_BOOL* opcodes (implies optimization did not happen)'
	$grep -E "OC_" boolexpr.lis | $grep -vE $filter | $tst_awk '{print $NF}'
endif

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
	echo '# Test3 : Test the actual number of instructions for a y=z and y\'=z test case'
	echo "# ---------------------------------------------------------------------------"
	echo "# [limit] variable contains number of instructions (from perf) when tested with the YDB#1091 fixes."
	echo "# The test allows for up to 5% more instructions. And signals failure if it exceeds even that."
	set limit = (2988271381 2988272313 2938276984 2988276562)
	# Allow for 5% more than this.
	@ cnt = 1
	foreach cmd ('s x=(y=z)' 's x=(y\'=z)' 's:(y=z) x=1' 's:(y\'=z) x=1')
		set maxlimit = `$gtm_dist/mumps -run %XCMD 'write '$limit[$cnt]'*1.05\1'`
		@ cnt = $cnt + 1
		set fullcmd = "s y=\$justify(1,10),z=\"a\" for i=1:1:10000000 $cmd"
		set instructions = `echo $fullcmd | perf stat --log-fd 1 "-x " -e instructions $gtm_dist/mumps -direct`
		if ( "$instructions[3]" == "" ) echo "No instruction count produced by perf: $instructions"`false` || continue
		if ( "$instructions[3]" > $maxlimit ) echo "FAIL: [Actual=$instructions[3]] more than [Maxlimit=$maxlimit] instructions"`false` || continue
		echo "PASS: Test of [$cmd]"
	end
endif

