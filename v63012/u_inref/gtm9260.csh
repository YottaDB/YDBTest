#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# This test verifies that when an auxiliary shared memory segment for a resize M Lock hashtable"
echo "# is created and orphaned, it gets cleaned up by MUPIP RUNDOWN. Prior to GTM-9260, that cleanup"
echo "# did not occur".

# The sequence in this test is the following:
# 1. Run gtm9260.m. This will force the creation of a resized M Lock hashtable, writes the shmid of the
#    segment out to mlockshmid.txt (which it obtains via ^%PEEKBYNAME(), and kills itself with a kill -9
#    to orphan the IPCs.
# 2. Verify the orphaned shared memory segment exists.
# 3. Run MUPIP RUNDOWN on the DEFAULT region.
# 4. Verify that the lock hashtab extension shared segment shmid no longer exists

$gtm_tst/com/dbcreate.csh mumps
setenv ydb_lockhash_n_bits 10   # Using only 10 bits of the hash value causes enough hash collisions to create the shm we want
$echoline
echo "# Step 1 - run gtm9260 to create and orphan our M Lock hashtab shm extension"
$ydb_dist/mumps -run gtm9260
$echoline
echo "# Step 2 - verify the shmid created for the lock hashtab extension was properly orphaned"
set shmid = `cat ydblckhshshmid.txt`
set rslt = `$gtm_tst/com/ipcs -m | $tst_awk '{print $2}' | $grep -w $shmid`
if ("" == "$rslt") then
    echo "Fail - shmid created for the lock hashtab extension was not orphaned properly"
else
    echo "Verified - the shmid created for the lock hashtab extension was properly orphaned and still exists"
endif
$echoline
echo "# Step 3 - run MUPIP RUNDOWN on the DEFAULT region"
$MUPIP rundown -region DEFAULT
$echoline
echo "# Step 4 - verify the shmid created for the lock hashtab extension has been removed"
set rslt = `$gtm_tst/com/ipcs -m | $tst_awk '{print $2}' | $grep -w $shmid`
if ("" == "$rslt") then
    echo "Success - created M Lock shm was removed"
else
    echo "Fail - we still see the created M Lock shm - was not cleaned up by MUPIP RUNDOWN"
endif
$echoline
echo "# Run dbcheck"
$gtm_tst/com/dbcheck.csh
