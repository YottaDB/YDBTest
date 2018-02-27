#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Note that $testname could be "v54003_0_2" where _0 reflects non-replic run and _2 reflects 2nd test run (-num_runs)
# We dont want the num_runs part. So do the below sed operation. In this case "$tst" points to "v54003".
set sprgdefile = `echo $testname | sed 's/\('$tst'_[0-9]*\)\(_.*\)/\1/'`

if ($?test_subtest_name) then
	set sprgdefile = ${sprgdefile}_${test_subtest_name}
endif
if ($?gtm_chset) then
	set sprgdefile = ${sprgdefile}_${gtm_chset}
else
	set sprgdefile = ${sprgdefile}_M
endif
if ($?test_collation_no) then
	set sprgdefile = ${sprgdefile}_"COL${test_collation_no}"
else
	set sprgdefile = ${sprgdefile}_"COL0"
endif
if ($?gtm_test_sprgde_id) then
	if ($gtm_test_sprgde_id != "") then
		set sprgdefile = ${sprgdefile}_${gtm_test_sprgde_id}
	endif
endif
set sprgdefile = ${sprgdefile}.sprgde

# Set sprgdeindir
set sprgdeindir = $gtm_test/$tst_src/sprgdedata
if (1 == $gtm_test_spanreg) then
	# if test wants to only use existing .sprgde files and not re-generate them (most common case)
	# use .sprgde files from generic directory.
	set sprgdeindir = $gtm_test/sprgdedata
else if (3 == $gtm_test_spanreg) then
	# test wants to use existing .sprgde files and re-generate them (done once in a while to refresh .sprgde files)
	# use .sprgde files from T9xx specific directory. But if the .sprgde file specific to this test/subtest combination
	# does not exist there, use the generic directory in the hope we find one in the generic directory (and hence get
	# more .sprgde test coverage).
	if (! -e $sprgdeindir/$sprgdefile) then
		set sprgdeindir = $gtm_test/sprgdedata
	endif
endif

# Set sprgdeoutdir
# As for output directory to generate .sprgde files, always choose T9xx specific directory (do not write to generic directory)
# as multiple folks might be running tests and we dont want race conditions during concurrent overwrites.
# Also if the env var "nfs_gtm_test" is defined, let it control where we place the .sprgde files.
set outdir = $gtm_test
if ($?nfs_gtm_test) then
	if (-e $nfs_gtm_test) then
		set outdir = $nfs_gtm_test
	endif
endif
set sprgdeoutdir = $outdir/$tst_src/sprgdedata
# gtmtest does not own any Txxx directory.
if ("gtmtest" == "$USER") set sprgdeoutdir = $outdir/sprgdedata/$tst_src

