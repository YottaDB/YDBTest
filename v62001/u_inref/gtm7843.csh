#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

# test to verify that an instance freeze seldom produces MUTEXLCKALERT messages. Within 70 seconds, we should see no MUTEXLCKALERT
# because of the instance freeze protection.  There is a possiblity of seeing at most 1 MUTEXLCKALERT due to a small window. Without
# the instance freeze protection MUTEXLCKALERTs are issued every 32 seconds, so it should be issued twice in 70 seconds.

# Disable debug-only huge db scheme as that has been found to randomly/rarely slow this test down dramatically
# (it has been known to take 19 hours to finish once when it normally finishes in a minute or so). The suspicion is
# some XFS file system issue with handling 100s of processes updating tera-byte sized database file (even if it has a big hole).
setenv ydb_test_4g_db_blks 0

$gtm_tst/com/dbcreate.csh mumps 1 200 900 1024 100 328 200
unsetenv gtm_test_freeze_on_error	# this test does its own thing with freeze and doesn't need to deal with interactions
unsetenv gtm_test_fake_enospc		# ditto
cp $gtm_tst/com/gtmprocstuck_get_stack_trace.csh ./		# bring in a procstuctexec
setenv gtm_procstuckexec "$PWD/gtmprocstuck_get_stack_trace.csh"
echo $gtm_procstuckexec
setenv gtm_custom_errors $gtm_tools/custom_errors_sample.txt	# enable Instance Freeze

$gtm_dist/mumps -run gtm7843				# invoke the driver to create activity and manage the freeze

# Most of the time, there should never be a COUNTER_MUTEXLCKALERT file
if ("" != `find . -name 'COUNTER_MUTEXLCKALERT_*'`) then
	# If there is one, count the number of PIDs reported. If there is more than one, issue error
	@ bad = `$tst_awk 'END{ print NR }' COUNTER_MUTEXLCKALERT_*`
	if ($bad > 1) then
		echo "Not expecting $bad MUTEXLCKALERTs"	# check for excess procstuckexecs presumably caused by inst freeze
	endif
endif
$gtm_tst/com/dbcheck.csh
