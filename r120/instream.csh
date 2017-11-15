#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
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
# zindcacheoverflow [ashok]	Test fix to indirect code cache stats 4-byte overflow error
# largelvarray       [nars]	Test local array performance does not deteriorate exponentially with large # of nodes
# gctest             [nars]	Test stringpool garbage collection performance with lots of strings in the pool
# patnotfound        [nars]	Test runtime behavior after PATNOTFOUND compile-time error
#-------------------------------------------------------------------------------------

echo "r120 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "zindcacheoverflow largelvarray gctest patnotfound"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Disable certain heavyweight tests on single-cpu systems
if ($gtm_test_singlecpu) then
	setenv subtest_exclude_list "$subtest_exclude_list largelvarray"
endif

if ("dbg" == "$tst_image") then
	# gctest subtest stresses the stringpool garbage collection and runs very slow in dbg so disable it there.
	setenv subtest_exclude_list "$subtest_exclude_list gctest"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r120 test DONE."
