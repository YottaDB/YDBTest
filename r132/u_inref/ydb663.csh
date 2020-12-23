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

echo "# This tests that a MUPIP LOAD of a binary extract from the same database"
echo "# will not produce a YDB-E-DBDUPNULCOL error. Previously, doing this would"
echo "# result in an erroneous YDB-E-DBDUPNULCOL error message for both historical"
echo "# and standard null subscript collation."

$echoline
echo "# Create database and set the null subscript collation type to historical"
$gtm_tst/com/dbcreate.csh mumpshist 1 -nostdnull -null_subscripts=TRUE
setenv ydb_gbldir mumpshist.gld

$echoline
echo "# Set a null subscript in database with historical collation"
$ydb_dist/mumps -run %XCMD 'set ^Y("")=3'

$echoline
echo "# Do a binary extract from database with historical collation"
$ydb_dist/mupip extract extrhist.bin -format=binary

$echoline
echo "# Load the binary extract with historical collation back into the same database"
$ydb_dist/mupip load -fo=binary extrhist.bin\

$echoline
echo "# Check database with historical collation for errors"
$gtm_tst/com/dbcheck.csh

$echoline
echo "# Create another database and set the null subscript collation type to standard"
setenv ydb_gbldir mumpsstd.gld
$gtm_tst/com/dbcreate.csh mumpsstd 1 -stdnull -null_subscripts=TRUE

$echoline
echo "# Set a null subscript in database with standard collation"
$ydb_dist/mumps -run %XCMD 'set ^Y("")=3'

$echoline
echo "# Do a binary extract from database with standard collation"
$ydb_dist/mupip extract extrstd.bin -format=binary

$echoline
echo "# Load the binary extract with standard collation back into the same database"
$ydb_dist/mupip load -fo=binary extrstd.bin\

$echoline
echo "# Check database with standard collation for errors"
$gtm_tst/com/dbcheck.csh
