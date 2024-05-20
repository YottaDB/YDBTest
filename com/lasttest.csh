#!/usr/local/bin/tcsh -f
###########################################################
#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
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
	foreach tst (`awk '{print $2}' $last_tst_dir/submitted_tests`)
		# Find the last listed test that was actually run
		if ! (-e $last_tst_dir/${tst}_0) break
		setenv tst $tst
	end
	unset tst   # unset the internal variable to expose the last env variable we set above
endif

if ( "$tst" == "" ) then
	echo "\$last_tst_dir/submitted_tests should contain a valid list of tests that were run. Did they run?"
	ln -fns $last_tst_dir "$r"   # if we can't find a specific test dir, at least point to its parent
	exit 1
endif

echo 'Latest test results are available via symlink at $r'
ln -fns $last_tst_dir/${tst}_0 "$r"

# extract last subtest run -- may be by aliases, e.g. to auto-diff the last subtest (see meldtest alias)
if ( -e $last_tst_dir/${tst}_0/config.log ) then
	setenv subtests `cat $last_tst_dir/${tst}_0/config.log | grep -oP "SUB_TEST: \K[^ ]+"`
else
	echo 'But no test log found at $r/config.log'
	setenv subtests ""
endif
setenv subtest `grep -soP "(?<=^FAIL from )[^.]+" $r/outstream.log`
if ( "$subtest" == "" ) setenv subtest `echo $subtests | grep -oE '[^ ]+$'`
