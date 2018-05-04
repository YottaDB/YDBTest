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

echo "# Create a single region DB with region DEFAULT"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt

set dep = 0		; #The actual depth of each recursive call before overflow (calculated later)
set expDep = 0		; #The expected depth of each recursive call before overflow (calculated later)
set minKiB = 25		; #Minimum Mstack size
set maxKiB = 10000	; #Maximum Mstack size
set defKiB = 272	; #Default Mstack size

echo "# Establishing baseline of (recursive calls / KiB)"
echo "# Set gtm_mstack_size = minKiB"
setenv gtm_mstack_size $minKiB
echo "# Run gtm1041.m recursively until stack overflow"
$ydb_dist/mumps -run gtm1041 >>& gtm1041.m.baseline.log0
unsetenv gtm_mstack_size
set min=`$ydb_dist/mumps -run ^%XCMD 'write ^x'`
echo "# Set gtm_mstack_size = maxKiB"
setenv gtm_mstack_size $maxKiB
echo "# Run gtm1041.m recursively until stack overflow"
$ydb_dist/mumps -run gtm1041 >>& gtm1041.m.baseline.log0
unsetenv gtm_mstack_size
set max=`$ydb_dist/mumps -run ^%XCMD 'write ^x' `
echo "# Calculate baseline calls / KiB"
set baseline=`$ydb_dist/mumps -run ^%XCMD 'write ('$max'-'$min')/('$maxKiB'-'$minKiB')' `
echo "# Calculate calls lost to stack overhead"
set lostcalls=`$ydb_dist/mumps -run ^%XCMD 'write ('$baseline'*'$maxKiB')-'$max'' `
echo ""


echo "# Unset gtm_mstack_size (defaults to defKiB)"
unsetenv gtm_mstack_size
echo "# Run gtm1041.m recursively until stack overflow"
$ydb_dist/mumps -run gtm1041 >>& gtm1041.m.log1
set dep=`$ydb_dist/mumps -run ^%XCMD 'write ^x'`
set expDep=`$ydb_dist/mumps -run ^%XCMD 'write ('$defKiB'*'$baseline')-'$lostcalls''`
set match=`$ydb_dist/mumps -run ^%XCMD 'write '$dep'<=('$expDep'+1)&('$dep'>=('$expDep'-1))'`
if ( $match )  then
	echo "# Depth matches expected"
else
	echo "# DEPTH DOES NOT MATCH EXPECTED"
endif
echo ""


echo "# Set gtm_mstack_size to 0 (defaults to defKiB)"
setenv gtm_mstack_size 0
echo "# Run gtm1041.m recursively until stack overflow"
$ydb_dist/mumps -run gtm1041 >>& gtm1041.m.log2
unsetenv gtm_mstack_size
set dep=`$ydb_dist/mumps -run ^%XCMD 'write ^x'`
set expDep=`$ydb_dist/mumps -run ^%XCMD 'write ('$defKiB'*'$baseline')-'$lostcalls''`
set match=`$ydb_dist/mumps -run ^%XCMD 'write '$dep'<=('$expDep'+1)&('$dep'>=('$expDep'-1))'`
if ( $match )  then
	echo "# Depth matches expected"
else
	echo "# DEPTH DOES NOT MATCH EXPECTED"
endif
echo ""


echo "# Set gtm_mstack_size to 5000"
setenv gtm_mstack_size 5000
echo "# Run gtm1041.m recursively until stack overflow"
$ydb_dist/mumps -run gtm1041 >>& gtm1041.m.log3
unsetenv gtm_mstack_size
set dep=`$ydb_dist/mumps -run ^%XCMD 'write ^x'`
set expDep=`$ydb_dist/mumps -run ^%XCMD 'write (5000*'$baseline')-'$lostcalls''`
set match=`$ydb_dist/mumps -run ^%XCMD 'write '$dep'<=('$expDep'+1)&('$dep'>=('$expDep'-1))'`
if ( $match )  then
	echo "# Depth matches expected"
else
	echo "# DEPTH DOES NOT MATCH EXPECTED"
endif
echo ""


echo "# Set gtm_mstack_size to maxKiB"
setenv gtm_mstack_size $maxKiB
echo "# Run gtm1041.m recursively until stack overflow"
$ydb_dist/mumps -run gtm1041 >>& gtm1041.m.log4
unsetenv gtm_mstack_size
set dep=`$ydb_dist/mumps -run ^%XCMD 'write ^x'`
set expDep=`$ydb_dist/mumps -run ^%XCMD 'write ('$maxKiB'*'$baseline')-'$lostcalls''`
set match=`$ydb_dist/mumps -run ^%XCMD 'write '$dep'<=('$expDep'+1)&('$dep'>=('$expDep'-1))'`
if ( $match )  then
	echo "# Depth matches expected"
else
	echo "# DEPTH DOES NOT MATCH EXPECTED"
endif
echo ""


echo "# Set gtm_mstack_size to maxKiB + 10000 (defaults to maxKiB)"
@ maxKiB = $maxKiB + 10000
setenv gtm_mstack_size $maxKiB
@ maxKiB = $maxKiB - 10000
echo "# Run gtm1041.m recursively until stack overflow"
$ydb_dist/mumps -run gtm1041 >>& gtm1041.m.log5
unsetenv gtm_mstack_size
set dep=`$ydb_dist/mumps -run ^%XCMD 'write ^x'`
set expDep=`$ydb_dist/mumps -run ^%XCMD 'write ('$maxKiB'*'$baseline')-'$lostcalls''`
set match=`$ydb_dist/mumps -run ^%XCMD 'write '$dep'<=('$expDep'+1)&('$dep'>=('$expDep'-1))'`
if ( $match )  then
	echo "# Depth matches expected"
else
	echo "# DEPTH DOES NOT MATCH EXPECTED"
endif
echo ""


echo "# Set gtm_mstack_size to minKiB - 5 (defaults to minKiB)"
@ minKiB = $minKiB - 5
setenv gtm_mstack_size $minKiB
@ minKiB = $minKiB + 5
echo "# Run gtm1041.m recursively until stack overflow"
$ydb_dist/mumps -run gtm1041 >>& gtm1041.m.log6
unsetenv gtm_mstack_size
set dep=`$ydb_dist/mumps -run ^%XCMD 'write ^x'`
set expDep=`$ydb_dist/mumps -run ^%XCMD 'write ('$minKiB'*'$baseline')-'$lostcalls''`
set match=`$ydb_dist/mumps -run ^%XCMD 'write '$dep'<=('$expDep'+1)&('$dep'>=('$expDep'-1))'`
if ( $match )  then
	echo "# Depth matches expected"
else
	echo "# DEPTH DOES NOT MATCH EXPECTED"
endif

$gtm_tst/com/dbcheck.csh >>& dbcreate_log.txt
