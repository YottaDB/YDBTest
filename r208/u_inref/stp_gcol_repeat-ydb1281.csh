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
echo '# [YDB#1281] VIEW "STP_GCOL" does not expand the stringpool when it reclaims no space                #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# op_view.c asked the garbage collector for one byte more than the free space in the stringpool. When'
echo '# nothing had been allocated since the previous garbage collection, nothing was reclaimed, so the'
echo '# stringpool had to expand, by a factor approaching 2 as the calls repeated.'
echo '#'
echo '# Stages 1 and 2 fail without the fix: 12 calls in a row take the stringpool from 96KiB to about'
echo '# 79MiB. Stage 3 passes without the fix too; it checks that VIEW "STP_GCOL" still reclaims space.'
echo '#'
echo '# Each stage runs in its own process, so each starts from a new stringpool.'
echo

cp $gtm_tst/$tst/inref/ydb1281.m .

echo '# Stage 1 : VIEW "STP_GCOL_NOSORT":0, then VIEW "STP_GCOL" 12 times in a row'
echo '# Command : $ydb_dist/yottadb -run repeat^ydb1281 0'
echo '#   expect the stringpool size to be unchanged'
$ydb_dist/yottadb -run repeat^ydb1281 0
echo

echo '# Stage 2 : VIEW "STP_GCOL_NOSORT":1, then VIEW "STP_GCOL" 12 times in a row'
echo '# Command : $ydb_dist/yottadb -run repeat^ydb1281 1'
echo '#   expect the stringpool size to be unchanged'
$ydb_dist/yottadb -run repeat^ydb1281 1
echo

echo '# Stage 3 : VIEW "STP_GCOL", create 20 strings of 1000 bytes that are garbage by the end, then VIEW "STP_GCOL"'
echo '# Command : $ydb_dist/yottadb -run reclaim^ydb1281'
echo '#   expect bytes in use to grow by at least 20000, then drop back to within 2048 bytes of the start'
$ydb_dist/yottadb -run reclaim^ydb1281
echo

echo "# Done"
