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

echo "#----------------------------------------------------------------------------------------------------#"
echo '# [YDB#1278] Indirection naming a local variable with simple subscripts is not compiled             #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# An indirection whose source string names a local variable, with subscripts that are canonical'
echo '# numbers, string literals or defined unsubscripted local variables, is located directly instead'
echo '# of compiling the string. Any other string is compiled as before.'
echo '#'
echo '# Stages 1 to 5 check that the fast path gives what the compiled code gives. Each compares an'
echo '# indirection through @ref with the same indirection through @(ref_" "). The compiler ignores the'
echo '# trailing space but the fast path does not accept it, so the second is always compiled. The two'
echo '# must agree, value or error, for every string. These stages pass without the change too.'
echo '#'
echo '# Stages 6 and 7 fail without the change. Stage 6 compares the cost of a new reference string on'
echo '# every call with the cost of a repeated one, about 20 to 1 without the change and under 2 to 1 with'
echo '# it. Stage 7 checks that, in a process with a large local array, garbage collections grow the'
echo '# stringpool instead of walking the array every few KiB.'
echo '#'
echo '# Each stage runs in its own process.'
echo

cp $gtm_tst/$tst/inref/ydb1278.m .

echo '# Stage 1 : $DATA, $ZDATA, $GET, $ORDER, value fetch and $NAME on 62 reference strings of many shapes'
echo '# Command : $gtm_dist/mumps -run reads^ydb1278'
echo '#   expect every result through the fast path to be the same as compiled'
$gtm_dist/mumps -run reads^ydb1278
echo

echo '# Stage 2 : SET, multiple SET, SET $PIECE and $EXTRACT, FOR, MERGE, KILL and $INCREMENT with an indirect target'
echo '# Command : $gtm_dist/mumps -run saves^ydb1278'
echo '#   expect every command to leave the same variables through the fast path as compiled'
$gtm_dist/mumps -run saves^ydb1278
echo

echo '# Stage 3 : name indirection @r@(subs), with subscripts that change r or another subscript'
echo '# Command : $gtm_dist/mumps -run names^ydb1278'
echo '#   expect every result to be the same as the compiled text op_indname builds'
$gtm_dist/mumps -run names^ydb1278
echo

echo '# Stage 4 : 5000 randomly generated reference strings, valid and not, many sharing a prefix with the one before'
echo '# Command : $gtm_dist/mumps -run random^ydb1278'
echo '#   expect every result through the fast path to be the same as compiled'
$gtm_dist/mumps -run random^ydb1278
echo

echo '# Stage 5 : string literals from 20000 unique indirect compilations, cache evictions and garbage collections'
echo '# Command : $gtm_dist/mumps -run lits^ydb1278'
echo '#   expect every variable to hold the literal assigned to it'
$gtm_dist/mumps -run lits^ydb1278
echo

echo '# Stage 6 : $DATA(@ref@("b")) 100000 times with the same ref, then with a new ref every time, in 3 alternating rounds'
echo '# Command : $gtm_dist/mumps -run cost^ydb1278'
echo '#   expect the fastest round with a new ref every time to cost less than 5 times the fastest with the same ref'
$gtm_dist/mumps -run cost^ydb1278
echo

echo '# Stage 7 : a local array of 200000 nodes, then $DATA(@ref@("b")) with a new ref 200000 times'
echo '# Command : $gtm_dist/mumps -run grow^ydb1278'
echo '#   expect the stringpool to have grown beyond twice its initial 96KiB'
$gtm_dist/mumps -run grow^ydb1278
echo

echo "# Done"
