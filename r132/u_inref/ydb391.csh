#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# Implementation of $ZYSU[FFIX]: Provide name equivalent to 128-bit hash'
echo '# Test $ZYSUFFIX on "SELECT * FROM NAMES" does not error'
$ydb_dist/yottadb -run ^%XCMD 'write $zysuffix("SELECT * FROM NAMES"),!'
echo '# Test $ZYSUFFIX on a variable'
$ydb_dist/yottadb -run ^%XCMD 'set x="SELECT * FROM NAMES" write $zysuffix(x),!'
echo '# Test $ZYSUFFIX produces 22 characters'
$ydb_dist/yottadb -run ^%XCMD 'write $length($zysuffix("SELECT * FROM NAMES")),!'
echo '# Test $ZYSU = $ZUSUFFIX'
$ydb_dist/yottadb -run ^%XCMD 'write $zysu("SELECT * FROM NAMES"),!'
echo '# Test $ZYSUFFF does not work'
$ydb_dist/yottadb -run ^%XCMD 'write $zysufff("SELECT * FROM NAMES"),!'
echo '# End of $ZYSUFFIX Test'
