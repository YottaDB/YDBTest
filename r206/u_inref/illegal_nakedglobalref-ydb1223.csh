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

echo '#-------------------------------------------------------------------------#'
echo '# [YDB#1223] Test fix for illegal naked global reference in release r2.04'
echo '#-------------------------------------------------------------------------#'
echo

$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out

echo '## Test 1: Run [ydb1223a.m] with `quit system` line enabled'
echo '## For test case source, see: https://gitlab.com/YottaDB/DB/YDB/-/work_items/1223#note_3266885297'
echo '# Expect [SystemVersion=24.1.12] twice. Previously, with r2.04, this routine:'
echo '# 1. Left the second value of [SystemVersion] empty.'
echo '# 2. Issued a GVNAKED error with PRO builds and GVDBGNAKEDUNSET with DBG builds'
$ydb_dist/yottadb -r ydb1223a
echo

echo '## Test 2: Run [ydb1223a.m] with `quit system` line disabled'
echo '## For test case source, see: https://gitlab.com/YottaDB/DB/YDB/-/work_items/1223#note_3271149622'
echo '# Expect [SystemVersion=24.1.12] twice. Previously, with r2.04, this routine:'
echo '# 1. Left the second value of [SystemVersion] empty.'
echo '# 2. Issued a GVNAKED error with PRO builds and GVDBGNAKEDUNSET with DBG builds'
cp $gtm_tst/$tst/inref/ydb1223a.m ydb1223a2.m
sed -i 's/quit system/; quit system/g' ydb1223a2.m
$ydb_dist/yottadb -r ydb1223a2
echo

echo '## Test 3: Run [ydb1223b.m] using SET on GVN with 1 subscript'
echo '## For test case source, see: https://gitlab.com/YottaDB/DB/YDB/-/work_items/1223#note_3272316062'
echo '# Expect a YDB-E-GVUNDEF error for [^x]. Previously, with r2.04, this routine:'
echo '# 1. With PRO builds: silently updated the wrong global, i.e. [^x(1)] instead of [^y(1)], and issued no errors.'
echo '# 2. With DBG builds: issued a GVDBGNAKEDMISMATCH error.'
$ydb_dist/yottadb -r ydb1223b
echo

echo '## Test 4: Run [ydb1223b.m] using SET on GVN with 2 subscripts'
echo '## For test case source, see: https://gitlab.com/YottaDB/DB/YDB/-/work_items/1223#note_3272316062'
echo '# Expect a YDB-E-GVUNDEF error for [^x]. Previously, with r2.04, this routine:'
echo '# 1. With PRO builds: silently updated the wrong global, i.e. [^x(1)] instead of [^y(1,2)], and issued no errors.'
echo '# 2. With DBG builds: issued a GVDBGNAKEDMISMATCH error.'
cp $gtm_tst/$tst/inref/ydb1223b.m ydb1223b2.m
sed -i 's/y(1)/y(1,2)/g' ydb1223b2.m
$ydb_dist/yottadb -r ydb1223b2
echo

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
