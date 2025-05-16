#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
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
YDB#1145 - Test https://gitlab.com/YottaDB/DB/YDB/-/issues/1145#draft-release-note
********************************************************************************************

The M command VIEW "STP_GCOL_NOSORT":1 signals future garbage collections to happen without sorting
and VIEW "STP_GCOL_NOSORT":0 reverts back to garbage collections with sorting. Avoiding sorting will
likely improve garbage collection runtimes (~ 50%) but could result in increased memory needs depending
on the application. \$VIEW("SPSIZESORT") returns a comma-separated list of 2 integers which indicate
the memory usage (in bytes) of the stringpool if one used the unsorted approach and the sorted approach
respectively. If the application finds these 2 values to be close enough to each other (the sorted value
will never be more than the unsorted value), it might benefit from the reduced runtimes by switching to
the unsorted approach (see #1145 (comment 2507097811) for examples). The env var ydb_stp_gcol_nosort
can also be set to 0 or 1 (or any positive integer value) to choose the sorted or unsorted approach
respectively by non-M (and M) applications. The env var initializes the approach at process startup
and can be overridden by later VIEW "STP_GCOL_NOSORT" commands. The \$VIEW("STP_GCOL_NOSORT") intrinsic
function returns a value of 0 if garbage collections use the sorted approach and 1 otherwise. Sorted
garbage collections are the default if neither the env var nor VIEW commands are specified. Previously,
garbage collections always happened with the sorted approach and there was no unsorted approach choice.

CAT_EOF

echo

unsetenv ydb_stp_gcol_nosort	# unset this env var since this test explicitly sets it later

echo '# Test that Default value of $VIEW("STP_GCOL_NOSORT") is 0. Expect output of 0 below'
$gtm_dist/mumps -run %XCMD 'write $VIEW("STP_GCOL_NOSORT"),!'
echo

echo '# ----------------------------------------------------------------------------------------'
echo '# Test that VIEW "STP_GCOL_NOSORT":N treats positive values as 1 and all other values as 0'
echo '# ----------------------------------------------------------------------------------------'
foreach value (0 1 2 100 -1 -2 -100)
	echo "## Testing [N=$value]. Expect output of 1 if N is positive and 0 otherwise"
	$gtm_dist/mumps -run %XCMD 'VIEW "STP_GCOL_NOSORT":'$value'  write $VIEW("STP_GCOL_NOSORT"),!'
end

# Test of https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2318#note_2531350800
echo '## Testing [N="a"]. Expect output of 0 if N is non-numeric'
$gtm_dist/mumps -run %XCMD 'VIEW "STP_GCOL_NOSORT":"a"  write $VIEW("STP_GCOL_NOSORT"),!'

echo

echo '# -------------------------------------------------------------------------------------'
echo '# Test that ydb_stp_gcol_nosort=N treats positive values as 1 and all other values as 0'
echo '# -------------------------------------------------------------------------------------'
foreach value (0 1 2 100 -1 -2 -100)
	echo "## Testing [ydb_stp_gcol_nosort=$value]. Expect output of 1 if ydb_stp_gcol_nosort is positive and 0 otherwise"
	setenv ydb_stp_gcol_nosort $value
	$gtm_dist/mumps -run %XCMD 'write $VIEW("STP_GCOL_NOSORT"),!'
end
unsetenv ydb_stp_gcol_nosort
echo

foreach viewkwrd ("S" "SP" "SPS" "SPSI" "SPSIZ")
	echo '# Testing [$VIEW("'$viewkwrd'")]. Expect a VIEWAMBIG error.'
	$gtm_dist/mumps -run %XCMD 'write $VIEW("'$viewkwrd'"),!'
	echo
end

foreach viewkwrd ("SPSIZE" "SPSIZES" "SPSIZESO" "SPSIZESOR" "SPSIZESORT")
	echo '# Testing [$VIEW("'$viewkwrd'")]. Expect NO VIEWAMBIG error.'
	$gtm_dist/mumps -run %XCMD 'write $VIEW("'$viewkwrd'"),!'
	echo
end

echo "## Test that substring is accepted as VIEW parameter as long as it is unambiguous."
echo "## See https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2318#note_2531350804 for more details."
foreach viewkwrd ("B" "BA" "BAD" "BADC" "BADCH" "BADCHA" "BADCHAR")
	echo '# Testing [$VIEW("'$viewkwrd'")]. Should not generate a VIEWAMBIG error.'
	$gtm_dist/mumps -run %XCMD 'write $VIEW("'$viewkwrd'"),!'
	echo
end

echo '## Test that VIEW "STP_GCOL_NOSORT" with no subparameters issues error'
echo '# Run [VIEW "STP_GCOL_NOSORT"]. Expect VIEWARGCNT error.'
$gtm_dist/mumps -run %XCMD 'VIEW "STP_GCOL_NOSORT"'
echo

echo '# Test that VIEW "STP_GCOL_NOSORT" with too many subparameters issues error'
echo '# Run [VIEW "STP_GCOL_NOSORT":1:2]. Expect VIEWARGCNT error.'
$gtm_dist/mumps -run %XCMD 'VIEW "STP_GCOL_NOSORT":1:2'
echo

echo '# Test $VIEW("SPSIZESORT") when there is 0% memory sharing across local variable nodes'
echo '# This is example 1 of https://gitlab.com/YottaDB/DB/YDB/-/issues/1145#note_2507097811'
echo '# We expect the unsorted stringpool memory usage (1st number below) to be almost the same as the sorted (2nd number below)'
$gtm_dist/mumps -run spSizeSortUnshared^stpgcolydb1145
echo

echo '# Test $VIEW("SPSIZESORT") when there is 100% memory sharing across local variable nodes'
echo '# This is example 2 of https://gitlab.com/YottaDB/DB/YDB/-/issues/1145#note_2507097811'
echo '# We expect the unsorted stringpool memory usage (1st number below) to be LOT greater than the sorted (2nd number below)'
$gtm_dist/mumps -run spSizeSortShared^stpgcolydb1145
echo

echo '# Print stringpool memory usage using $VIEW("SPSIZE")'
echo '# For 2 workloads, 0% memory sharing and 100% memory sharing across local variable nodes.'
echo '# And for values of ydb_stp_gcol_nosort=0 and 1'
foreach label (Shared Unshared)
	foreach value (0 1)
		setenv ydb_stp_gcol_nosort $value
		$gtm_dist/mumps -run %XCMD 'do stpgcol'$label'^stpgcolydb1145' >& stpgcol.$label.$value
	end
end
echo '# We expect stpgcol.Shared.0 (shared lvns with ydb_stp_gcol_nosort=0) to need only 1Kb of stringpool'
echo '# We expect stpgcol.Shared.1 (shared lvns with ydb_stp_gcol_nosort=1) to need 100Mb of stringpool'
echo '# We expect stpgcol.Unshared.0 (unshared lvns with ydb_stp_gcol_nosort=0) to need 100Mb of stringpool'
echo '# We expect stpgcol.Unshared.1 (unshared lvns with ydb_stp_gcol_nosort=1) to need 100Mb of stringpool'
foreach file (stpgcol.*)
	set value = `head -1 $file`
	echo "$file $value" | $tst_awk '{printf "%19s : %9d\n", $1, $2}'
end
unsetenv ydb_stp_gcol_nosort
echo

# Only run the below perf related stage of the subtest if "perf" executable exists and is the YottaDB
# build is not a DBG or ASAN build (both are slow). Also restrict the test to only be on x86_64 linux.
# And only with GCC builds (not CLANG builds which use up 10% more instructions, greater than the 5% allowance).
# This lets us keep strong limits for performance comparison. That helps us quickly determine if any
# performance regression occurs. Also restrict the test to run only if M-profiling is not turned on by
# the test framework (i.e. gtm_trace_gbl_name env var is not defined) as otherwise a lot more instructions get used.
set perf_missing = `which perf >/dev/null; echo $status`
source $gtm_tst/com/is_libyottadb_asan_enabled.csh     # detect asan build into $gtm_test_libyottadb_asan_enabled
if (! $perf_missing && ! $gtm_test_libyottadb_asan_enabled && ("pro" == "$tst_image") && ("x86_64" == `uname -m`)      \
		&& ("GCC" == $gtm_test_yottadb_compiler) && ! $?gtm_trace_gbl_name) then
	echo '# Test that VIEW "STP_GCOL_NOSORT":1 is better in runtime when there is a lot of lvn sharing'
	echo '# This is an implementation of Test 2 in https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1668#note_2445424537'
	echo '# We measure the total instructions for ydb_stp_gcol_nosort=0 and ydb_stp_gcol_nosort=1'
	echo '# We expect the =1 instructions to be at least 5% less than the =0 instructions.'
	echo '# If so we issue a PASS. Otherwise we issue FAIL.'
	foreach value (0 1)
		setenv ydb_stp_gcol_nosort $value
		perf stat --log-fd 1 "-x " -e instructions $gtm_dist/mumps -run gctest2^stpgcolydb1145 >& perf.gctest2.$value
		set instructions$value = `head -1 perf.gctest2.$value | $tst_awk '{print $1}'`
	end
	$gtm_dist/mumps -run gctest2verify^stpgcolydb1145 $instructions0 $instructions1
	echo
endif
