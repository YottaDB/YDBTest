#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
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
# zlen2arg	[estess]	Test two argument form of $[Z]LENGTH() and its use of $[Z]PIECE() cache
# prmptchk 	[estess]	Test prompt that it defaults to "YDB>" but can be overridden to "YDB>" if desired
# objlvlchk	[estess]	Verify object level changes for YDB
# dllversion	[estess]	Test DLLVERSION error for x8664 (sharedlib version is only 32 bit)
#                               (this test temporarily disabled due to issues with object file format change
#				but can be re-enabled after r1.32 is released though it needs to restrict
#				previous verisons to r1.30).
#-------------------------------------------------------------------------------------

echo "r100 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "zlen2arg prmptchk objlvlchk"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""
#if ("HOST_LINUX_IX86" == "$gtm_test_os_machtype") then
#        setenv subtest_exclude_list "$subtest_exclude_list xxxx"
#endif

# filter out tests that cannot run in pro
#if ("pro" == "$tst_image") then
#	setenv subtest_exclude_list "$subtest_exclude_list xxxx"
#endif

# If the platform/host does not have prior GT.M versions, disable tests that require them
if ($?gtm_test_nopriorgtmver) then
	setenv subtest_exclude_list "$subtest_exclude_list objlvlchk dllversion"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r100 test DONE."
