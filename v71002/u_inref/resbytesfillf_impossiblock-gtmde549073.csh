#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
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
GTM-DE549073- Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-002_Release_Notes.html#GTM-DE549073)

MUPIP REORG enforces a minimum target block size of the block size minus the maximum reserved bytes. Previously, GT.M failed to reject a combination of reserved bytes and -fill_factor which effectively reserved a space larger than the database block size and caused database damage. Users of previous releases should use either reserved bytes or -fill_factor, but not both, as a means of achieving REORG sparseness. (GTM-DE549073)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"
setenv gtm_test_use_V6_DBs 0

echo "### Test MUPIP REORG enforces minimum target block size combination of reserve bytes and minimum block size"
echo "# Create a database"
setenv gtmgbldir T1.gld
$gtm_tst/com/dbcreate.csh T1 -block_size=1024 >& dbcreateT1.log
echo "# Set a value for -RESERVED_BYTES that approaches the limit for reserved bytes (920)"
@ randbytes = `$gtm_dist/mumps -run rand 400 1 0`
@ resbytes = 512 + $randbytes
echo $resbytes >&! resbytes.txt
$gtm_dist/mupip set -reserved_bytes=$resbytes -reg '*'
echo "# Populate the database with data using multiple subscripts"
$gtm_dist/mumps -run %XCMD 'for i=1:2:500 for j=1:1:10 for k=1:1:10 for l=1:1:10 set ^x(i,j,k,l)=$j(i_j_k_l,25)'
echo "# Run MUPIP REORG -FILL_FACTOR=50 to create a conflict with previously set -RESERVED_BYTES"
echo "# Expect MUPIP REORG to complete successfully. Previously, it emitted an assert failure like:"
echo "# %GTM-F-ASSERT, Assert failed in SRC_PATH/sr_port/reorg_funcs.c line 106 for expression ((first_key != second_key) || mu_upgrade_in_prog)"
echo "# See https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2349#note_2565749924 for more details on expected output."
$gtm_dist/mupip reorg -fill_factor=50 -reg "*" >& T1reorg.log
# In rare cases, an additional line saying "REORG may be incomplete for this global" is emitted by MUPIP REORG.
# In that case, remove it since it is not relevant to the test and cannot be
# handled using SUSPEND_OUTPUT, which doesn't support distinctions based on specific V6 versions.
# Also, a "Levels Increased" line from MUPIP REORG may be included, depending on how the REORG
# was completed. It is not clear what causes this line to be included. Nevertheless, since this line
# is not strictly among the changes under test, omit it from the test output to prevent test failures.
grep -v "REORG may be incomplete for this global." T1reorg.log | grep -v "Levels Increased"
$gtm_tst/com/dbcheck.csh
