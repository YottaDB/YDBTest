#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "A regression was introduced in GT.M V6.3-006 that produced an"
echo "assert failure or a GTMCHECK fatal error when this script was"
echo "executed. This was fixed as part of V6.3-009. This test"
echo "functions as a test for both YottaDB issue ydb441 and GT.M issue"
echo "gtm-9114 verifying that auto-ZLINK works properly when zlinking"
echo "a new version of an M routine after changing ZROUTINES."
mkdir -p patch
touch bar.m
$ydb_dist/mumps -run %XCMD 'ZCompile "bar"'; mv bar.o ./patch
$ydb_dist/mumps -run %XCMD 'ZCompile "bar"'; mv bar.o ./patch/bar2.o
cat > base.m << CAT_EOF
        ZLink "bar"
        Set \$ZROutines="./patch"
        Do ^bar2
CAT_EOF
$ydb_dist/mumps -run base
