#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Tests that when over 31 locks hash to the same value, LOCK commands work correctly
#
unsetenv ydb_lockhash_n_bits	# This env var will affect the hash values of the carefully chosen subscripts in this test
				# resulting in fewer collisions on the same hash value than the test expects so disable it
# Do not allow random use of V6 format DBs as this causes issues with LKE output (differing values)
setenv gtm_test_use_V6_DBs 0
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
# Simulates 2 errors in prior versions, either inappropriately seizes ownership of a lock or test hangs
# Randomly chooses an option (1 will cause the test to hang, 0 will cause locks to be inappropriately seized)
setenv hang `$gtm_tst/com/genrandnumbers.csh 1 0 1`
$ydb_dist/mumps -run ydb297^ydb297 >>& job.out
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
echo "# LOCKING RESOURCES THAT HASH TO THE SAME VALUE, EXPECT NUMBER OF LOCKS TO REMAIN CONSTANT ACROSS EACH RUN"
echo "# INFO FROM RUN 1"
# Not expecting any failure strings in this first file regardless of hang mode
$grep FAILURE lockhang_ydb297.mjo1
$grep LOCKSPACEINFO lockhang_ydb297.mjo1
# Note we don't check for FAILURE if $hang=1 here because there's a race condition in ydb297 where we've incremented
# the ^X() value for the next task to release it but we haven't yet released the locks held (until process quits) so
# the first several locks of the next job may fail until the previous job completes exiting and releasing its locks.
echo "# INFO FROM RUN 2"
if (0 == $hang) then
	# Not expecting any success strings if we are running a non hanging test
	$grep SUCCESS lockhang_ydb297.mjo2
endif
$grep LOCKSPACEINFO lockhang_ydb297.mjo2
echo "# INFO FROM RUN 3"
if (0 == $hang) then
	# Not expecting any success strings if we are running a non hanging test
	$grep SUCCESS lockhang_ydb297.mjo3
endif
$grep LOCKSPACEINFO lockhang_ydb297.mjo3
$grep SEGMENT lockhang_ydb297.mjo3
# The following section is retained but disabled for now. When we allow the neighborhood size to be changed, this code can
# help us determine when we've hit the neighborhood-full problem.
#echo "# Verify DSE DUMP -FILE -ALL displays [Lock Hash Bucket Full] statistic with a non-zero value"
# Filter out Transaction field as it can be non-deterministic due to "gtm_test_disable_randomdbtn"
#$DSE DUMP -FILE -ALL |& grep "Lock Hash" | sed 's/  *Transaction = .*//'
