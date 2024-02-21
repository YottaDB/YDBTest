#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv ydb_test_4g_db_blks 0	# Disable this random hugedb env var as it makes statsdb file integ output non-deterministic

echo "# Test that MUPIP INTEG -STATS does not SIG-11 and MUPIP TRIGGER does not assert fail if ydb_statshare=1"
echo "# Test of YDB#1047. See https://gitlab.com/YottaDB/DB/YDB/-/issues/1047#description for test details."
echo "# Before the YDB#1047 code fixes, the below test used to assert fail in MUPIP TRIGGER and SIG-11 in MUPIP INTEG -STATS"

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps

echo "# Set ydb_app_ensures_isolation env var to non-empty value"
setenv ydb_app_ensures_isolation "^x"

# Set ydb_statsdir to current directory to avoid statsdb files from getting created in /tmp
setenv ydb_statsdir .

echo "# Set ydb_statshare env var to 1"
setenv ydb_statshare 1

echo "# Try MUPIP TRIGGER command. This used to assert fail"
echo '+^ax(1,2,2) -commands=K -xecute="set x=1"' | $ydb_dist/mupip trigger -stdin

echo "# Try MUPIP INTEG -STATS command. This used to SIG-11"
$ydb_dist/mumps -run %XCMD 'view "statshare" zsystem "$ydb_dist/mupip integ -reg DEFAULT -stats"'

$gtm_tst/com/dbcheck.csh

