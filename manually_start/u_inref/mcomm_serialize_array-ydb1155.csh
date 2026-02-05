#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# ------------------------------------------------------------------------------------------------'
echo '# Test M command to serialize and deserialize local or global variable subtrees larger than 4 GiBs'
echo '# ------------------------------------------------------------------------------------------------'
echo

setenv gtm_test_jnl NON_SETJNL
setenv ydb_stp_gcol_nosort 0
setenv gtmdbglvl 0x00400000	# Set this to bypass the 2 GiB sanity check in gtm_memcpy_validate_and_execute() in dbg builds

$gtm_tst/com/dbcreate.csh mumps -key_size=512 -record_size=1048576 >& dbcreate.out

echo "# Test ZYENCODE and ZYDECODE on local and global variable that encodes to a JSON string larger than 4 GiBs"
echo
echo "## Call local^ydb1155 to test the ZYENCODE and ZYDECODE commands on large M arrays"
echo
$ydb_dist/yottadb -run local^ydb1155
echo
echo "## Call global^ydb1155 to test the ZYENCODE and ZYDECODE commands on large M arrays"
echo
$ydb_dist/yottadb -run global^ydb1155
echo

which jq >& /dev/null
if ($status == 1) then
	echo "ERROR: 'jq' utility not installed. Please install 'jq' before running this test."
else
	echo "# Check all ZYENCODE JSON output files for valid JSON"
	foreach file (`ls *.json`)
		jq . $file >& $file.jq.out
		if (0 == $status) then
			echo "PASS: $file contains valid JSON"
		else
			echo "FAIL: $file does not contain valid JSON"
		endif
	end
endif
echo

$gtm_tst/com/dbcheck.csh mumps >& dbcheck.out
