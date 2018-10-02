#!/usr/local/bin/tcsh -f
#################################################################
#                                                              #
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.     #
# All rights reserved.                                         #
#                                                              #
#      This source code contains the intellectual property     #
#      of its copyright holder(s), and is made available       #
#      under a license.  If you do not know the terms of       #
#      the license, please stop and do not read further.       #
#                                                              #
#################################################################
#
#----------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#----------------------------------------------------------------------------------------------------------------------------------
# gtm4283	[quinn]	Test that GT.M compiler accepts input with <CR><LF> line termination.
# gtm6793	[quinn]	Test that Merge of two local variables that would result in 32 subscripts gives a YDB-E-MAXNRSUBSCRIPTS error
#----------------------------------------------------------------------------------------------------------------------------------

echo "v63001 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic gtm4283 gtm6793"
setenv subtest_list_replic     ""


if ($?test_replic == 1) then
       setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
       setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list    ""
# Filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
       setenv subtest_exclude_list "$subtest_exclude_list"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63001 test DONE."

