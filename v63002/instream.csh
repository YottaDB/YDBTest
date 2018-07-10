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
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# gtm8281	    [vinay] Tests YottaDB source lines, XECUTE strings and Direct Mode input all accept up to 8192 byte values
# gtm5178	    [vinay] Tests YottaDB reports BLKTOODEEP errors as warnings
# gtm8760	    [vinay] Tests YottaDB properly handles environment variables whose contesnts are over 32K in size
# gtm5250	    [vinay] Tests YottaDB supports fractional timeouts
# gtm8736	    [vinay] Tests $zroutines defaults to "." when $gtmroutines is undefined
#-------------------------------------------------------------------------------------

echo "v63002 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "gtm8281 gtm5178 gtm8760 gtm5250 gtm8736"
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

echo "v63002 test DONE."
