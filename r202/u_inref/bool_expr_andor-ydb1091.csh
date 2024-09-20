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
	echo "# ---------------------------------------------------------------------------"
	echo '# Test performance of =, < etc. in boolean expressions with AND or OR'
	echo '# This is an automated test of https://gitlab.com/YottaDB/DB/YDB/-/issues/1091#note_2122238799'
	echo "# ---------------------------------------------------------------------------"
	echo "# [$tst/inref/bool_expr_andor_mcmds_perf.txt] contains perf numbers when tested with YDB#1091."
	echo "# The test allows for up to 5% more instructions. And signals failure if it exceeds even that."
	cp $gtm_tst/$tst/inref/bool_expr_andor_mcmds.txt perfcmds.csh
	cp perfcmds.csh perfcmds.txt
	sed -i 's/^/echo \'/;s/$/\' | perf stat -x" " -e instructions $gtm_dist\/mumps -direct > \/dev\/null/;' perfcmds.csh
	source perfcmds.csh >& perfcmds.out
	$tst_awk '{printf "%.f\n", $1/1000000;}' perfcmds.out > perfcmds.actual
	sed -i 's/^set .*000 //;s/ | .*//;s/s //;s/ x=1//;' perfcmds.txt
	paste $gtm_tst/$tst/inref/bool_expr_andor_mcmds_perf.txt perfcmds.actual perfcmds.txt > awk.input
	$tst_awk 	\
		'{												\
			if ($2 > ($1 * 1.05))									\
			{											\
				printf "FAIL : Command [%s] : MaxAllowed = [%s] Actual = [%s] instructions\n",	\
					$3, $1 * 1.05, $2;							\
			} else											\
				printf "PASS : Performance test of [%s]\n", $3;					\
		}' awk.input
endif

