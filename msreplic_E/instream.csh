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
# instance_file_backup_stress	[Nergis]	Stress test for backup of instance files
# switch_over			[Kishore]	The multi-site version of the switch_over test
# two_passive_source_servers	[Nergis]	Test that activating one of two passive source servers and shutting down the other one works

echo "Part E of multisite_replic tests starts..."


setenv tst_jnl_str `echo "$tst_jnl_str" | sed 's/,align=[1-9][0-9]*//'`
if (1 == $test_replic_suppl_type) then
	# A->P type won't work for most of the subtests, for valid reasons of their own. Choose only between A->B and P->Q
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_replic     "instance_file_backup_stress switch_over two_passive_source_servers"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "Part E of multisite_replic tests DONE."
