#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

setenv gtm_test_db_format "NO_CHANGE"

echo "# Create the DB"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif
echo ""

echo "# Create a variable with 31 characters, the maximum length"
$ydb_dist/mumps -run ^%XCMD 'set ^abcdefghijklmnopqrstuvwxyzabcde=11'
echo ""
echo "# Create a too-long global name by appending 4 more non-zero bytes to an existing global name record"
$ydb_dist/dse overwrite -block=2 -offset=33 -data="\66\67\68\69"
echo ""

echo "# Perform a MUPIP INTEG"
$MUPIP INTEG -reg "*"
echo ""

echo "# Skip DB check (the subtest has ensured a DB check will fail)"
