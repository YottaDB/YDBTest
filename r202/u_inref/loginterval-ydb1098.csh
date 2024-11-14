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

echo "# This is to test the frequency at which the source server log file emits output."
if (! $?test_replic) then
	echo "This subtest is applicable only with -replic. Exiting."
	exit
endif

echo "# Create a new empty database so we can run an M program."
$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out

echo "# Run 50000 transactions and make sure exactly 5 logs are emitted."
$gtm_dist/mumps -run ydb1098loginterval
echo "# Validate that the sequence numbers in REPL INFO messages are 10000 transactions apart."
echo "# On ARM, these numbers have been observed to vary between 1 and 100 of the expected value."
echo "# Permit a variance of up to 500, as long as we don't see more logs than we expect."
$grep -o 'Seqno : [0-9]*' SRC_*.log | $tst_awk -f $gtm_tst/$tst/inref/ydb1098.awk

echo "# Shutdown the servers and verify they match."
$gtm_tst/com/dbcheck.csh -extract >& dbcheck.out
#==================================================================================================================================
