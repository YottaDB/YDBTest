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
echo "# Run nosetZcomp^ydb315.m to attempt to compile blktoodeep.m with no '-nowarning' flag (expecting warnings)"
$ydb_dist/mumps -run nosetZcomp^ydb315
echo ""

echo "# Run setZcomp^ydb315.m to attempt to compile blktoodeep.m with the '-nowarning' flag set directly (expecting no warnings)"
$ydb_dist/mumps -run setZcomp^ydb315
echo ""

setenv ydb_compile "-nowarning"
unsetenv ydb_compile
echo "# Run noZcomp^ydb315.m to attempt to compile blktoodeep.m with the '-nowarning' flag set in "'$'"ydb_compile (expecting no warnings)"
$ydb_dist/mumps -run setZcomp^ydb315
echo ""

setenv gtmcompile "-nowarning"
echo "# Run noZcomp^ydb315.m to attempt to compile blktoodeep.m with the '-nowarning' flag set in "'$'"gtmcompile (expecting no warnings)"
$ydb_dist/mumps -run setZcomp^ydb315
echo ""

unsetenv gtmcompile
