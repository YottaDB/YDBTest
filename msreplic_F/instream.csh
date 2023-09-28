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
# instance_file_simple		[Nergis]	Design tests -- Simple Example
# errors			[Kishore]	Test all error scenarios
# rp_pp				[Balaji]	Test erroronous uses of -rootprimary and -propagateprimary
# dummy_passive_source_server	[Balaji]	Test that if the instance name of the secondary-to-be is unknown, using a dummy passive source server works
if (0 != $test_replic_mh_type) then
	setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to difficulties with remote systems having same V6 version to create DBs
endif
echo "Part F of multisite_replic tests starts..."


setenv tst_jnl_str `echo "$tst_jnl_str" | sed 's/,align=[1-9][0-9]*//'`
if (1 == $test_replic_suppl_type) then
	# A->P type won't work for most of the subtests, for valid reasons of their own. Choose only between A->B and P->Q
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_replic     "instance_file_simple errors rp_pp dummy_passive_source_server"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Filter out subtests that cannot pass with MM
#  instance_file_simple			Requires BEFORE image journaling
#  errors				Requires BEFORE image journaling
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "$subtest_exclude_list instance_file_simple errors "
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "Part F of multisite_replic tests DONE."
