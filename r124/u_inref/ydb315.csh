#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#The compile env vars are unset to avoid complications from parent environment
unsetenv ydb_compile
unsetenv gtmcompile

echo "# Run nosetZcomp^ydb315.m to attempt to compile blktoodeep.m with no '-nowarning' flag (expecting warnings)"
$ydb_dist/mumps -run nosetZcomp^ydb315
echo ""

echo "# Run setZcompNoWarning^ydb315.m to attempt to compile blktoodeep.m with the '-nowarning' flag set directly (expecting no warnings)"
$ydb_dist/mumps -run setZcompNoWarning^ydb315
echo ""

setenv ydb_compile "-nowarning"
echo "# Run nosetZcomp^ydb315.m to attempt to compile blktoodeep.m with the '-nowarning' flag set in "'$'"ydb_compile (expecting no warnings)"
$ydb_dist/mumps -run nosetZcomp^ydb315
echo ""

unsetenv ydb_compile

setenv gtmcompile "-nowarning"
echo "# Run nosetZcomp^ydb315.m to attempt to compile blktoodeep.m with the '-nowarning' flag set in "'$'"gtmcompile (expecting no warnings)"
$ydb_dist/mumps -run nosetZcomp^ydb315
echo ""

unsetenv gtmcompile

setenv gtmcompile "-warning"
echo "# Run setZcompNoWarning^ydb315.m to attempt to compile blktoodeep.m with the '-warning' flag set in "'$'"gtmcompile  and the '-nowarning' flag set directly (expecting no warnings)"
$ydb_dist/mumps -run setZcompNoWarning^ydb315
echo ""

unsetenv gtmcompile

setenv ydb_compile "-warning"
echo "# Run setZcompNoWarning^ydb315.m to attempt to compile blktoodeep.m with the '-warning' flag set in "'$'"ydb_compile  and the '-nowarning' flag set directly (expecting no warnings)"
$ydb_dist/mumps -run setZcompNoWarning^ydb315
echo ""

unsetenv ydb_compile

setenv gtmcompile "-nowarning"
echo "# Run setZcompWarning^ydb315.m to attempt to compile blktoodeep.m with the '-nowarning' flag set in "'$'"gtmcompile  and the '-warning' flag set directly (expecting warnings)"
$ydb_dist/mumps -run setZcompWarning^ydb315
echo ""

unsetenv gtmcompile

setenv ydb_compile "-nowarning"
echo "# Run setZcompWarning^ydb315.m to attempt to compile blktoodeep.m with the '-nowarning' flag set in "'$'"ydb_compile  and the '-warning' flag set directly (expecting warnings)"
$ydb_dist/mumps -run setZcompWarning^ydb315
echo ""

unsetenv ydb_compile
