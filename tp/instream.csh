#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------

echo "tp test starts..."

# This test can only run with BG access method, so let's make sure that's what we have
source $gtm_tst/com/gtm_test_setbgaccess.csh
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
if($?test_replic) setenv save_test_replic test_replic
if ($test_reorg == "REORG") then
	if($?test_replic) then
		echo "tp test does not run with replic and reorg together"
		exit
	endif
	setenv tst_offline_reorg 1
	setenv test_reorg "NON_REORG"
endif
# List the subtests separated by spaces under the appropriate environment variable name
if ( $LFE == "L") then
	setenv subtest_list_common     "tp"
else
	setenv subtest_list_common     "tp interfer rinttp recovery per tpset split kill tpclue tptest"
endif
setenv subtest_list_non_replic ""
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "tp test DONE."

