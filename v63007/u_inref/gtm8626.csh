#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#

echo '# MUPIP JOURNAL does not allow any two of -EXTRACT, -LOSTTRANS or -BROKENTRANS to specify the same file name unless they are special files (-stdout or /dev/null)'
echo '# Previously, MUPIP JOURNAL allowed overlapping file specifications, which lead to unexpected behavior including missing files'

echo; echo '# Enabling jouranaling so there is a file to try and extract'
setenv acc_meth "BG"
setenv gtm_test_jnl "SETJNL"
setenv tst_jnl_str '-journal="enable,on,before"'
$gtm_tst/com/dbcreate.csh mumps

echo; echo '# Testing -losttrans -brokentrans'
echo '# Testing with same file should error'
$gtm_dist/mupip journal -extract -backward -losttrans=outfile.outx -brokentrans=outfile.outx
echo; echo '# Testing with -stdout should pass'
$gtm_dist/mupip journal -extract mumps.mjl -backward -losttrans=-stdout -brokentrans=-stdout
echo; echo '# Testing with /dev/null should pass'
$gtm_dist/mupip journal -extract mumps.mjl -backward -losttrans=/dev/null -brokentrans=/dev/null

echo; echo '# Testing -losttrans -extract'
echo '# Testing with same file should error'
$gtm_dist/mupip journal -extract -backward -losttrans=outfile.outx -extract=outfile.outx
echo; echo '# Testing with -stdout should pass'
$gtm_dist/mupip journal -extract mumps.mjl -backward -losttrans=-stdout -extract=-stdout
echo; echo '# Testing with /dev/null should pass'
$gtm_dist/mupip journal -extract mumps.mjl -backward -losttrans=/dev/null -extract=/dev/null

echo; echo '# Testing -brokentrans -extract'
echo '# Testing with same file should error'
$gtm_dist/mupip journal -extract -backward -brokentrans=outfile.outx -extract=outfile.outx
echo; echo '# Testing with -stdout should pass'
$gtm_dist/mupip journal -extract mumps.mjl -backward -brokentrans=-stdout -extract=-stdout
echo; echo '# Testing with /dev/null should pass'
$gtm_dist/mupip journal -extract mumps.mjl -backward -brokentrans=/dev/null -extract=/dev/null

$gtm_tst/com/dbcheck.csh
