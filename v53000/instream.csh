#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# ------------------------------------------------------------------------------
# for bugs fixed in V53000
# ------------------------------------------------------------------------------
# C9F06002736 [Narayanan] Test case for REPLOFFJNLON error from GT.M
# D9H08002668 [Narayanan] MUPIP REORG hangs with lots of global variables in -SELECT qualifier
# C9H09002905 [Narayanan] Source server should log only AFTER sending at least 1000 transactions on the pipe
# C9C11002165 {SteveJ] Object files are truncated at creation, even if recompiled
# C9H09002900 [MikeC] View command should show a changed global directory without having to access a variable
# ------------------------------------------------------------------------------
#
# The first subtest to be included in subtest_list_replic below will necessitate
#	a) a change to suite.txt to enable the test to be run with replication
#	b) a change to outref.txt to handle replication as well as non-replication test runs using ##TEST_AWK macros
#
echo "V53000 test starts..."
setenv subtest_list_common ""
setenv subtest_list_replic "C9H09002905 "
setenv subtest_list_non_replic "C9F06002736 D9H08002668 C9C11002165 C9H05002863 C9H09002900"
#
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
$gtm_tst/com/submit_subtest.csh
echo "V53000 test DONE."
