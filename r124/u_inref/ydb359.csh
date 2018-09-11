#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Test that ZSTEP actions continue to work after a MUPIP INTRPT"
echo '# Invoke "do ^sstep" in ydb359.m at the beginning so it prints each M line as it executes'
echo "# Send a MUPIP INTRPT to self in between"
echo "# Expect the M line printing to continue even after the MUPIP INTRPT"
echo "# Note that the M line that is first executed to handle the MUPIP INTRPT will not be printed even with #359 fixes."
echo "# This is because, the transfer table entry for OC_LINESTART at the start of that line will handle the MUPIP INTRPT request"
echo "# So the ZSTEP activity will resume only from the following M line onwards. But that is still better than never resuming"
echo "#     which was the case prior to #359 fixes"
echo ""

$ydb_dist/mumps -run ydb359
