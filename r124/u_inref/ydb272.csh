#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "-----------------------------------------------------------------------------------------"
echo "# Test that the environment variable ydb_poollimit is honored by MUMPS and DSE."
echo "-----------------------------------------------------------------------------------------"

# Set acc_meth to BG because DRD does not behave appropriately in MM mode.
setenv acc_meth BG

echo "# Create database with two regions, DEFAULT and AREG"
$gtm_tst/com/dbcreate.csh mumps 2 >& dbcreate.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate.out
	exit -1
endif
echo ""
echo "# Test that MUMPS honors ydb_poollimit"

echo "# Set ydb_poollimit to 32"
setenv ydb_poollimit 32
echo "# Set the POOLLIMIT in AREG to 64"
echo '# Test that $view() returns the correct POOLLIMIT value for DEFAULT and AREG'
$ydb_dist/mumps -run check^ydb272

echo "-----------------------------------------------------------------------------------------"

echo "# Test that DSE honors ydb_poollimit"
echo "# Generate a text file with various dump commands"
$ydb_dist/mumps -run dseinp^ydb272

echo "# Using the DRD statistic to measure how many blocks are read from disk."
echo "# dse.inp contains 66 DSE DUMP commands to be read."
echo ""
echo "# With ydb_poollimit set to 32, DRD value should be 0x42 (66 in decimal)"
echo "# With POOLLIMIT set to 32, the DSE process will read the first 32 Blocks from disk"
echo "# and write into the global buffer cache, which has 32 spaces."
echo "# When the 33rd Block is read, since there is no space in the buffer, it will overwrite"
echo "# the oldest global buffer cache position, which is Block 0."
echo "# When Block 0 is read for the second time, it has to be read from disk and overwrites"
echo "# the next oldest global buffer position, which is Block 1."
echo "# When Block 1 is read for the second time, it follows this pattern, and so on."
setenv ydb_poollimit 32 ; source $gtm_tst/$tst/u_inref/dse.csh
echo ""
echo "# With ydb_poollimit set to 33, DRD value should be 0x21 (33 in decimal)"
echo "# With POOLLIMIT set to 33, the DSE process will read the first 33 Blocks from disk"
echo "# and write into the global buffer cache, which has 33 spaces. Since the last 33"
echo "# Blocks are duplicate, each remaining read block request does not need to read"
echo "# from disk, and can instead read from the global buffer cache"
setenv ydb_poollimit 33 ; source $gtm_tst/$tst/u_inref/dse.csh


echo ""

echo "# Check database"
$gtm_tst/com/dbcheck.csh mumps >& dbcheck.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck.out
	exit -1
endif
