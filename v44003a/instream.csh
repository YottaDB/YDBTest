#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################
#
# ------------------------------------------------------------------------------
# for bugs fixed in V44003A
# ------------------------------------------------------------------------------
# D9D12002403 [Malli] Setting ZBREAK on line accessing more than 8 locals fails
# D9D12002404 [Malli] %YDB-F-GTMCHECK, Internal GT.M error
# D9D10002377 [Narayanan] The CLI parameter values are not reliable when read from CLI prompts
# C9D12002473 [Layek]     JNLBADRECFMT error from ideminter_rolrec test (this subtest uses replication server but $test_replic == 0)
# D9D12002402 [Narayanan] TID in the journal extract seems to be from innermost TSTART not outermost
# C9D12002478 [Malli]    marvin dbg cores with v44003 (find_line_addr has SEGV)
# D9D12002398 [Layek]	D9D12-002398 BEGSEQGTENDSEQ error as part of crash recovery testing at KTB
# ------------------------------------------------------------------------------
#
# The first subtest to be included in subtest_list_replic below will necessitate
#	a) a change to suite.txt to enable the test to be run with replication
#	b) a change to outref.txt to handle replication as well as non-replication test runs using ##TEST_AWK macros
#
echo "V44003a test starts..."
setenv subtest_list_common ""
setenv subtest_list_replic "D9D12002398"
setenv subtest_list_non_replic "D9D12002403 D9D12002404 D9D10002377 C9D12002473 D9D12002402 C9D12002478"
#
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""
# filter out subtests that cannot pass with MM
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "C9D12002473"
endif

# The below subtest uses MUPIP UPGRADE which is not supported in GT.M V7.0-000 (YottaDB r2.00). Therefore disable it for now.
setenv subtest_exclude_list "$subtest_exclude_list D9D10002377"	# [UPGRADE_DOWNGRADE_UNSUPPORTED]

$gtm_tst/com/submit_subtest.csh
echo "V44003a test DONE."
