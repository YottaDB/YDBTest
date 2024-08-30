#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2024 YottaDB LLC and/or its subsidiaries.	#
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
# gtm8130		[mmr]		Test of %GSEL changes to ignore subscripts and issue errors on bad inputs
# gtm8665		[mmr]		Test that mupip integ reports interrupted -RECOVER/-ROLLBACK attempts
# gtm8626		[mmr]		Test that if mupip journal switches -losttrans, -brokentrans have the same output file an error is raised
# gtm9047		[mmr]		Test of the ISV $ZCSTATUS under various conditions, and that triggers with "xecute" are not added if they contain errors
# gtm9043		[mmr]		Test that YDB detects more concatenations than allowed when parsing source code and not at code generation
# gtm9056		[mmr]		Test that MUPIP SET takes switches -TRIGGER_FLUSH=n and -WRITES_PER_FLUSH=n and that MUPIP DUMPFHEAD shows -TRIGGER_FLUSH setting
# gtm9071		[mmr]		Test that ZMESSAGE with a boolean expression does not sig11
# gtm7318		[pooh]		Test for Audit Principal Device
#----------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "v63007 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     "gtm8665"
setenv subtest_list_non_replic "gtm8130 gtm8626 gtm9047 gtm9043 gtm9056 gtm9071 gtm7318"
setenv subtest_list_replic     ""


if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list "
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63007 test DONE."
