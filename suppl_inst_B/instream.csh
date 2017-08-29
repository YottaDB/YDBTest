#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
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

# supplementary_err uses prior versions by manually modifying instance_file_config.txt. For multi-host runs, changing versions like this won't work well
if ("MULTISITE" == "$test_replic") then
	setenv subtest_exclude_list "$subtest_exclude_list supplementary_err"
endif
# If the platform/host does not have prior GT.M versions, disable tests that require them
if ($?gtm_test_nopriorgtmver) then
	setenv subtest_exclude_list "$subtest_exclude_list supplementary_err"
else if ($?ydb_environment_init) then
	# We are in a YDB environment (i.e. non-GG setup)
	source $gtm_tst/com/set_gtm_machtype.csh	# to setenv "gtm_test_linux_distrib"
	if ("dbg" == "$tst_image") then
		# We do not have dbg builds of versions [V51000,V54003] needed by the below subtest so disable it.
		setenv subtest_exclude_list "$subtest_exclude_list supplementary_err"
	else if ("arch" == $gtm_test_linux_distrib) then
		# The pro builds of versions [V51000,V54003] needed by the below subtest occasionally get SIG-11 on certain hosts.
		# This is due to a known issue that is fixed in V55000 but this test requires those older versions.
		# So disable this test on those hosts.
		setenv subtest_exclude_list "$subtest_exclude_list supplementary_err"
	endif
endif

# Randomization of replication type is disable since it is all handled by the subtests.
setenv test_replic_suppl_type 0

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "Part B of supplementary instances test DONE."
