#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test the default value of $ZROUTINES.'
echo '# First we must copy ydb_dist so we can destroy files from it without causing problems'
source $gtm_tst/com/copy_ydb_dist_dir.csh ydb_temp_dist
chmod -R +wX ydb_temp_dist

echo 'First doing UTF-8 mode tests'
echo
echo

$switch_chset "UTF-8"
unsetenv ydb_routines
unsetenv gtmroutines


echo '# UTF-8 mode: $ydb_dist/plugin/o/utf8 exists, $ydb_dist/utf8/libyottadbutil.so exists'
echo '# Expected: $ydb_dist/plugin/o/utf8/*.so $ydb_dist/utf8/libyottadbutil.so'
echo 'W $ZROUTINES,!' > input.txt

$gtm_dist/mumps -dir < input.txt

echo '# UTF-8 mode with empty ydb_routines: same expectation'
echo '# Expected: $ydb_dist/plugin/o/utf8/*.so $ydb_dist/utf8/libyottadbutil.so'
setenv ydb_routines ""
$gtm_dist/mumps -dir < input.txt
unsetenv ydb_routines

echo '# UTF-8 mode: $ydb_dist/plugin/o/utf8 exists, $ydb_dist/utf8/libyottadbutil.so does NOT exist'
echo '# Expected: $ydb_dist/plugin/o/utf8/*.so $ydb_dist/utf8'
mv $ydb_dist/utf8/libyottadbutil.so $ydb_dist/utf8/libyottadbutil.so.temp_rename
$gtm_dist/mumps -dir < input.txt
mv $ydb_dist/utf8/libyottadbutil.so.temp_rename $ydb_dist/utf8/libyottadbutil.so

echo '# UTF-8 mode: $ydb_dist/plugin/o/utf8 does NOT exist, $ydb_dist/utf8/libyottadbutil.so exists'
echo '# Expected: $ydb_dist/utf8/libyottadbutil.so'
mv $ydb_dist/plugin/o/utf8 $ydb_dist/plugin/o/utf8.temp_rename
$gtm_dist/mumps -dir < input.txt

echo '# UTF-8 mode: $ydb_dist/plugin/o/utf8 does NOT exist, $ydb_dist/utf8/libyottadbutil.so does NOT exist'
echo '# Expected: $ydb_dist/utf8'
mv $ydb_dist/utf8/libyottadbutil.so $ydb_dist/utf8/libyottadbutil.so.temp_rename
$gtm_dist/mumps -dir < input.txt
mv $ydb_dist/plugin/o/utf8.temp_rename $ydb_dist/plugin/o/utf8
mv $ydb_dist/utf8/libyottadbutil.so.temp_rename $ydb_dist/utf8/libyottadbutil.so

echo '# UTF-8 mode: testing the error where $ydb_dist/utf8 does NOT exist'
echo '# Expect a UTF8NOTINSTALLED error'
mv $ydb_dist/utf8 $ydb_dist/utf8.temp_rename
$gtm_dist/mumps -dir < input.txt
mv $ydb_dist/utf8.temp_rename $ydb_dist/utf8

echo
echo 'Now doing M mode tests'
echo
echo

$switch_chset "M"
unsetenv ydb_routines
unsetenv gtmroutines



echo '# M mode: $ydb_dist/plugin/o exists, $ydb_dist/libyottadbutil.so exists'
echo '# Expected: $ydb_dist/plugin/o/*.so $ydb_dist/libyottadbutil.so'
$gtm_dist/mumps -dir < input.txt

echo '# M mode: $ydb_dist/plugin/o exists, $ydb_dist/libyottadbutil.so does NOT exist'
echo '# Expected: $ydb_dist/plugin/o/*.so $ydb_dist'
mv $ydb_dist/libyottadbutil.so $ydb_dist/libyottadbutil.so.temp_rename
$gtm_dist/mumps -dir < input.txt
mv $ydb_dist/libyottadbutil.so.temp_rename $ydb_dist/libyottadbutil.so

echo '# M mode: $ydb_dist/plugin/o does NOT exist, $ydb_dist/libyottadbutil.so exists'
echo '# Expected: $ydb_dist/libyottadbutil.so'
mv $ydb_dist/plugin/o $ydb_dist/plugin/o.temp_rename
$gtm_dist/mumps -dir < input.txt

echo '# M mode: $ydb_dist/plugin/o does NOT exist, $ydb_dist/libyottadbutil.so does NOT exist'
echo '# Expected: $ydb_dist'
mv $ydb_dist/libyottadbutil.so $ydb_dist/libyottadbutil.so.temp_rename
$gtm_dist/mumps -dir < input.txt
mv $ydb_dist/plugin/o.temp_rename $ydb_dist/plugin/o
mv $ydb_dist/libyottadbutil.so.temp_rename $ydb_dist/libyottadbutil.so
