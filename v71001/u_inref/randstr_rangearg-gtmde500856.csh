#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
# The performance testing logic in this test case is derived from:
# v70005/u_inref/strcat_efficiency-gtmf135278.csh
# The check for conditionally executing the performance testing logic in this test is from:
# r202/u_inref/bool_expr_sortsafter-ydb1091.csh
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-001_Release_Notes.html#GTM-DE500856)

^%RANDSTR limits the range argument upper limit to the actual number of characters available in the current character set - 256 for M mode and 65,536 for UTF-8 mode. Previously, a missing or defective upper limit caused the routine to perform unproductive processing that could consume unreasonable amounts of time. The workaround was to avoid inappropriate range arguments. (GTM-DE500856)
CAT_EOF
echo ""

setenv ydb_msgprefix "GTM"	# So can run the test under GTM or YDB
# Only run the below perf related stage of the subtest if "perf" executable exists and is the YottaDB
# build is not a DBG or ASAN build (both are slow). Also restrict the test to only be on x86_64 linux.
# And only with GCC builds (not CLANG builds which use up 10% more instructions, greater than the 5% allowance).
# This lets us keep strong limits for performance comparison. That helps us quickly determine if any
# performance regression occurs. Also restrict the test to run only if M-profiling is not turned on by
# the test framework (i.e. gtm_trace_gbl_name env var is not defined) as otherwise a lot more instructions get used.
set perf_missing = `which perf >/dev/null; echo $status`

source $gtm_tst/com/is_libyottadb_asan_enabled.csh      # detect asan build into $gtm_test_libyottadb_asan_enabled
if (! $perf_missing && ! $gtm_test_libyottadb_asan_enabled && ("pro" == "$tst_image") && ("x86_64" == `uname -m`)       \
	&& ("GCC" == $gtm_test_yottadb_compiler) && ! $?gtm_trace_gbl_name) then
	set limit = 150000000
	set testmsg = ( \
		"# Test 1. Defective range argument upper limit, e.g.: '1:1:2**32'" \
		"# Test 2. Missing range argument upper limit, i.e. '1:1'" \
	)

	echo "# Run M routines that call ^%RANDSTR with various range argument upper limits,"
	echo "# then confirm that each routine runs in less than 1.5 million instructions."
	echo "# Previously, these routines would have hung for long periods without issuing any output."
	echo ""
	foreach test ( 1 2 )
		echo "$testmsg[$test]"
		if ($test == 1) then
			set testname = "defectivelimit"
		else
			set testname = "missinglimit"
		endif
		perf stat --log-fd 1 "-x " -e instructions $gtm_dist/mumps -run $testname^gtmde500856 >& perf.out
		set instructions = `tail -1 perf.out`
		if ( "$instructions[1]" > $limit ) echo "FAIL: Test took more than $limit instructions"`false` || continue
		echo "PASS: Took less than $limit instructions"
		echo ""
	end
endif
