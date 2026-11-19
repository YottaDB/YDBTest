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

echo "#----------------------------------------------------------------------------------------------------#"
echo '# [YDB#1407] ZYENCODE does not corrupt memory after JSON strings that are canonical numbers          #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# ZYDECODE stores a JSON string that is a canonical number, such as "123", with a $CHAR(0) prefix, so'
echo '# that M does not treat it as a number. ZYENCODE reads each value at one level into one buffer, and'
echo '# to write such a value without its prefix it moved the start of that buffer past the prefix and'
echo '# left it there. So each such value moved the buffer one byte further, while its size stayed the'
echo '# same, and a long value after enough of them was written past the end of the buffer, corrupting'
echo '# the heap and terminating the process.'
echo '#'
echo '# Each stage sets 20000 such values and then a value of 1048000 bytes at the same level, encodes it'
echo '# with ZYENCODE, decodes the JSON with ZYDECODE, and checks that every node comes back unchanged. A'
echo '# JSON object and a JSON array are encoded by different code, and ZYENCODE sizes its buffer'
echo '# differently for a local and for a global variable, so each runs with both. Every stage fails'
echo '# without the fix.'
echo

cp $gtm_tst/$tst/inref/ydb1407.m .

$gtm_tst/com/dbcreate.csh mumps -record_size=1048576 >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

echo '# Stage 1 : object, local variable'
echo '# Command : $ydb_dist/yottadb -run object^ydb1407 0'
echo '# Before the fix : glibc "corrupted size vs. prev_size", then an assert (Debug) or KILLBYSIGSINFO1 (Release)'
echo '# With the fix   : expect the JSON object, and PASS for the decoded JSON'
$ydb_dist/yottadb -run object^ydb1407 0
echo

echo '# Stage 2 : object, global variable'
echo '# Command : $ydb_dist/yottadb -run object^ydb1407 1'
echo '# Before the fix : glibc "double free or corruption (\!prev)", then an assert (Debug) or KILLBYSIGSINFO1 (Release)'
echo '# With the fix   : expect the JSON object, and PASS for the decoded JSON'
$ydb_dist/yottadb -run object^ydb1407 1
echo

echo '# Stage 3 : array, local variable'
echo '# Command : $ydb_dist/yottadb -run array^ydb1407 0'
echo '# Before the fix : glibc "corrupted size vs. prev_size", then an assert (Debug) or KILLBYSIGSINFO1 (Release)'
echo '# With the fix   : expect the JSON array, and PASS for the decoded JSON'
$ydb_dist/yottadb -run array^ydb1407 0
echo

echo '# Stage 4 : array, global variable'
echo '# Command : $ydb_dist/yottadb -run array^ydb1407 1'
echo '# Before the fix : glibc "double free or corruption (\!prev)", then an assert (Debug) or KILLBYSIGSINFO1 (Release)'
echo '# With the fix   : expect the JSON array, and PASS for the decoded JSON'
$ydb_dist/yottadb -run array^ydb1407 1
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif

echo "# Done"
