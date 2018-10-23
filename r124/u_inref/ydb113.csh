#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.      #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo "------------------------------------------------------------------------------------------------------------"
echo '# Test that $$getncol^%LCLCOL returns expected values when ydb_lct_stdnull env var is set to various values.'
echo "------------------------------------------------------------------------------------------------------------"

# Set random value to determine upper case settings or lower case
set lcase=`$ydb_dist/mumps -run ^%XCMD 'write $random(2)'`
echo $lcase >> debug.txt

echo "# Unset ydb_lct_stdnull to test with undefined settings"
unset ydb_lct_stdnull
$ydb_dist/mumps -run test^ydb113
echo ""

echo "# Set ydb_lct_stdnull to 0"
setenv ydb_lct_stdnull "0"
$ydb_dist/mumps -run test^ydb113
echo ""

echo "# Set ydb_lct_stdnull to N, NO, no etc."
set no=`$ydb_dist/mumps -run gen^ydb113 no`
setenv ydb_lct_stdnull $no
$ydb_dist/mumps -run test^ydb113
echo $no >> debug.txt
echo ""

echo "# Set ydb_lct_stdnull to F, FA, FAL, FALS, FALSE, false etc."
set false=`$ydb_dist/mumps -run gen^ydb113 false`
setenv ydb_lct_stdnull $false
$ydb_dist/mumps -run test^ydb113
echo $false >> debug.txt
echo ""

echo "# Set ydb_lct_stdnull to a number XXX < 0."
set num=`$ydb_dist/mumps -run ^%XCMD 'write -1*($random(998)+1)'`
setenv ydb_lct_stdnull $num
$ydb_dist/mumps -run test^ydb113
echo $num >> debug.txt
echo ""

echo "# Set ydb_lct_stdnull to 1"
setenv ydb_lct_stdnull 1
$ydb_dist/mumps -run test^ydb113
echo ""

echo "# Set ydb_lct_stdnull to Y, YE, YES, yes etc."
set yes=`$ydb_dist/mumps -run gen^ydb113 yes`
setenv ydb_lct_stdnull $yes
$ydb_dist/mumps -run test^ydb113
echo $yes >> debug.txt
echo ""

echo "# Set ydb_lct_stdnull to T,TR,TRU,TRUE, true etc."
set true=`$ydb_dist/mumps -run gen^ydb113 true`
setenv ydb_lct_stdnull $true
$ydb_dist/mumps -run test^ydb113
echo $true >> debug.txt
echo ""

echo "# Set ydb_lct_stdnull to a number XXX > 1."
set num=`$ydb_dist/mumps -run ^%XCMD 'write $random(998)+2'`
setenv ydb_lct_stdnull $num
$ydb_dist/mumps -run test^ydb113
echo $num >> debug.txt
