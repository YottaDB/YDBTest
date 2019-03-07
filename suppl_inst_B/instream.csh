#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Part B of supplementary instances test - original suppl_inst test split into multiple tests for quicker run times of each test
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
# dup_hist_rec			[parentel] <Test that history records are written twice if the same instance file is used more than once with updateresync.>
# fetchresync_nosupplsupplgroup	[bahirs] <Test fetchresync rollback between nonsupplementary and supplementary group>
# multiple_streams		[kishoreh] Test if mixing of multiple streams in the same receive pool is prevented
# noresync_2			[bahirs] <Test noresync qualifier for receiver start-up.>
# supplementary_err		[parentel,kishore] <Test invalid supplementary scenarios.>
# updateresync			[parentel,kishore] <Test -updateresync qualifier usage error.>
# upgrade_inst			[bahirs] <Test the upgrade of P(non-supplementary instace) from B(supplementary instance)>
#-------------------------------------------------------------------------------------

echo "Part B of supplementary instances test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_replic     "dup_hist_rec fetchresync_nosupplsupplgroup multiple_streams noresync_2 supplementary_err updateresync upgrade_inst "

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Randomization of replication type is disable since it is all handled by the subtests.
setenv test_replic_suppl_type 0

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "Part B of supplementary instances test DONE."
