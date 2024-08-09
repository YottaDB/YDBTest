#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-005_Release_Notes.html#GTM-DE340860)

MUPIP BACKUP does not leave temporary files when there in an error during the copy phase for a
multi-region backup. Previously, MUPIP BACKUP incorrectly left temporary files when there was an error
during the copy phase for any region except the first. (GTM-DE340860)

CAT_EOF

setenv ydb_prompt 'GTM>'	# So can run the test under GTM or YDB
setenv ydb_msgprefix "GTM"	# So can run the test under GTM or YDB

# This test moves the DEFAULT region database file from current directory to /tmp.
# We have seen EINVAL errors when an AIO db is attempted to be opened from /tmp so disable AIO for this test
# as it is not central to the objective of this test anyways.
setenv gtm_test_asyncio 0

echo '# Create 2-region database (AREG and DEFAULT)'
$gtm_tst/com/dbcreate.csh mumps 2 -stdnull

echo '# We want to induce an error in the copy phase of the second region. Towards that we let AREG database'
echo '# file stay in the current directory and keep DEFAULT database file in /tmp (see Test 1c in'
echo '# v70001/u_inref/gtm9424.csh for more details).'
# pick unique name that will not collide with other users/tests
set default_dbfile = /tmp/mumps_${user}_$$.dat
$gtm_dist/mumps -run GDE change -segment DEFAULT -file=$default_dbfile

echo '# Recreate DEFAULT database to point to /tmp'
$gtm_dist/mupip create -reg=DEFAULT

echo '# Now attempt a mupip backup on both AREG and DEFAULT where the target is [bkpdir] a subdirectory in the current directory.'
echo '# AREG backup should work fine but we would see an EXDEV error while trying to backup DEFAULT database.'
echo '# In GT.M V7.0-004 and older versions, this would cause temporary files to be left over and an [Error removing temp dir]'
echo '# error message displayed. In GT.M V7.0-005 and above, this error would not show up.'
mkdir bkpdir
$MUPIP backup "*" bkpdir >& backup.out
# Journaling and db tn are randomly set by test framework so filter those out from the reference file to keep it deterministic.
$grep -vE "FILERENAME|JNLCREATE|BACKUPTN" backup.out

echo '# Check the contents of [bkpdir] to ensure no leftover temporary files.'
echo '# Run [ls -la bkpdir]. We only expect to see a.dat and mumps.dat. Nothing else.'
echo '# When run with GT.M V7.0-004, we would see subdirectories like [DEFAULT_64441__1.tmp/] show up.'
ls -la bkpdir | tail -n +4 | $tst_awk '{print $NF}'

echo '# Validate DB'
$gtm_tst/com/dbcheck.csh

# Move DEFAULT region db file from /tmp to current directory in case it is needed for test failure analysis
mv $default_dbfile .

