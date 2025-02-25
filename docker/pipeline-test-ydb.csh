#!/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
pushd $gtm_tst
set test_list=`echo basic sudo r1* r2* v7*`
echo "test_list: $test_list"
popd

# Choose 3 tests randomly
set random_test_list=`shuf -n3 -e $test_list`

# Grab subtests
foreach test ($random_test_list)
	unsetenv subtest_list_non_replic subtest_list_common subtest_list_replic
	grep "setenv subtest_list_" $gtm_tst/$test/instream.csh > instream_setenvs
	source instream_setenvs
	rm instream_setenvs

	# Choose subtests at random
	set subtest_list_to_randomize_nonreplic="$subtest_list_non_replic $subtest_list_common"
	set subtest_list_to_randomize_replic="$subtest_list_common $subtest_list_replic"

	# Remove subtests that don't run in Docker today
	# r120 fails in ydbdist (process id issue)
	if ($test == "r120") set subtest_list_to_randomize_nonreplic=`echo $subtest_list_to_randomize_nonreplic:s/ydbdist//`
	# r122 fails in tprestart (log related)
	if ($test == "r122") set subtest_list_to_randomize_nonreplic=`echo $subtest_list_to_randomize_nonreplic:s/tprestart//`
	# r136 fails in gtm8863a (v V63011_R134 is not installed)
	if ($test == "r136") then
		set subtest_list_to_randomize_nonreplic=`echo $subtest_list_to_randomize_nonreplic:s/gtm8863a//`
	endif
	# v70000 fails in ydb531_v6to7 (imptp invocation)
	if ($test == "v70000") set subtest_list_to_randomize_nonreplic=`echo $subtest_list_to_randomize_nonreplic:s/ydb531_v6tov7//`

	# Choose 5 non-replic tests at random
	set random_nonreplic_subtest_list=`shuf -n5 -e $subtest_list_to_randomize_nonreplic`
	# Choose 1 replic test at random
	set random_replic_subtest_list=`shuf -n1 -e $subtest_list_to_randomize_replic`
	set random_nonreplic_subtest_list_with_commas=`echo "$random_nonreplic_subtest_list" | tr ' ' ','`
	set random_replic_subtest_list_with_commas=`echo "$random_replic_subtest_list" | tr ' ' ','`

	# if we have tests, run them async, saving results in /tmp/test-testname.txt
	# Note that we use "fg", because if we use "bg", the shell does not know that there are child jobs to "wait" for.
	# using fg with & gives us what we want: run multiple tests concurrently and wait for all of them to finish
	if ( $random_nonreplic_subtest_list_with_commas != "" ) then
		/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -env gtm_ipv4_only=1 -stdout 0 -fg -t $test -st $random_nonreplic_subtest_list_with_commas >>& /tmp/test-${test}.txt &
	endif
	if ( $random_replic_subtest_list_with_commas != "" ) then
		/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -env gtm_ipv4_only=1 -stdout 0 -fg -t $test -st $random_replic_subtest_list_with_commas -replic >>& /tmp/test-${test}.txt &
	endif
end

# Wait till all tests are finished
jobs
wait

# Status of the script. 1 if any test failed
set test_status = 0

# Go through test output directories
set tstdirs = `grep -h "Test Output Directory   ::" /tmp/test-* | awk -F":: " '{print $2}'`
foreach tstdir ($tstdirs)
	# Output report, and see if it failed
	# Various looks in report.txt do a loop even though all our invocations will cause a report.txt with a single line
	# This is because report.txt could potentially in the future contain multiple lines
	cat $tstdir/report.txt
	foreach invoke_status (`awk '{print $NF}' $tstdir/report.txt`)
		if ($invoke_status == 'FAILED') set test_status = 1
	end

	# For each test in the report, print outstream.log, and if any of the tests failed, print out the diff
	# Same algorithm as com/submit_test.csh
	foreach invoke_name (`awk '{print $2}' $tstdir/report.txt`)
		set tst_general_dir = $tstdir/$invoke_name
		cat $tst_general_dir/outstream.log
		foreach file (`awk '/^FAIL from / {print $6}' $tst_general_dir/outstream.log`)
			set failedtestname = `echo $file | awk -F "/" '{print $1}'`
			echo "# Diff of $failedtestname follows"
			cat $tst_general_dir/$file
		end
		if (-f $tst_general_dir/diff.log && ! -z $tst_general_dir/diff.log) then
			echo "# diff.log contents follow"
			cat $tst_general_dir/diff.log
		endif
	end
	echo
end

exit $test_status
