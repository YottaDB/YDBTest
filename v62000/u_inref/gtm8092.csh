#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test below two things
#	1) SIG-11 during SET of 1Mb-sized global nodes in replicated database and journal pool size is close to 1Mb
#	2) mrep <gtmsource_msgp_assert_failures_in_source_server>

# Randomly choose a jnlpool size of 1Mb or 2Mb. With 1Mb, we test (1). With 2Mb, we test (2).
@ jnlpoolsize = `$gtm_exe/mumps -run %XCMD 'write $random(2)'`
if ($jnlpoolsize) then
	setenv gtm_test_jnlpool_buffsize 1000000
else
	setenv gtm_test_jnlpool_buffsize 2000000
endif
# Set receive pool size of 20Mb to ensure the largest transaction we send will fit in one recvpool
setenv tst_buffsize 20000000

setenv gtm_test_spanreg     0       # Test requires traditional global mappings, so disable spanning regions

$MULTISITE_REPLIC_PREPARE 2

# Test does sets of 1Mb nodes so set huge record-size.
# Need huge block-size and global-buffers to avoid TRANS2BIG errors
$gtm_tst/com/dbcreate.csh mumps 1 -record_size=1048576 -block_size=8192 -global_buffer_count=8192

$MSR STARTSRC INST1 INST2 RP

echo "Do first set of updates. The first jnl_seqno has ~ 4Mb of journal data so source server will expand its internal buffers"
$gtm_dist/mumps -run test1^gtm8092

echo "Start receiver server after updates are done to ensure source server reads first jnl_seqno from files"
$MSR STARTRCV INST1 INST2

echo "Sleep at least two heartbeat periods (8 seconds each) to ensure source server trims its internal buffers"
sleep 17

echo "Stop receiver server before second set of updates to ensure source server reads those from journal files as well"
$MSR STOPRCV INST1 INST2

echo "Do second set of updates. This has ~ 3Mb of journal data so source server does not need to expand its buffers as much as before"
$gtm_dist/mumps -run test2^gtm8092

echo "Start receiver server so source server now sends from files"
$MSR STARTRCV INST1 INST2

echo "Check that source server has sent all data without issues"
$gtm_tst/com/dbcheck.csh -extract
