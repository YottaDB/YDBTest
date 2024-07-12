#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "----------------------------------------------------------------------------------------------------------"
echo "# Test that remote file name specifications in the client side GLD use the GT.CM GNP server as appropriate"
echo "----------------------------------------------------------------------------------------------------------"

echo ""

echo "# Create database with fullpath enabled"
$gtm_tst/com/dbcreate.csh mumps -gld_has_db_fullpath >& dbcreate.out
if ($status) then
        echo "# dbcreate failed. Output of dbcreate.out follows"
        cat dbcreate.out
endif

echo "# Use mumps to obtain the fullpath to the database"
set filepath=`$ydb_dist/mumps -run path^ydb191`

# Copy the DB file to be restored at the end of the subtest.
cp mumps.gld back.gld

set shorthost = $HOST:r:r:r

echo ""
echo "# Change the DEFAULT segment in the database using the syntax: <hostname>:<filepath>."
echo "# This should use short-circuiting as <hostname> is the local host name and no @ syntax specified."
echo "# And so can satisfy the database reference locally (i.e. should not need the GNP server) without any error."
$ydb_dist/mumps -run GDE change -segment DEFAULT -file="$shorthost":$filepath >& case1.txt
$ydb_dist/mumps -run case1^ydb191
echo ""

echo "# Change the DEFAULT segment in the database using the syntax: @<hostname>:<filepath>."
echo "# This should use the GNP server even though <hostname> is local due to the @ syntax."
echo "# Since there is no GNP server started, we expect a database access to error out."
$ydb_dist/mumps -run GDE change -segment DEFAULT -file="@$shorthost":$filepath >& case2.txt
$ydb_dist/mumps -run case2^ydb191
echo ""

echo "# Using fabricated remote server 'ghosthost' as a non-local hostname for the subtest."
echo ""
echo "# Change the DEFAULT segment in the database using the syntax: <ghosthost>:<filepath>."
echo "# Since <ghosthost> is not a local hostname, this should need the GNP server irrespective of the presence/absence of @ syntax."
echo "# Since there is no GNP server started, we expect a database access to error out."
$ydb_dist/mumps -run GDE change -segment DEFAULT -file="ghosthost":$filepath >& case3.txt
$ydb_dist/mumps -run case3^ydb191
echo ""

echo "# Change the DEFAULT segment in the database using the syntax: @<ghosthost>:<filename>."
echo "# Since <ghosthost> is not a local hostname, this should need the GNP server irrespective of the presence/absence of @ syntax."
echo "# Since there is no GNP server started, we expect a database access to error out."
$ydb_dist/mumps -run GDE change -segment DEFAULT -file="@ghosthost":$filepath >& case4.txt
$ydb_dist/mumps -run case4^ydb191
echo ""

# Restore the original DB file
rm mumps.gld
cp back.gld mumps.gld

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
        echo "# dbcheck failed. Output of dbcheck.out follows"
        cat dbcheck.out
endif

echo "# Test NOCRENETFILE error displays full path and file name (used to truncate last character previously)"
echo "# Change the DEFAULT segment in the database using the syntax: @<hostname>:<filepath>."
$ydb_dist/mumps -run GDE change -segment DEFAULT -file="@$shorthost":/tmp/abcd.dat >& case5.txt
$ydb_dist/mupip create

