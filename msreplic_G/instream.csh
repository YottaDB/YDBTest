#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2014 Fidelity Information Services, Inc	#
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
# instance_file_complex		[Nergis]	Design tests -- Complex Example
# primary_to_tertiary_transition [Kishore]	Test the transitions of primary to be a tertiary
# crash_passive_source		[Nergis]	Test that a passive source server to a tertiary can be restarted (after a crash) as an active propagateprimary
# start_order			[Balaji]	Test different starting orders of source server and receiver server on an instance

echo "Part G of multisite_replic tests starts..."


setenv tst_jnl_str `echo "$tst_jnl_str" | sed 's/,align=[1-9][0-9]*//'`
if (1 == $test_replic_suppl_type) then
	# A->P type won't work for most of the subtests, for valid reasons of their own. Choose only between A->B and P->Q
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_replic     "instance_file_complex primary_to_tertiary_transition crash_passive_source start_order "

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Filter out subtests that cannot pass with MM
#  instance_file_complex		Requires BEFORE image journaling
#  primary_to_tertiary_transition	Requires BEFORE image journaling
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "$subtest_exclude_list instance_file_complex primary_to_tertiary_transition "
endif
# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "Part G of multisite_replic tests DONE."
