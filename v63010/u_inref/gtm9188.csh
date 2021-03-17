#!/usr/local/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

cat >> gtm9188.m << xx
	write "ZCMDLINE = ",\$ZCMDLINE,!
xx

echo "This test checks that ZCMDLINE does not include direct or run when mumps/ydb is invoked with -run or -direct. Prior to V63010, 'run' or 'direct' could incorrectly appear in ZCMDLINE if extra spaces were inserted in the mumps/ydb command between mumps/ydb, the '-' and/or run/direct."

$echoline
echo "Testing 'mumps -direct'"
$ydb_dist/mumps -direct << YDB_EOF
	write "ZCMDLINE = ",\$ZCMDLINE,!
YDB_EOF

$echoline
echo "Testing 'mumps -dir'"
$ydb_dist/mumps -dir << YDB_EOF
	write "ZCMDLINE = ",\$ZCMDLINE,!
YDB_EOF

$echoline
echo "Testing 'mumps  -dir'"
$ydb_dist/mumps  -dir << YDB_EOF
	write "ZCMDLINE = ",\$ZCMDLINE,!
YDB_EOF

$echoline
echo "Testing 'mumps  -direct'"
$ydb_dist/mumps  -direct << YDB_EOF
	write "ZCMDLINE = ",\$ZCMDLINE,!
YDB_EOF

$echoline
echo "Testing 'mumps - direct'"
$ydb_dist/mumps - direct << YDB_EOF
	write "ZCMDLINE = ",\$ZCMDLINE,!
YDB_EOF

$echoline
echo "Testing 'mumps - dir'"
$ydb_dist/mumps - dir << YDB_EOF
	write "ZCMDLINE = ",\$ZCMDLINE,!
YDB_EOF

$echoline
echo "Testing 'mumps  - direct'"
$ydb_dist/mumps  - direct << YDB_EOF
	write "ZCMDLINE = ",\$ZCMDLINE,!
YDB_EOF

$echoline
echo "Testing 'mumps - dir'"
$ydb_dist/mumps  - dir << YDB_EOF
	write "ZCMDLINE = ",\$ZCMDLINE,!
YDB_EOF

$echoline
echo "Testing 'mumps -run gtm9188'"
$ydb_dist/mumps -run gtm9188

$echoline
echo "Testing 'mumps  -run gtm9188'"
$ydb_dist/mumps  -run gtm9188

$echoline
echo "Testing 'mumps - run gtm9188'"
$ydb_dist/mumps - run gtm9188

$echoline
echo "Testing 'mumps  - run gtm9188'"
$ydb_dist/mumps  - run gtm9188
