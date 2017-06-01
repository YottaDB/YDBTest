#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
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
#
# basic		[estess]	Basic testing of gtmsecshr functionality
# rorundown	[estess]	Test rundown of read-only database (orphaned IPCs no updates)
#                               NOTE! Above test currently disabled due to rundown bugs exposed (GTM-7386)
# gtm7617	[shaha]		Validate that gtmsecshr_wrapper does not pass on control characters when sending syslog messsages.
#-------------------------------------------------------------------------------------

echo "secshr test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "basic gtm7617"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# On lester (HPPA), snail (Solaris 8), and turtle (Solaris 9), the gtmposix plugin does not implement setenv()
if ("HOST_HP-UX_PA_RISC" == "${gtm_test_os_machtype}" || "snail" == "${HOST:r:r:r}" || "turtle" == "${HOST:r:r:r}") then
	setenv subtest_exclude_list	"${subtest_exclude_list} gtm7617"
endif

# If IGS is not available, filter out tests that need it
if ($?gtm_test_noIGS) then
	setenv subtest_exclude_list "$subtest_exclude_list basic"
endif
if ($?gtm_test_temporary_disable) then
       setenv subtest_exclude_list "$subtest_exclude_list gtm7617"
endif
# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "secshr test DONE."

