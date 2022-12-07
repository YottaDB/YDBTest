#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

echo '######################################################################################################'
echo '# Test that ACTLSTTOOLONG and FMLLSTMISSING errors print SRCLOC message with line/column number detail'
echo '######################################################################################################'

cp $gtm_tst/$tst/inref/ydb729.m ydb729.m

echo ''
echo '# Test [yottadb ydb729.m] i.e. compile time. Expect ACTLSTTOOLONG/FMLLSTMISSING errors with SRCLOC messages'
echo ''
$ydb_dist/yottadb ydb729.m
rm -f ydb729.o

echo ''
echo '# Test [zlink ydb729.m] i.e. compile during runtime. Expect ACTLSTTOOLONG/FMLLSTMISSING errors with SRCLOC messages'
echo ''
$ydb_dist/yottadb -direct << YDB_EOF
	zlink "ydb729.m"
YDB_EOF

echo ''
echo '# Test [do ^ydb729] i.e. no compile, only runtime. Expect ACTLSTTOOLONG/FMLLSTMISSING errors with NO SRCLOC messages'
echo ''
$ydb_dist/yottadb -run ydb729

