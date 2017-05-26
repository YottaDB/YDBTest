#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
# orphanshm	[Bahirs]	Test argumentless mupip rundown behavior"
# dbidmismatch2	[Bahirs]	Test DBIDMISMATCH error in argumentless MUPIP RUNDOWN"
# mupip_rundown_ipcs	[sopini]	Ensure that shared memory as well as FTOK and access control semaphores are not left.
# gtm7010	[karthikk]	Verify that argument less MUPIP RUNDOWN does not remove shared memory if there are processes attached to the journal pool.
# gtm7485	[karthikk]	ensure that argument-less rundown doesn't exploit the open-window in repl-shutdown logic
# gtm7706 	[karthikk] 	Test that argument-less rundown removes orphaned shared memory and semaphores.
# gtm7938	[base]		Verify that mu_rndwn_replpool_ch is not called outside of the mu_rndwn_replpool function
# ipcsnoreset	[base]		Verify that shared memory and semaphore fields in the file header are not reset without being removed

echo "rundown_argless test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "orphanshm dbidmismatch2 mupip_rundown_ipcs "
setenv subtest_list_replic     "gtm7010 gtm7485 gtm7706 gtm7938 ipcsnoreset mu_rundown_no_ipcrm1"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""
# If the platform/host does not have prior GT.M versions, disable tests that require them
if ($?gtm_test_nopriorgtmver) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm7938 "
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "rundown_argless test DONE."
