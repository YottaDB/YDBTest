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
echo "#--------------------------------------------------------------------------------------------------#"
echo "# [YDB#1362] A comparison with < or > of a number and a string literal that is a number that is    #"
echo "# too large issues NUMOFLOW                                                                        #"
echo "#--------------------------------------------------------------------------------------------------#"
echo
echo '# When both operands of a < or > (or of their negations) are literals, the compiler computes the'
echo '# comparison at compile time. It did not check that a string literal is a valid number, so a string'
echo '# literal that is a number that is too large, like "1E47", compared as if it had a value, and the'
echo '# comparison gave 0 or 1 instead of issuing NUMOFLOW, as the comparison does when the string is in a'
echo '# variable. Stages 1 to 4 run in one process, and stages 5 and 6 compile and run a routine.'
echo

cp $gtm_tst/$tst/inref/ydb1362cmp.m .
foreach stage (1 2 3 4)
	switch ($stage)
	case 1:
		echo '# Stage 1 : each comparison, compiled at run time (as in Direct Mode)'
		echo '# Before the fix : the comparisons gave 0, 1, 1, 1 and 0'
		echo '# With the fix   : expect NUMOFLOW for each'
		breaksw
	case 2:
		echo '# Stage 2 : the comparison in a Boolean expression'
		echo '# Before the fix : 1&(1<"1E47") gave 0'
		echo '# With the fix   : expect NUMOFLOW'
		breaksw
	case 3:
		echo '# Stage 3 : $ZYCOMPILE() of a line with the comparison'
		echo '# Before the fix : $ZYCOMPILE() returned "" (no error)'
		echo '# With the fix   : expect NUMOFLOW'
		breaksw
	case 4:
		echo '# Stage 4 : a string literal that is a number that is not too large, and a string in a variable'
		echo '# Before the fix : no error for the four comparisons, and NUMOFLOW for the variable (this stage is a'
		echo '#                  control)'
		echo '# With the fix   : expect the same'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run '"stage$stage^ydb1362cmp"
	$gtm_dist/mumps -run stage$stage^ydb1362cmp >& stage$stage.out
	$grep -E "^(PASS|FAIL) " stage$stage.out
	echo
end

$gtm_dist/mumps -run gen^ydb1362cmp
echo '# Stage 5 : compile and run a routine with the comparison'
sed -n 1p xcmp.m | sed 's/^/#   /'
echo '# Before the fix : the routine compiled with no error, and wrote 0 and line 2'
echo '# With the fix   : expect the compile to issue NUMOFLOW (a compile time warning) and produce an object'
echo '#                  file, and the routine to issue NUMOFLOW when it runs'
echo '# Command : $gtm_dist/mumps xcmp.m'
$gtm_dist/mumps xcmp.m >& xcmp.cmp
if (1 == `$grep -c -- "-E-NUMOFLOW," xcmp.cmp`) then
	echo "PASS : compiling xcmp.m issued NUMOFLOW once"
else
	echo "FAIL : compiling xcmp.m did not issue NUMOFLOW once - see xcmp.cmp"
endif
$gtm_tst/com/check_error_exist.csh xcmp.cmp NUMOFLOW >& /dev/null
if (-e xcmp.o) then
	echo "PASS : xcmp.o was produced"
else
	echo "FAIL : xcmp.o was not produced"
endif
echo '# Command : $gtm_dist/mumps -run xcmp'
$gtm_dist/mumps -run xcmp >& xcmp.run < /dev/null
if ((1 == `$grep -c -- "-E-NUMOFLOW," xcmp.run`) && (0 == `$grep -c -x "line 2" xcmp.run`)) then
	echo "PASS : xcmp issued NUMOFLOW at the comparison"
else
	echo "FAIL : xcmp did not issue NUMOFLOW at the comparison - see xcmp.run"
endif
$gtm_tst/com/check_error_exist.csh xcmp.run NUMOFLOW >& /dev/null
echo

echo '# Stage 6 : compile and run a routine that XECUTEs a string literal with the comparison'
sed -n 1p xcmpx.m | sed 's/^/#   /'
echo '# Before the fix : the routine compiled with no error, and wrote 0 and line 2'
echo '# With the fix   : expect the compile to issue no error and produce an object file, and the XECUTE'
echo '#                  to issue NUMOFLOW when it runs'
echo '# Command : $gtm_dist/mumps xcmpx.m'
$gtm_dist/mumps xcmpx.m >& xcmpx.cmp
if (-z xcmpx.cmp) then
	echo "PASS : compiling xcmpx.m issued no error"
else
	echo "FAIL : compiling xcmpx.m issued the errors below"
	cat xcmpx.cmp
endif
if (-e xcmpx.o) then
	echo "PASS : xcmpx.o was produced"
else
	echo "FAIL : xcmpx.o was not produced"
endif
echo '# Command : $gtm_dist/mumps -run xcmpx'
$gtm_dist/mumps -run xcmpx >& xcmpx.run < /dev/null
if ((1 == `$grep -c -- "-E-NUMOFLOW," xcmpx.run`) && (0 == `$grep -c -x "line 2" xcmpx.run`)) then
	echo "PASS : xcmpx issued NUMOFLOW at the XECUTE"
else
	echo "FAIL : xcmpx did not issue NUMOFLOW at the XECUTE - see xcmpx.run"
endif
$gtm_tst/com/check_error_exist.csh xcmpx.run NUMOFLOW >& /dev/null
