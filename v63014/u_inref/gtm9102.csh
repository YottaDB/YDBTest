#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

echo "##################################################################################"
echo "# Test GTM-9102 : MUPIP FREEZE -ONLINE is consistent across regions except for AIO"
echo "##################################################################################"

echo "# Disable AIO in the test as GTM-9102 does not work with it"
setenv gtm_test_asyncio 0

echo "# Force BG as access method as ONLINE FREEZE does not work on MM regions"
setenv acc_meth BG

echo "# Create 2-region database where ^a updates go to a.dat and ^b updates go to b.dat"
$gtm_tst/com/dbcreate.csh mumps 2 >& dbcreate.out

echo "# Start updates in background that set ^a=i and ^b=i+1 in a loop"
$gtm_dist/mumps -run startupd^gtm9102

echo '# Run MUPIP FREEZE -ONLINE -ON "*"'
$gtm_dist/mupip freeze -on -online "*" >& freeze.out

echo "# Capture online freeze output in a deterministic order"
echo "# First capture list of regions that got frozen in a sorted order (to keep it determninistic)"
grep Region freeze.out | sort

echo "# Copy over the a.dat and b.dat files over to a [bak] directory (effectively taking a snapshot after online freeze)"
mkdir bak
cp *.gld *.dat bak

echo "# Unfreeze the regions now that the snapshot has been taken"
$gtm_dist/mupip freeze -off "*" >& unfreeze.out

echo "# Stop background updates"
$gtm_dist/mumps -run stopupd^gtm9102

cd bak
echo "# Run [mupip rundown] first on the snapshot as the backup .dat files still have references to live db shmid"
$gtm_dist/mupip rundown -reg "*" >& rundown.out
echo "# Verify that multi-region online freeze snapshot has ^a and ^b differing by at most 1"
echo "# Before GTM-9102 fixes, the difference would be a lot more than 1 (e.g. 55)"
$gtm_dist/mumps -run verify^gtm9102
cd ..

echo "# Run dbcheck.csh"
$gtm_tst/com/dbcheck.csh

