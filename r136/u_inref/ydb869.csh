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

echo 'YDB#869 : Test boolean expressions involving huge numeric literals issue NUMOFLOW error (and not SIG-11)'
echo ""

echo "#################################################################################################"
echo "# Test 1 : Test that compiling M program with NUMOFLOW expressions does not assert fail or SIG-11"
echo "# Note that NUMOFLOW errors will be printed more than once for the same expression in different code sections"
echo "# Therefore there would be more NUMOFLOW errors (60 error lines in actual) here than the number of expressions (3*6 = 18)"
set logfile = compile_ydb869.outx
$ydb_dist/yottadb $gtm_tst/$tst/inref/ydb869.m >& $logfile
$gtm_tst/com/check_error_exist.csh $logfile "%YDB-E-NUMOFLOW"

echo ""
echo "#################################################################################################"
echo "# Test 2 : Test that running M commands with NUMOFLOW expressions does not assert fail or SIG-11"
echo "# Note that NUMOFLOW errors will be printed once per expression in this case so we expect 18 lines of such errors"
set logfile = direct_ydb869.outx
$ydb_dist/yottadb -direct < $gtm_tst/$tst/inref/ydb869.m >& $logfile
$gtm_tst/com/check_error_exist.csh $logfile "%YDB-E-NUMOFLOW"

echo ""
echo "#################################################################################################"
echo "# Test 3 : Test that running M program with NUMOFLOW expressions does not assert fail or SIG-11"
echo "# We run this with a ZTRAP handler set to print the error in each line and move on to the next line"
echo "# So we expect a series of error lines below. Mostly NUMOFLOW errors. But some other errors too since these"
echo "# M lines were generated by fuzz testing which can generated syntax-error M lines"
set logfile = run_ydb869.outx
$ydb_dist/yottadb -run %XCMD 'set $ztrap="goto incrtrap^incrtrap" do ^ydb869'

