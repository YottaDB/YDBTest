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
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

set dep = 0		; #The actual depth of each recursive call before overflow (calculated later)
set expDep = 0		; #The expected depth of each recursive call before overflow (calculated later)
set minKiB = 25		; #Minimum Mstack size
set maxKiB = 10000	; #Maximum Mstack size
set defKiB = 272	; #Default Mstack size

echo "# Establishing baseline of (recursive calls / KiB)"
echo "# Set gtm_mstack_size = minKiB"
setenv gtm_mstack_size $minKiB
echo "# Run gtm1042.m recursively until stack overflow"
$ydb_dist/mumps -run gtm1042 >>& gtm1042.m.baseline.log0
unsetenv gtm_mstack_size
set min=`$ydb_dist/mumps -run ^%XCMD 'write ^x'`
echo "# Set gtm_mstack_size = maxKiB"
setenv gtm_mstack_size $maxKiB
echo "# Run gtm1042.m recursively until stack overflow"
$ydb_dist/mumps -run gtm1042 >>& gtm1042.m.baseline.log0
unsetenv gtm_mstack_size
set max=`$ydb_dist/mumps -run ^%XCMD 'write ^x' `
echo "# Calculate baseline calls / KiB"
set baseline=`$ydb_dist/mumps -run ^%XCMD 'write ('$max'-'$min')/('$maxKiB'-'$minKiB')' `
echo "# Calculate calls lost to stack overhead"
set lostcalls=`$ydb_dist/mumps -run ^%XCMD 'write ('$baseline'*'$maxKiB')-'$max'' `
echo ""

@ maxKiB2 = $maxKiB + 1000
@ minKiB2 = $minKiB - 5

foreach envKiB ($defKiB 0 5000 $maxKiB $maxKiB2 $minKiB2)
	if ($defKiB == $envKiB) then
		echo "# Unset gtm_mstack_size (defaults to defKiB)"
		unsetenv gtm_mstack_size
		set expKiB = $defKiB
	else
		setenv gtm_mstack_size $envKiB
		if (0 == $envKiB) then
			echo "# Set gtm_mstack_size to 0 (defaults to defKiB)"
			set expKiB = $defKiB
		else if (5000 == $envKiB) then
			echo "# Set gtm_mstack_size to 5000"
			set expKiB = $envKiB
		else if ($maxKiB == $envKiB) then
			echo "# Set gtm_mstack_size to maxKiB"
			set expKiB = $envKiB
		else if ($maxKiB2 == $envKiB) then
			echo "# Set gtm_mstack_size to maxKiB + 10000 (defaults to maxKiB)"
			set expKiB = $maxKiB
		else if ($minKiB2 == $envKiB) then
			echo "# Set gtm_mstack_size to minKiB - 5 (defaults to minKiB)"
			set expKiB = $minKiB
		endif
	endif
	echo "# Run gtm1042.m recursively until stack overflow"
	$ydb_dist/mumps -run gtm1042 >& gtm1042.$envKiB.logx
	unsetenv gtm_mstack_size	# so below mumps -run commands are not affected by above mstack size setting
	set dep=`$ydb_dist/mumps -run ^%XCMD 'write ^x'`
	set expDep=`$ydb_dist/mumps -run ^%XCMD 'write ('$expKiB'*'$baseline')-'$lostcalls''`
	set match=`$ydb_dist/mumps -run ^%XCMD 'write '$dep'<=('$expDep'+1)&('$dep'>=('$expDep'-1))'`
	if (1 == $match)  then
		echo "# Depth matches expected"
	else
		echo "# DEPTH DOES NOT MATCH EXPECTED"
	endif
	echo ""
end

$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
