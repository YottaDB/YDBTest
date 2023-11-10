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
# for bugs fixed in V53001
# ------------------------------------------------------------------------------
# C9H11002926 [SteveE] GTM allows relink of active routine if not most current fileheader
# ------------------------------------------------------------------------------
#
# The first subtest to be included in subtest_list_replic below will necessitate
#       a) a change to suite.txt to enable the test to be run with replication
#       b) a change to outref.txt to handle replication as well as non-replication test runs using ##TEST_AWK macros
#
echo "V53001 test starts..."
setenv subtest_list_common ""
setenv subtest_list_replic ""
setenv subtest_list_non_replic "C9H11002926 C9B03001664"
#
if ($?test_replic == 1) then
        setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
        setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
$gtm_tst/com/submit_subtest.csh
echo "V53001 test DONE."

