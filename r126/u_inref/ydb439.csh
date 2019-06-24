#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#

echo '# Test that causing setting greater than 33 lock collisions does not cause a hang and runaway shared memory usage'

if ($tst_image == "dbg") then
	echo '# Testing 100 lock collisions when ydb_lockhash_n_bits=1'
	echo '# The value of sgmnt_data.lock_hash_bucket_full_cntr should be 70 as all the buckets are full after the 30th lock'
	$gtm_tst/com/dbcreate.csh mumps
	setenv ydb_lockhash_n_bits 1
	$ydb_dist/mumps -run lockMonitorA^ydb439 &
	$ydb_dist/mumps -run lockhashloopA^ydb439
	wait
	$gtm_tst/com/dbcheck.csh
endif


echo; echo '# Testing 47 lock collisions when ydb_lockhas_n_bits is unset'
echo '# The value of sgmnt_data.lock_hash_bucket_full_cntr should be 16 as all the buckets are full after the 30th lock'
$gtm_tst/com/dbcreate.csh mumps
unsetenv ydb_lockhash_n_bits
$ydb_dist/mumps -run lockMonitorB^ydb439 &
$ydb_dist/mumps -run lockhashloopB^ydb439
wait
$gtm_tst/com/dbcheck.csh

exit 0
