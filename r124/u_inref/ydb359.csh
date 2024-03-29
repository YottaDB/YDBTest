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
echo '# Test that ZSTEP actions continue to work after a MUPIP INTRPT if $ZINTERRUPT is appropriately set'
echo '# Invoke "do ^sstep" in ydb359.m at the beginning so it prints each M line as it executes'
echo "# Send a MUPIP INTRPT to self in between"
echo '# Expect the M line printing to continue even after the MUPIP INTRPT'
echo '# Note: The first M line after MUPIP INTRPT is not displayed. But remaining lines are. Not sure why.'
echo '#       But this behavior is the same in GT.M V7.0-001 and YottaDB r2.00.'
echo ""

$ydb_dist/mumps -run ydb359
