#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# all rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license. If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#-----------------------------------------------------------------------------------------------------------------------------
# list of subtests of the form "subtestname [author] description"
#-----------------------------------------------------------------------------------------------------------------------------
# gtm8909	    [jake]  tests that <ctrl-c> within the help facility no longer leads to en0256 error upon exit
# gtm8891	    [vinay] testing for a select false runtime error in ydb when <side-effect-expression><pure-Boolean-operator>$SELECT(0:side-effect-expression)) is run
# gtm8860	    [jake]  tests that journal extract removes additional / from journal and output file paths
# gtm8791	    [jake]  tests that <ctrl-z> no longer causes segmentation violation
# gtm8699	    [jake]  tests that $view("statshare",<region>) returns 1 if the process is sharing db stats and 0 otherwise
# gtm8202	    [jake]  tests the functionality of the -seqno qualifier for the mupip journal -extract command
# gtm5730	    [jake]  tests that the update process now logs record types with a corresponding, non-numerical, description
# gtm1041	    [jake]  tests the that env variable gtm_mstack_size sets the size of the m stack as expected
#-----------------------------------------------------------------------------------------------------------------------------

echo "v63004 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8909 gtm8891 gtm8860 gtm8791 gtm8699 gtm8202 gtm1041"
setenv subtest_list_replic     ""
setenv subtest_list_replic     "$subtest_list_replic gtm5730"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63004 test DONE."
