#!/usr/local/bin/tcsh -f
###########################################################
#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
###########################################################

# Source this to create a symlink at $r pointing to the most recent run test and subtest

if ( `find $tst_dir -maxdepth 1 -type d -name "tst_*"` == "" ) exit 1   # avoid No Match error if no prior test
setenv last_tst_dir `ls -dt $tst_dir/tst_* | head -n1`
if ( -e $last_tst_dir/submitted_tests ) then
	# If test was run with runtest or gtmtest, there is a submitted_tests file containing
	# a list of tests that were run, so extract name of last test run.
	# Otherwise (if run by runsubtest), retain $tst from what was previously set by settest.
	foreach submitted_tst (`awk '{print $2}' $last_tst_dir/submitted_tests`)
		# Find the last listed test that was actually run
		set max_wait = 60
		# Note that this check only works for the simple case of running one test without replication.
		# It will not work in the case of:
		# + Submitting a test with `-replic`, which would only create `${tst}_1`
		# + Submitting a test with `-num_runs 10` etc., which would only create `${tst}_0_1` etc.
		while ( (! -e $last_tst_dir/${submitted_tst}_0) && ($max_wait > 0) )
			# Wait for the last test directory to be created. Needed when tests are run in the background,
			# such as when -fg is not passed to gtmtest.csh, e.g. via $gtmtest_args".
			sleep 1
			@ max_wait = $max_wait - 1
		end
		if ! (-e $last_tst_dir/${submitted_tst}_0) break
		setenv tst $submitted_tst
	end
endif

if ( "$tst" == "" ) then
	echo "\$last_tst_dir/submitted_tests should contain a valid list of tests that were run. Did they run?"
	ln -fns $last_tst_dir "$r"   # if we can't find a specific test dir, at least point to its parent
	exit 1
endif

echo 'Latest test results are available via symlink at $r'
grep "\-replic" $last_tst_dir/config.log >& /dev/null
if ($status == 0) then
	# The test was a -replic test, so the last directory ends in 1 instead of 0
	ln -fns $last_tst_dir/${tst}_1 "$r"
else
	ln -fns $last_tst_dir/${tst}_0 "$r"
endif

# extract last subtest run -- may be by aliases, e.g. to auto-diff the last subtest (see meldtest alias)
if ( -e $last_tst_dir/${tst}_0/config.log ) then
	setenv subtests `cat $last_tst_dir/${tst}_0/config.log | grep -oP "SUB_TEST: \K[^ ]+"`
else
	echo 'But no test log found at $r/config.log'
	setenv subtests ""
endif
setenv subtest `grep -soP "(?<=^FAIL from )[^.]+" $r/outstream.log`
if ( "$subtest" == "" ) setenv subtest `echo $subtests | grep -oE '[^ ]+$'`
