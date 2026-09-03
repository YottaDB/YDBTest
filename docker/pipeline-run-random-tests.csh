#!/bin/tcsh
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
# Run a few randomly chosen tests. Invoked by docker/pipeline-test-ydb.csh when the YDB branch under
# test has no matching YDBTest MR (and hence no list of changed tests to run).
#
# This is a script of its own, rather than part of pipeline-test-ydb.csh, so that a YDBTest MR branch
# checked out by pipeline-test-ydb.csh can change what runs here: pipeline-test-ydb.csh is running at
# that point and so keeps executing the version it started with, but this script is not read until it
# is exec'ed, which happens after the checkout.

# Note that some echo commands below include only a space since the GitLab CI
# will not emit newlines unless they are preceded by a printable character.
# So, include a space in the echos that are meant to generate newlines to create the
# desired effect.

pushd $gtm_tst >& /dev/null
echo -n "## Get the full test list: "
set test_list=`echo basic sudo r1* r2* v7*`
echo $test_list
popd >& /dev/null

echo -n "# Choose 3 tests randomly: "
set random_test_list=`shuf -n3 -e $test_list`
echo $random_test_list

# Grab subtests
foreach test ($random_test_list)
	echo " "
	echo "### Run randomly chosen test: $test"
	unsetenv subtest_list_non_replic subtest_list_common subtest_list_replic
	grep "setenv subtest_list_" $gtm_tst/$test/instream.csh > instream_setenvs
	source instream_setenvs
	rm instream_setenvs

	set subtest_list_to_randomize_nonreplic="$subtest_list_non_replic $subtest_list_common"
	set subtest_list_to_randomize_replic="$subtest_list_common $subtest_list_replic"

	set random_nonreplic_subtest_list=`shuf -n5 -e $subtest_list_to_randomize_nonreplic`
	set random_nonreplic_subtest_list_with_commas=`echo "$random_nonreplic_subtest_list" | tr ' ' ','`
	echo -n "# For $test non-replic, choose 5 random subtests: "
	echo $random_nonreplic_subtest_list

	echo -n "# For $test replic, choose 1 random subtest: "
	set random_replic_subtest_list=`shuf -n1 -e $subtest_list_to_randomize_replic`
	set random_replic_subtest_list_with_commas=`echo "$random_replic_subtest_list" | tr ' ' ','`
	echo $random_replic_subtest_list_with_commas

	echo " "

	# If we have tests, run them async, saving results in /tmp/test-testname.txt.
	# Note that we use "fg", because if we use "bg", the shell does not know that there are child jobs to "wait" for.'
	# using fg with & gives us what we want: run multiple tests concurrently and wait for all of them to finish"
	if ( $random_nonreplic_subtest_list_with_commas != "" ) then
		echo "# Starting $test non-replic tests:"
		su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -env gtm_ipv4_only=1 -stdout 0 -fg -t $test -st $random_nonreplic_subtest_list_with_commas >>& /tmp/test-${test}.txt" &
	endif
	if ( $random_replic_subtest_list_with_commas != "" ) then
		echo "# Starting $test replic tests:"
		su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -env gtm_ipv4_only=1 -stdout 0 -fg -t $test -st $random_replic_subtest_list_with_commas -replic >>& /tmp/test-${test}.txt" &
	endif
end

echo " "
echo "### Wait till all tests are finished"
jobs
wait
echo " "

# Status of the script. 1 if any test failed
set test_status = 0

echo "### Go through test output directories:"
set tstdirs = `grep -h "Test Output Directory   ::" /tmp/test-* | awk -F":: " '{print $2}'`
foreach tstdir ($tstdirs)
	echo "## Output report for $tstdir, and see if it failed:"
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
	echo " "
end

# Coverage for YDB pipeline
/usr/library/gtm_test/T999/docker/coverage.csh
exit $test_status
