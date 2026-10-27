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

echo "#-------------------------------------------------------------------------------------------------#"
echo "# [YDB#1308] With gtm_side_effects=1, an indirect reference is compiled the same after an earlier   #"
echo "# indirect reference with a nested indirection                                                     #"
echo "#-------------------------------------------------------------------------------------------------#"
echo
echo '# With gtm_side_effects set to 1, compiling an indirect reference with a nested indirection, such as'
echo '# x(@y), left a side effect flag set in the compiler, and the next indirect reference was compiled as'
echo '# if it too had a side effect. For $DATA(@ref) with ref="z(p,n)", where z and p are undefined, that'
echo '# code evaluates the subscript p, which issues LVUNDEF, whereas $DATA(z(p,n)) is 0 since z does not'
echo '# exist. It did not matter whether the earlier reference issued an error.'
echo '#'
echo '# Each stage runs in its own process, with gtm_side_effects set to 1.'
echo

cp $gtm_tst/$tst/inref/ydb1308.m .

# The framework sets gtm_side_effects at random, and ydb_side_effects takes precedence over it
unsetenv ydb_side_effects
setenv gtm_side_effects 1

echo '# Stage 1 : the example in YDB#1308, with the two $DATA() values joined:'
echo '#   set y="y",v=$data(@"x(@y)")_$data(@"z(p,1)")'
echo '# Command : $gtm_dist/mumps -run short^ydb1308'
echo '#   expect 00'
echo '# Before the fix, LVUNDEF, so the line below was a WRONG line'
$gtm_dist/mumps -run short^ydb1308
echo

echo '# Stages 2 to 6 are variations of stage 1: the second reference is $DATA(@ref) with ref="z(p,n)",'
echo '# and the first is the one named in each stage, or none'
echo

echo '# Stage 2 : $DATA(@ref) with ref="z(p,n)" without a first indirect reference'
echo '# Command : $gtm_dist/mumps -run nofirst^ydb1308'
echo '#   expect 0'
echo '# Before the fix, the same result'
$gtm_dist/mumps -run nofirst^ydb1308
echo

echo '# Stage 3 : the same after $DATA(@ref) with ref="x(@y)", y="a" and a defined'
echo '# Command : $gtm_dist/mumps -run nested^ydb1308'
echo '#   expect 0'
echo '# Before the fix, LVUNDEF, so the second line below was a WRONG line'
$gtm_dist/mumps -run nested^ydb1308
echo

echo '# Stage 4 : the same after $DATA(@ref) with ref="x(@y)", y="a" and a undefined, which issues an error'
echo '# Command : $gtm_dist/mumps -run nestederr^ydb1308'
echo '#   expect 0'
echo '# Before the fix, LVUNDEF, so the second line below was a WRONG line'
$gtm_dist/mumps -run nestederr^ydb1308
echo

echo '# Stage 5 : the same after $DATA(@ref) with ref="x(1,@y)", y="a" and a defined'
echo '# Command : $gtm_dist/mumps -run nested2^ydb1308'
echo '#   expect 0'
echo '# Before the fix, LVUNDEF, so the second line below was a WRONG line'
$gtm_dist/mumps -run nested2^ydb1308
echo

echo '# Stage 6 : the same after $DATA(@ref) with ref="x(a)" and a defined, which has no nested indirection'
echo '# Command : $gtm_dist/mumps -run plain^ydb1308'
echo '#   expect 0'
echo '# Before the fix, the same result'
$gtm_dist/mumps -run plain^ydb1308
echo

echo "# Done"
