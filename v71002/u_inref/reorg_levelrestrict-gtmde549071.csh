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
GTM-DE549701 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-002_Release_Notes.html#GTM-DE549071)

MUPIP REORG traverses all index blocks and achieves a compact and optimally-structured database with a single pass. Previously, REORG failed to visit certain categories of blocks, including the root block and blocks it newly created or modified, and it required an indefinite number of passes to achieve optimal block structure. As a workaround for previous releases, users may consider repeating REORG operations until the command reports few blocks coalesced and split. In addition, REORG now recognizes a new qualifier, -MIN_LEVEL=n, which specifies the minimum level of block it may process. The default is -MIN_LEVEL=0. -MIN_LEVEL=1 instructs reorg only to process index blocks and can be understood as the REORG equivalent of an INTEG -FAST. (GTM-DE549071)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"

echo "### Test 1: MUPIP REORG -MIN_LEVEL=0"
echo "### This tests the above release note per the thread at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/684#note_2515981216"
echo "# Create a database"
setenv gtmgbldir T1.gld
$gtm_tst/com/dbcreate.csh T1 >& dbcreateT1.log
echo "# Populate the database with data using multiple subscripts"
$gtm_dist/mumps -run %XCMD 'for i=1:2:500 for j=1:1:10 for k=1:1:10 for l=1:1:10 set ^x(i,j,k,l)=$j(i_j_k_l,25)'
echo "# Run MUPIP REORG -MIN_LEVEL=0 to process all database blocks"
$gtm_dist/mupip reorg -min_level=0 -index_fill_factor=50 -reg "*" >&! T1reorg.log
echo "# Run MUPIP INTEG to check results of MUPIP REORG"
$gtm_dist/mupip integ -reg "*" >&! T1integ.log
echo "# Confirm all data blocks and index blocks processed"
set blocks_processed = `grep processed T1reorg.log | tr -d ' ' | cut -f 2 -d ":"`
set index_blocks = `grep Index T1integ.log | tr -s ' ' | cut -f 2 -d " "`
set data_blocks = `grep Data T1integ.log | tr -s ' ' | cut -f 2 -d " "`
@ combined_blocks = $index_blocks + $data_blocks
if ($blocks_processed == $combined_blocks ) then
	echo "PASS: All index blocks and data blocks processed by MUPIP REORG -MIN_LEVEL=0."
else
	echo "FAIL: $index_blocks index blocks and $data_blocks data blocks present, but only $blocks_processed processed."
endif
echo

echo "### Test 2: MUPIP REORG -MIN_LEVEL=1"
echo "### This tests the above release note per the thread at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/684#note_2515981216"
echo "# Create a database"
setenv gtmgbldir T2.gld
$gtm_tst/com/dbcreate.csh T2 >& dbcreateT2.log
echo "# Populate the database with data using multiple subscripts"
$gtm_dist/mumps -run %XCMD 'for i=1:2:500 for j=1:1:10 for k=1:1:10 for l=1:1:10 set ^x(i,j,k,l)=$j(i_j_k_l,25)'
echo "# Run MUPIP REORG -MIN_LEVEL=1 to process only index blocks at or above block level 1"
$gtm_dist/mupip reorg -min_level=1 -index_fill_factor=50 -reg "*" >&! T2reorg.log
echo "# Run MUPIP INTEG to check results of MUPIP REORG"
$gtm_dist/mupip integ -reg "*" >&! T2integ.log
echo "# Confirm only index blocks processed, not data blocks"
set blocks_processed = `grep processed T2reorg.log | tr -d ' ' | cut -f 2 -d ":"`
set index_blocks = `grep Index T2integ.log | tr -s ' ' | cut -f 2 -d " "`
set data_blocks = `grep Data T2integ.log | tr -s ' ' | cut -f 2 -d " "`
if ($blocks_processed == $index_blocks ) then
	echo "PASS: Only index blocks were processed by MUPIP REORG -MIN_LEVEL=1."
else
	echo "FAIL: MUPIP REORG -MIN_LEVEL=1 specified, but data blocks processed."
endif
echo

echo "### Test 3: MUPIP REORG -MIN_LEVEL=2"
echo "### This tests the above release note per the comment at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/684#note_2544003501"
echo "# Create a database"
setenv test_reorg "NON_REORG"
setenv gtmgbldir T3.gld
$gtm_tst/com/dbcreate.csh T3 1 255 1000 -block_size=1024  >& dbcreateT3.log
echo "# Fill the database so that there are > 2 block levels"
echo "# using a generated routine from reorg/u_inref/hightree.csh."
$gtm_dist/mumps -run %XCMD 'for i=1:1:50000 set ^a(i,$j(i,150),i,i*2)=$j(i,50)'
echo "# Run MUPIP REORG -MIN_LEVEL=2 to process only index blocks at or above block level 2"
# $gtm_dist/mupip reorg -min_level=2 -index_fill_factor=50 -reg "*" >&! T3reorg.log
$gtm_dist/mupip reorg -min_level=2 -index_fill_factor=50 -reg "*" >&! T3reorg.log
echo "# Run MUPIP INTEG to check results of MUPIP REORG"
$gtm_dist/mupip integ -reg "*" >&! T3integ.log
echo "# Confirm there are blocks at level 2"
echo 'dump -block=3 -header' | $gtm_dist/dse
echo
echo "# Confirm that the number of blocks processed is the same as the number of index blocks at block level 2 or higher"
set blocks_processed = `grep processed T3reorg.log | tr -d ' ' | cut -f 2 -d ":"`
$gtm_dist/mumps -run gtmde549071 | $gtm_dist/dse | & grep '^Block' | grep -vE "Level 0 |Level -1 |Level 1 " >&! T3indexblocks.out
set index_blocks = `wc -l T3indexblocks.out | cut -f 1 -d " "`
if ($blocks_processed == $index_blocks ) then
	echo "PASS: Data blocks at level 0 and index blocks at level 1 were not processed by MUPIP REORG -MIN_LEVEL=2."
else
	echo "FAIL: MUPIP REORG -MIN_LEVEL=2 specified, but level 0 or level 1 blocks were processed ($blocks_processed != $index_blocks)."
endif

$gtm_tst/com/dbcheck.csh >& dbcheck.log
