#################################################################
#								#
# Copyright (c) 2018-2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Test that MUPIP REORG on database file with non-zero RESERVED_BYTES does not cause integrity errors"
echo ""

echo "# Create database file with 4Kb block_size and record_size"
$gtm_tst/com/dbcreate.csh mumps -block_size=4096 -record_size=4096 >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

echo "# Set a single node in database that can randomly occupy upto one GDS block of space"
$ydb_dist/mumps -run ydb349

echo "# Set reserved_bytes on database to a random value from 0 to 4000 (maximum reserved bytes for 4Kb block_size)"
set randreservedbytes = `$ydb_dist/mumps -run genreservedbytes^ydb349`
$ydb_dist/mupip set -reserved=$randreservedbytes -reg "*" >& mu_set.log

echo "# Run MUPIP REORG with a random fill factor ranging from 0% to 100%"
echo "# Before #349 code fixes, this would fail with cores and/or produce DBINVGBL integrity errors"
set randfillfactor = `$ydb_dist/mumps -run genfillfactor^ydb349`
$ydb_dist/mupip reorg -reg "*" -fill=$randfillfactor >& mu_reorg.log

echo "# Do dbcheck.csh"
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
