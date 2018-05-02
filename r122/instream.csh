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
#-------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------------------------------
# tprestart   [nars]  Test that TPRESTART syslog message has the correct global name when restart "type" is 4
# viewcmdfunc [nars]  Test various VIEW commands and $VIEW functions (used to SIG-11/SIG-6/GTMASSERT2 in V6.3-004)
# blktoodeep  [nars]  Test that BLKTOODEEP error is not issued if -NOWARNING is specified at compile time
#-------------------------------------------------------------------------------------------------------------

echo "r122 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic tprestart viewcmdfunc blktoodeep"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r122 test DONE."
