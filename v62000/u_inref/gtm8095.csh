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
# Test for : Buffer overflows in source server in rare cases with multiple regions and huge transactions (> 3Mb jnl record size)

# Set jnlpool size of < 2Mb to ensure source server will read first seqno from files
setenv gtm_test_jnlpool_buffsize 2000000
# Set receive pool size of 10Mb to ensure the largest transaction we send will fit in one recvpool
setenv tst_buffsize 10000000

setenv gtm_test_spanreg     0       # Test requires traditional global mappings, so disable spanning regions

$MULTISITE_REPLIC_PREPARE 2

# Test does sets of 1Mb nodes so set huge record-size.
# Need huge block-size and global-buffers to avoid TRANS2BIG errors
$gtm_tst/com/dbcreate.csh mumps 3 -record_size=1048576 -block_size=8192 -global_buffer_count=8192

$MSR STARTSRC INST1 INST2 RP

echo "Do updates that have ~ 3Mb of journal data such that they use up almost all"
echo "	of the source server's internal buffer (after one expansion) but does not"
echo "	have enough room to write TCOM record for the 3 regions"
$gtm_dist/mumps -run gtm8095

echo "Start receiver server after updates are done to ensure source server reads first jnl_seqno from files"
$MSR STARTRCV INST1 INST2

echo "Check that source server has sent all data without issues"
$gtm_tst/com/dbcheck.csh -extract
