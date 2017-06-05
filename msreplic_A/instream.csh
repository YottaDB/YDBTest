#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# ------------------------------------------------------------------------------
# For multisite replication tests
# The original long running multisite_replic test is split into multiple smaller tests
# ------------------------------------------------------------------------------
# subtest 			[author] 	description
#--------------------------------------------------
# activate_deactivate		[Nergis]	Test activating and deactivating source servers
# active_passive_source		[Nergis]	If there is an active source server running to a specific instance, one cannot start another active/passive source to that instance
# cleanslots			[Nergis]	Design tests -- Source Server Shutdown
# instance_create		[Kishore]	Test mupip replic -instance_create
# instance_file_cycle		[Kishore]	Design tests -- Final Example
# tertiary_ahead		[Nergis]	Test what happens when a tertiary instance realizes its propagating primary did a rollback (to a point before the tertiaries seqno)
# log_error			[zouc] 		Test what happens when the log file or stdout/stderr are not available
#
echo "Part A of multisite_replic tests starts..."

setenv tst_jnl_str `echo "$tst_jnl_str" | sed 's/,align=[1-9][0-9]*//'`
if (1 == $test_replic_suppl_type) then
	# A->P type won't work for most of the subtests, for valid reasons of their own. Choose only between A->B and P->Q
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif
#
setenv subtest_list_common " "
setenv subtest_list_replic "activate_deactivate active_passive_source cleanslots instance_create instance_file_cycle tertiary_ahead "
setenv subtest_list_replic "$subtest_list_replic updateproc_nohang log_error"
setenv subtest_list_non_replic " " #no non-replic subtests for multisite replication, but is left here to keep the test structure.
#
if (1 == $?test_replic) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	echo "TEST-E-NON_REPLIC multisite_replic needs to be submitted with -replic option"
	exit 1
endif

setenv subtest_exclude_list ""

# filter out few subtests on MULTISITE
if ($?test_replic) then
	if ("MULTISITE" == "$test_replic") then
		setenv subtest_exclude_list "$subtest_exclude_list instance_create "
	endif
endif

# Filter out subtests that cannot pass with MM
#  instance_file_cycle			Requires BEFORE image journaling
#  tertiary_ahead			Requires BEFORE image journaling
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "$subtest_exclude_list instance_file_cycle tertiary_ahead"
endif

# If the platform/host does not have prior GT.M versions, disable tests that require them
if ($?gtm_test_nopriorgtmver) then
	setenv subtest_exclude_list "$subtest_exclude_list updateproc_nohang"
endif

# Filter out tests requiring specific gg-user setup, if the setup is not available
if ($?gtm_test_noggusers) then
	setenv subtest_exclude_list "$subtest_exclude_list log_error"
endif

if ($?gtm_test_temporary_disable) then
	setenv subtest_exclude_list "$subtest_exclude_list activate_deactivate"
endif

$gtm_tst/com/submit_subtest.csh

echo "Part A of multisite_replic tests DONE."
