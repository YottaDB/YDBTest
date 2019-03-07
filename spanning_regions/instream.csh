#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
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
# gde			[kishoreh] unit test cases for gde from narayanan
# merge			[kishoreh] specific test cases checking merge with spanning regions and extended global reference
# functions1		[kishoreh] checking $data, $order, $query and zwrite with spanning regions
# namelevelorder	[kishoreh] test case for $order operation with spanning regions
# extgbl		[kishoreh] test cases for per2953 fixes
# jnl_nojnl		[kishoreh] A global with one part map to a journaled region and another part map to a non-journaled region
# viewregion_gvstats	[nars] Test that $VIEW("REGION") and various db operations touch the correct # of regions in case of spanned globals
# mergecoll		[kishoreh,nars] test cases for merge and different collations (and spanning regions)
# keysizevary		[nars] test effect of varying max-key-size settings across the regions spanned by one global
# actcollmismtch	[kishoreh,nars] test cases for YDB-E-ACTCOLLMISMTCH errors
# gtm7562		[kishoreh] GTM-7562 DSE silently switches to the wrong region if same global exists in multiple .dat files
# collationtests	[kishoreh,nars] various test cases for collation + spanning regions
# noisolation		[kishoreh] tests for view "NOISOLATION" command
# mixgld		[kishoreh] a few global access scenarios with multiple glds spanning same global differently
# gv_altkey_corruption	[sopini] test a known case of gv_altkey corruption that leads to bad $zprevious() results
#-------------------------------------------------------------------------------------

echo "spanning_regions test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "gde merge functions1 namelevelorder extgbl viewregion_gvstats mergecoll keysizevary"
setenv subtest_list_non_replic "$subtest_list_non_replic actcollmismtch gtm7562 collationtests noisolation mixgld"
setenv subtest_list_non_replic "$subtest_list_non_replic gv_altkey_corruption"
setenv subtest_list_replic     "jnl_nojnl"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "spanning_regions test DONE."

