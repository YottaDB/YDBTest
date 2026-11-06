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
echo "# [YDB#1344] Compiling a routine line with an invalid special variable or function name followed by #"
echo "# another syntax error issues the errors and produces an object file                                 #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# An invalid special variable name (INVSVN) or function name (INVFCN) is a compile time warning, so'
echo '# the compiler adds an OC_RTERROR triple and goes on parsing the line. When the line then has a real'
echo '# error, ins_errtriple() took that OC_RTERROR triple for an earlier error on the line and left the'
echo '# triples of the failed parse after it, which code generation could not handle. The compile ended with'
echo '# GTMASSERT2 in emit_code.c (an assert failure in emit_code.c in a Debug build).'
echo '#'
echo '# Without the fix, stages 1, 2 and 5 end the compile with GTMASSERT2 (or the assert failure), and print'
echo '# FAIL, and stages 3, 4 and 6 PASS.'
echo

cp $gtm_tst/$tst/inref/ydb1344.m .
set q = '"'
$gtm_dist/mumps -run gen^ydb1344

foreach stage (1 2 3 4)
	switch ($stage)
	case 1:
		set rtn = ydb1344a
		set errs = (INVSVN RPARENMISSING)
		echo '# Stage 1 : line 3 is [ w $length($zbar x]: INVSVN and then RPARENMISSING'
		set prev = 'the compile issued INVSVN and RPARENMISSING and then ended with GTMASSERT2 in emit_code.c'
		breaksw
	case 2:
		set rtn = ydb1344b
		set errs = (INVSVN MAXARGCNT)
		echo '# Stage 2 : line 3 is [ w $zfoo,a(1)_","_a(2)_","_ ... _","_a(128)]: INVSVN and then MAXARGCNT'
		set prev = 'the compile issued INVSVN and MAXARGCNT and then ended with GTMASSERT2 in emit_code.c'
		breaksw
	case 3:
		set rtn = ydb1344c
		set errs = (INVFCN EXPR)
		echo '# Stage 3 : line 3 is [ w $zbar(1)+$length(]: INVFCN and then EXPR'
		set prev = ''
		breaksw
	case 4:
		set rtn = ydb1344e
		set errs = (INVSVN)
		echo '# Stage 4 : line 3 is [ w $zbar]: INVSVN only'
		set prev = ''
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps '"$rtn.m"
	if ("" == "$prev") then
		echo '# Before the fix, this stage passed too, with the output below'
	else
		echo "# Before the fix, $prev"
		echo '# (an assert failure in emit_code.c in a Debug build), and the FAIL lines below were printed'
	endif
	echo "#   expect the errors ($errs), no GTMASSERT2 or assert failure, and $rtn.o to be produced"
	$gtm_dist/mumps $rtn.m >& $rtn.cmp
	$gtm_tst/com/check_error_exist.csh $rtn.cmp $errs
	$grep -aE "GTMASSERT|-F-ASSERT" ${rtn}.cmpx >& /dev/null
	if (! $status) then
		echo "FAIL : compiling $rtn.m failed an assert"
	else
		echo "PASS: compiling $rtn.m does not fail an assert"
	endif
	if (-e $rtn.o) then
		echo "PASS: $rtn.o was produced"
	else
		echo "FAIL : $rtn.o was not produced"
	endif
	echo '# Command : $gtm_dist/mumps -run %XCMD '"'do run^ydb1344(${q}$rtn${q},${q}$errs[1]${q})'"
	echo "#   expect line 2 to run and line 3 to issue the first error of the line ($errs[1])"
	$gtm_dist/mumps -run %XCMD "do run^ydb1344(${q}$rtn${q},${q}$errs[1]${q})"
	echo
end

echo '# Stage 5 : DO ^ydb1344d, whose line 3 is [ w $length($zbar x], compiles it with the automatic ZLINK'
echo '# Command : $gtm_dist/mumps -run %XCMD '"'do run^ydb1344(${q}ydb1344d${q},${q}INVSVN${q})'"
echo '# Before the fix, the automatic ZLINK issued INVSVN and RPARENMISSING and then ended with GTMASSERT2 in'
echo '# emit_code.c (an assert failure in emit_code.c in a Debug build), and the FAIL line below was printed'
echo '#   expect the compile to issue INVSVN and RPARENMISSING with no GTMASSERT2 or assert failure, line 2'
echo '#   to run and line 3 to issue INVSVN'
$gtm_dist/mumps -run %XCMD "do run^ydb1344(${q}ydb1344d${q},${q}INVSVN${q})" >& stage5.out
$gtm_tst/com/check_error_exist.csh stage5.out "INVSVN, Invalid" "RPARENMISSING, Right"
$grep -aE "GTMASSERT|-F-ASSERT" stage5.outx >& /dev/null
if (! $status) then
	echo "FAIL : the automatic ZLINK of ydb1344d failed an assert"
else
	echo "PASS: the automatic ZLINK of ydb1344d does not fail an assert"
endif
$grep -aE "PASS|FAIL|line . runs" stage5.out
echo

echo '# Stage 6 : a line with FALLINTOFLST (whose OC_RTERROR triple line() adds at the start of the line) and'
echo '#           NESTFORMP, the case YDB@c30512121 fixed'
echo '# Command : $gtm_dist/mumps ydb1344f.m'
echo '# Before the fix, this stage passed too, with the output below'
echo '#   expect FALLINTOFLST and NESTFORMP, and no GTMASSERT2 or assert failure'
echo ' do' > ydb1344f.m
echo ' . do' >> ydb1344f.m
echo 'LABLE(x) . w "Test"' >> ydb1344f.m
$gtm_dist/mumps ydb1344f.m >& ydb1344f.cmp
$gtm_tst/com/check_error_exist.csh ydb1344f.cmp FALLINTOFLST NESTFORMP
$grep -aE "GTMASSERT|-F-ASSERT" ydb1344f.cmpx >& /dev/null
if (! $status) then
	echo "FAIL : compiling ydb1344f.m failed an assert"
else
	echo "PASS: compiling ydb1344f.m does not fail an assert"
endif
