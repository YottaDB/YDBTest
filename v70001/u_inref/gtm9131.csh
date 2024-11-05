#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-9131 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-001_Release_Notes.html#GTM-9131)

LOGTPRESTART appropriately identifies restarts associated with extensions of a statsdb database;
Previously, it inappropriately identified these as caused by a BITMAP conflict. GT.M doubles the
block count with each statsdb size increase; Previously, GT.M used a fixed extension size of 2050
blocks. GT.M saves the database block count after each extension and uses it as the initial size for
any subsequent recreation of the statsdb database during the life of the associated database file;
Previously, GT.M always created a statsdb database with 2050 blocks, which is still the initial size
for such a database file when the corresponding database is first created. (GTM-9131)
CAT_EOF

setenv ydb_test_4g_db_blks 0  # Disable debug-only huge db scheme as it does not work with MM (statsdb uses MM)

# With encryption turned on, the TPRESTART message expected by this subtest does not show up.
# It is not clear exactly why but it is not considered important to figure that out given we do
# see the message with -noencrypt. Since -noencrypt does verify the intent of this subtest, we disable -encrypt.
setenv test_encryption NON_ENCRYPT

echo "#--------------------------------------------------------------------------------------------"
echo "# Verify TPRESTART messages properly identifies global name in case of statsdb extension restarts"
echo "#--------------------------------------------------------------------------------------------"
#
echo '# Create multi-region database (needed for TP restart in the statsdb)'
$gtm_tst/com/dbcreate.csh mumps 2

echo "# Set 128 blocks as the allocation for the STATSDB to get statsdb file extension sooner"
echo "# 128 blocks would cause extension if 128 processes start up at the same time"
echo "# Default value of 2050 blocks would need 2050 processes which would make this test not runnable on most systems"
echo "# Sort the output as the reigon names will show up in ftok order otherwise (non-deterministic)"
$MUPIP set -statsdb_allocation=128 -reg "*" |& sort

set syslog_before1 = `date +"%b %e %H:%M:%S"`
echo "# Execute [mumps -run gtm9131] which will create a TPRESTART message due to a statsdb database file extension restart"
$gtm_dist/mumps -run gtm9131
$gtm_tst/com/getoper.csh "$syslog_before1" "" test_syslog.txt

echo "# Verify TPRESTART message was seen in syslog with a proper global name (i.e. containing ^%YGS)"
echo "# Before r2.00, the global name (glbl: field in this message) used to be a misleading ^*BITMAP."
echo "# Note: The .dat.gst file name could be non-deterministic (based on ftok order of mumps.dat or a.dat)."
echo "# Note: Also sometimes we get 2 TPRESTART messages. One from mumps.dat.gst and one from a.dat.gst."
echo "# Note: Not sure what the cause is but is not considered important so we take just the first message."
set parentpid = `head -1 pidlist.txt`
$grep "\[$parentpid\]: %...-I-TPRESTART" test_syslog.txt | head -1

echo '# Validate DB'
$gtm_tst/com/dbcheck.csh

echo "#------------------------------------------------------------------"
echo "# Verify STATSDB allocation doubles each time and a few other tests"
echo "#------------------------------------------------------------------"
echo "# Create single-region database"
$gtm_tst/com/dbcreate.csh mumps
echo "# Verify initial statsdb database size is close to 2050 blocks (by default) by examining total blocks count"
$gtm_dist/mumps -run dbsize^gtm9131
echo "# Set statdb allocation to 128 blocks (minimum value supported) to start with"
$MUPIP set -statsdb_allocation=128 -reg "*"
echo "# Start process in background to have DEFAULT region open for the duration of the test"
$gtm_dist/mumps -run job^gtm9131 1 2	# parameter 1 indicates 1 job to start, parameter 2 indicates jobid=2
echo "# Verify initial statsdb allocation size is indeed close to 128 by examining total blocks count in statsdb"
$gtm_dist/mumps -run dbsize^gtm9131
echo "# Start 128 more processes in background to kick in first statsdb extension"
$gtm_dist/mumps -run job^gtm9131 128 3	# parameter 128 indicates 128 jobs to start, parameter 3 indicates jobid=3
echo "# Verify new statsdb file size is indeed close to 2*128 by examining total blocks count in statsdb"
$gtm_dist/mumps -run dbsize^gtm9131
echo "# Start 256 more processes in background to kick in second statsdb extension"
$gtm_dist/mumps -run job^gtm9131 256 4	# parameter 256 indicates 256 jobs to start, parameter 4 indicates jobid=4
echo "# Verify new statsdb file size is indeed close to 2*2*128 by examining total blocks count in statsdb"
$gtm_dist/mumps -run dbsize^gtm9131
echo "# Stop ALL background processes"
$gtm_dist/mumps -run stop^gtm9131 4	# parameter 2 indicates stop all jobs started with jobid=4
$gtm_dist/mumps -run stop^gtm9131 3	# parameter 2 indicates stop all jobs started with jobid=3
$gtm_dist/mumps -run stop^gtm9131 2	# parameter 2 indicates stop all jobs started with jobid=2
echo "# Verify initial recreated statsdb file size is saved database block count from most recent previous statsdb extension"
echo "# We expect to see total block count close to 2*2*128 (most recent statsdb file size above)"
echo "# The total block count varies between 517 and 518. Not sure exactly why."
echo "# But it is not considered important enough so we allow both values below."
$gtm_dist/mumps -run dbsize^gtm9131
echo '# Validate DB'
$gtm_tst/com/dbcheck.csh

