#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Test DSE REMOVE -RECORD does not SIG-11 in case of DBCOMPTOOLRG integrity error"

$gtm_tst/com/dbcreate.csh mumps

echo "# Set global node ^x=1"
$ydb_dist/yottadb -run %XCMD 'set ^x=1'
echo "# Create DBCOMPTOOLRG integrity error by adding a record using DSE"
$ydb_dist/dse add -block=3 -rec=2 -key=^x -data="\FF\FF\FF\00"
echo "# Delete first record in block with DBCOMPTOOLRG integrity error by doing DSE REMOVE -RECORD"
echo "# This used to SIG-11 without the YDB#741 code fixes"
$ydb_dist/dse remove -block=3 -rec=1

$gtm_tst/com/dbcheck.csh

