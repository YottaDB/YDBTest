#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#----------------------------------------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# gtm9011	[mmr]		Test that MUPIP SET accepts -KEY_SIZE or -RESERVED_BYTES and -RECORD_SIZE in the same command
# gtm8017	[mmr]		Test of optional second argument to ^%TRIM that specifies which characters get trimmed
# gtm8947	[mmr]		Test of $translate() compile time optimization when it's second and third arguments are literals
# gtm7433	[mmr]		Test that $order(,-1) and $zprevious() do not print out the trigger global variable (^#t)
# gtm9005	[mmr]		Test that mupip load returns a non-zero error code when there are record errors in the load file
# gtm7952	[estess]	Verify SIGSAFE exteral call table attribute works as documented
# gtm7952b	[mmr]		Second half of 7952. Tests call out EXTCALLBOUNDS/EXCEEDSPREALLOC when exceeding preallocation of gtm_string_t/gtm_char_t
# gtm6125	[mmr]		Test of all the functions of the ISV $ztimeout
#----------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "v63006 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "gtm9011 gtm8017 gtm8947 gtm7433 gtm9005 gtm7952 gtm7952b gtm6135"
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

echo "v63006 test DONE."
