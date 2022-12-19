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
# TEST %YDBJNLF
echo "Creating unjournaled database"
setenv gtm_test_jnl "NON_SETJNL"	# Disable random journaling
$gtm_tst/com/dbcreate.csh mumps         # Create one region database

echo ""
echo "Turning on journaling for the first time"
$MUPIP set -journal="enable,on,nobefore" -region "*"

echo ""
echo "Setting data into ^x"
$gtm_exe/mumps -run setx^ydb922

echo ""
echo "Switch journal files"
$MUPIP set -journal="enable,on,nobefore" -region "*"

echo ""
echo "Setting data into ^y"
$gtm_exe/mumps -run sety^ydb922

echo ""
echo "Run main extract test"
$gtm_exe/mumps -run maintest^ydb922

echo ""
echo "# Run Octo DDL Tool and print out DDL"
$gtm_exe/mumps -run OCTODDL^%YDBJNLF

echo ""
echo "# Make sure that the Octo DDL Tool does not crash on invalid pipes (YDB#967)"
$gtm_exe/mumps -run OCTODDL^%YDBJNLF | foo

echo ""
echo "# Test purge entry points"
$gtm_exe/mumps -run purgetest^ydb922

echo ""
echo "# Test error trap by ingesting an invalid file"
$gtm_exe/mumps -run %XCMD 'DO INGEST^%YDBJNLF("foo.boo.txt")'

# DBCheck
echo ""
echo "Database check..."
$gtm_tst/com/dbcheck.csh
