#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#----------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#----------------------------------------------------------------------------------------------------------------------------------
# rlsiglongjmp-ydb1065		[sam]	Multiple signals to a process in readline mode causes loss of stack
# mupip_verbose-ydb1060		[pooh]	Test functionality of MUPIP BACKUP, MUPIP FREEZE and MUPIP INTEG with option -DBG and -VERBOSE
#----------------------------------------------------------------------------------------------------------------------------------

echo "r202 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	"rlsiglongjmp-ydb1065 mupip_verbose-ydb1060"
setenv subtest_list_replic	""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list rlsiglongjmp-ydb1065"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# This test is a readline specific test. Exclude if readline is disabled.
if ($?ydb_readline) then
	if ( "0" == $ydb_readline ) then
		setenv subtest_exclude_list "$subtest_exclude_list rlsiglongjmp-ydb1065"
	else
		# Readline is enabled.
		# This test fails on SUSE Tumbleweed where its readline behaves as if it's readline 7
		# whereas it reports itself to be readline 8. Rather than try to figure out why,
		# just disable this test on SUSE Tumbleweed as we have good coverage on other SUSE systems.
		if ( "opensuse-tumbleweed" == $gtm_test_linux_suse_distro ) then
			setenv subtest_exclude_list "$subtest_exclude_list rlsiglongjmp-ydb1065"
		endif
	endif

endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r202 test DONE."
