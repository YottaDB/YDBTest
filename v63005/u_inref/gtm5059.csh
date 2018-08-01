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
echo "# gtm_mstack_crit_threshold set to 50 (threshold can not be set to 100% and 50 is the next easiest to calculate)"
setenv gtm_mstack_crit_threshold "50"
echo "# Set gtm_mstack_size = minKiB"
setenv gtm_mstack_size $minKiB
echo "# Run gtm5059.m recursively until STACKCRIT error"
$ydb_dist/mumps -run gtm5059 >>& gtm5059.m.baseline.log0
unsetenv gtm_mstack_size
set min=`$ydb_dist/mumps -run ^%XCMD 'write ^x'`
echo "# Set gtm_mstack_size = maxKiB"
setenv gtm_mstack_size $maxKiB
echo "# Run gtm5059.m recursively until STACKCRIT error"
$ydb_dist/mumps -run gtm5059 >>& gtm5059.m.baseline.log0
unsetenv gtm_mstack_size
set max=`$ydb_dist/mumps -run ^%XCMD 'write ^x' `
echo "# Calculate baseline calls / KiB"
# (maxKib - minKiB) is divided by 2 since gtm_mstack_crit_threshold is set to 50%
set baseline=`$ydb_dist/mumps -run ^%XCMD 'write ('$max'-'$min')/(('$maxKiB'-'$minKiB')/2)' `
echo "# Calculate calls lost to stack overhead"
# lostcalls uses maxKiB / 2 since the gtm_mstack_crit_threshold is set to 50%
set lostcalls=`$ydb_dist/mumps -run ^%XCMD 'write ('$baseline'*('$maxKiB'/2))-'$max'' `
echo ""

@ maxKiB2 = $maxKiB + 1000
@ minKiB2 = $minKiB - 5

foreach threshold (15 25 50 75 90 95 -20 10 0 96 100)
	echo ""
	echo ""

	#setting gtm_mstack_size to 10000 KiB means that (100 * our threshold %) = (KiB used)
	#when the warning is recieved and will greatly simplify calculations
	setenv gtm_mstack_size "10000"


	if ( 15 <= $threshold && $threshold <= 95) then
		@ expKiB = $threshold * 100
	else if ( $threshold > 15 ) then
		@ expKiB = 9500
	else
		@ expKiB = 1500
	endif

	echo "Testing with gtm_mstack_crit_threshold set to $threshold (expecting $expKiB KiB to be used)"
	echo '-------------------------------------------------------------------------------------------------'

	setenv gtm_mstack_crit_threshold $threshold
	echo "# Run gtm5059.m recursively until STACKCRIT error"
	$ydb_dist/mumps -run gtm5059 >& mlog_$threshold.logx
	unsetenv gtm_mstack_crit_threshold

	set dep=`$ydb_dist/mumps -run ^%XCMD 'write ^x'`
	set expDep=`$ydb_dist/mumps -run ^%XCMD 'write ('$expKiB'*'$baseline')-'$lostcalls''`
	set match=`$ydb_dist/mumps -run ^%XCMD 'write '$dep'<=('$expDep'+1)&('$dep'>=('$expDep'-1))'`

	if ($match) then
		echo "Recursion depth matches expected"
	else
		echo "Recursion depth does NOT match expected"
	endif
end

$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
