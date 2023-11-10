#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	#
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
# for bugs fixed in V44004
# ------------------------------------------------------------------------------
# D9D11002390 [Vinaya]    ZSTEP OVER produces abnormal termination (SIG 4)
# C9D11002455 [Narayanan] tptime test (pro) cores with damaged malloc chains for huge TP transactions. Note this test is now
#                         removed since out of memory operations are now FATAL. New test v53002/C9D12002471 takes its place
#                         to test the new functionality.
# D9D06002344 [Narayanan] -newjnlfiles=sync_io option with mupip backup
# D9D12002401 [Narayanan] sync_io characteristics do not get preserved across MUPIP SET JOURNAL commands
# C9D01002206 [Zhouc]     leftover ipcs (orphaned semaphores and shared memories)
# D9D08002352 [Malli]	  $Q() fails on nodes with "" in last subscript
# C9D12002472_1 [Nergis]  test set noop optimization
# C9D12002472_2 [Nergis]  test that even if one region is frozen, TP updates can continue if that region is not updated
# D9D10002386 [Zhouc]     resync_seqno does not get flushed to disk by source sever if gtm is inactive
# D9E03002436 [Nergis]    MERGE needs to set restart point for interruptibility
# ------------------------------------------------------------------------------
#
# The first subtest to be included in subtest_list_replic below will necessitate
#	a) a change to suite.txt to enable the test to be run with replication
#	b) a change to outref.txt to handle replication as well as non-replication test runs using ##TEST_AWK macros
#
echo "V44004 test starts..."
setenv subtest_list_common "C9D12002472_1"
setenv subtest_list_replic "D9D10002386"
setenv subtest_list_non_replic "D9D11002390 D9D06002344 D9D12002401 D9D08002352 D9E03002436 C9D01002206 C9D12002472_2"
#
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
setenv subtest_exclude_list ""
# filter out subtests that cannot pass with MM
# C9D01002206	MM can't do backward recovery
# C9E03002545	MM can't do backward recovery
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "$subtest_exclude_list C9D01002206 C9E03002545"
endif

# filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list C9D01002206"
endif
$gtm_tst/com/submit_subtest.csh
echo "V44004 test DONE."
