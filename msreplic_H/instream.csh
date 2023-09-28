#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2012, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# The original long running multisite_replic test is split into multiple smaller tests
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# max_connections		[Kishore]	Test the maximum supported number of connections
# instsecondary			[Balaji]	Test different variations of specifying -instsecondary (explicit, implicit using $gtm_repl_instsecondary, unspecified)
#
if (0 != $test_replic_mh_type) then
	setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to difficulties with remote systems having same V6 version to create DBs
endif
echo "Part H of multisite_replic tests starts..."


setenv tst_jnl_str `echo "$tst_jnl_str" | sed 's/,align=[1-9][0-9]*//'`
if (1 == $test_replic_suppl_type) then
	# A->P type won't work for most of the subtests, for valid reasons of their own. Choose only between A->B and P->Q
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_replic     "max_connections instsecondary"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# filter out few subtests on MULTISITE
if ($?test_replic) then
	if ("MULTISITE" == "$test_replic") then
		setenv subtest_exclude_list "$subtest_exclude_list instsecondary"
	endif
endif

# filter out some subtests for some servers
set hostn = $HOST:r:r:r
# filter out max_connections subtest on snail due to lack of memory errors
# max_connections uses up page space especially if anything else is running
if ( ("snail" == "$hostn") || ("os390" == "$gtm_test_osname") ) then
	setenv subtest_exclude_list "$subtest_exclude_list max_connections"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "Part H of multisite_replic tests DONE."
