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
echo '# [YDB#1304] ZYDECODE of a local variable accepts a computed number in its root or a chunk           #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# A value computed by an arithmetic expression, such as i-1, has a numeric form but no string form'
echo '# until something such as WRITE or ZWRITE forces one. op_zydecode() read the string length of the'
echo '# root node and of each chunk node of a local source without forcing a string form, so it read'
echo '# whatever was left in those fields. A computed root could issue ZYDECODEWRONGCNT for a valid'
echo '# count, and a computed chunk could issue LVUNDEF for a node that is defined, or be decoded as the'
echo '# wrong value with no error.'
echo '#'
echo '# op_zydecode() has a separate branch for a local and for a global destination, so each case runs'
echo '# with both. Stages 1 to 6 fail without the fix. Stages 7 to 10 pass without the fix too; they check'
echo '# that a root that is not a positive integer, and a chunk that is empty, missing, or has no value,'
echo '# still issue the same errors as before.'
echo '#'
echo '# Each stage runs in its own process, since the bug showed up reliably only on the first ZYDECODE in'
echo '# a process.'
echo

cp $gtm_tst/$tst/inref/ydb1304.m .

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

echo '# Stage 1 : computed root (src=i-1), local destination'
echo '# Command : $ydb_dist/yottadb -run root^ydb1304 0'
echo '#   expect dst("a")=1'
$ydb_dist/yottadb -run root^ydb1304 0
echo

echo '# Stage 2 : computed root (src=i-1), global destination'
echo '# Command : $ydb_dist/yottadb -run root^ydb1304 1'
echo '#   expect ^dst("a")=1'
$ydb_dist/yottadb -run root^ydb1304 1
echo

echo '# Stage 3 : computed chunk in the middle of the JSON (src(2)=i+40), local destination'
echo '# Command : $ydb_dist/yottadb -run chunk^ydb1304 0'
echo '#   expect dst(0)=1 and dst(1)=42'
$ydb_dist/yottadb -run chunk^ydb1304 0
echo

echo '# Stage 4 : computed chunk in the middle of the JSON (src(2)=i+40), global destination'
echo '# Command : $ydb_dist/yottadb -run chunk^ydb1304 1'
echo '#   expect ^dst(0)=1 and ^dst(1)=42'
$ydb_dist/yottadb -run chunk^ydb1304 1
echo

echo '# Stage 5 : computed root (src=i+1) and computed chunk (src(2)=i+40), local destination'
echo '# Command : $ydb_dist/yottadb -run both^ydb1304 0'
echo '#   expect dst(0)=1 and dst(1)=42'
$ydb_dist/yottadb -run both^ydb1304 0
echo

echo '# Stage 6 : computed root (src=i+1) and computed chunk (src(2)=i+40), global destination'
echo '# Command : $ydb_dist/yottadb -run both^ydb1304 1'
echo '#   expect ^dst(0)=1 and ^dst(1)=42'
$ydb_dist/yottadb -run both^ydb1304 1
echo

echo '# Stage 7 : roots that are not a positive integer: "" and a computed 0, local destination'
echo '# Command : $ydb_dist/yottadb -run badroot^ydb1304 0'
echo '#   expect ZYDECODEWRONGCNT for each'
$ydb_dist/yottadb -run badroot^ydb1304 0
echo

echo '# Stage 8 : roots that are not a positive integer: "" and a computed 0, global destination'
echo '# Command : $ydb_dist/yottadb -run badroot^ydb1304 1'
echo '#   expect ZYDECODEWRONGCNT for each'
$ydb_dist/yottadb -run badroot^ydb1304 1
echo

echo '# Stage 9 : a chunk that is "", a chunk that is missing, and a chunk with only a descendant, local destination'
echo '# Command : $ydb_dist/yottadb -run badchunk^ydb1304 0'
echo '#   expect LVUNDEF for src(2) each time'
$ydb_dist/yottadb -run badchunk^ydb1304 0
echo

echo '# Stage 10 : a chunk that is "", a chunk that is missing, and a chunk with only a descendant, global destination'
echo '# Command : $ydb_dist/yottadb -run badchunk^ydb1304 1'
echo '#   expect LVUNDEF for src(2) each time'
$ydb_dist/yottadb -run badchunk^ydb1304 1
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif

echo "# Done"
