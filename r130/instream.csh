#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2020 YottaDB LLC and/or its subsidiaries.	#
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
# ydb470 [bdw]  Tests ydb_init() to make sure that $gtm_dist is set correctly when it is initially null or different from $ydb_dist
# ydb482 [bdw]  Tests $ZJOBEXAM with 2 parameters to ensure the second parameter is working correctly
# ydb174 [bdw]  Ensures that naked references follow the max subscript limit
# ydb390 [bdw]  Tests $ZHASH and ydb_mmrhash_128 to ensure that their outputs are equivalent
# ydb476 [gm]   Tests $ZSigproc for its correctness with named string signal value as second argument
# ydb511 [bdw]  Tests $translate with undefined variables for the 2nd and 3rd arguments.
# ydb513 [nars] Test that $VIEW("REGION","^*") returns the name of the region mapped to by the `*` namespace
#----------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "r130 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "ydb470 ydb482 ydb174 ydb390 ydb476 ydb511 ydb513"
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

echo "r130 test DONE."
