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
# Part C of supplementary instances test - original suppl_inst test split into multiple tests for quicker run times of each test
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# failovers_with_supp	[parentel]	Test that non-supplementary failovers do not affect supplementary instance as long as rollback is not needed.
# multiple_switchover	[bahirs]	Test the multiple switchover between supplementary and non-supplementary instances.>
# noresync		[parentel,kishore] Test the new -noresync qualifier
# resync_seqno		[bahirs]	Test correctness of rollback with strm_seqno and strm_no
# reuse			[parentel]	Test the -REUSE qualifier
# wronginsync		[parentel,kishore]	Test that LMS logic correctly considers two instances in sync when they are not
# gtm8074		[nars]		Test interrupted fetchresync rollback on supplementary instance works
#-------------------------------------------------------------------------------------
#
if (0 != $test_replic_mh_type) then
	setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to difficulties with remote systems having same V6 version to create DBs
endif

echo "Part C of supplementary instances test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_replic     "failovers_with_supp multiple_switchover noresync resync_seqno reuse wronginsync gtm8074 "

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Randomization of replication type is disabled since it is all handled by the subtests.
setenv test_replic_suppl_type 0

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "Part C of supplementary instances test DONE."
