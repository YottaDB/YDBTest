#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#-----------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-----------------------------------------------------------------------------------------------------------------
# gtm8909	    [jake]  Tests that <ctrl-c> within the help facility no longer leads to EN0256 error upon exit
# gtm8874	    [jake]  Tests the VIEW command's [:<region list>] qualifier
# gtm8860	    [jake]  Tests that journal extract removes additional / from journal and output file paths
# gtm8791	    [jake]  Tests that <ctrl-z> no longer causes segmentation violation
# gtm8202	    [jake]  Tests the functionality of the -SEQNO qualifier for the mupip journal -extract command
# gtm1041	    [jake]  Tests the that env variable gtm_mstack_size sets the size of the M stack as expected
#-----------------------------------------------------------------------------------------------------------------

echo "v63004 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8909 gtm8874 gtm8860 gtm8791 gtm8202 gtm1041"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63004 test DONE."
