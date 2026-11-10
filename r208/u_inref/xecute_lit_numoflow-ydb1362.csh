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
echo "# [YDB#1362] A routine that XECUTEs a string literal with a complement of a number that is too     #"
echo "# large compiles, and the XECUTE issues NUMOFLOW when it runs                                      #"
echo "#--------------------------------------------------------------------------------------------------#"
echo
echo '# When the argument of an XECUTE is one string literal, the compiler tries to compile the M code in'
echo '# the literal as part of the routine, with run_time set to TRUE. If that trial compile fails, the'
echo '# compiler compiles the XECUTE as usual, and the M code is compiled when the XECUTE runs.'
echo '# bx_boollit() issued NUMOFLOW with rts_error_csa() for a number that is too large under a complement'
echo '# in a Boolean expression. With run_time TRUE, that error was a real error, which abandoned the'
echo '# compilation of the whole routine, so no object file was produced. A - or + in place of the'
echo '# complement worked, because unary_tail() issues NUMOFLOW with stx_error(), which makes the XECUTE'
echo '# issue the error when it runs. $ZYCOMPILE() of a line with such a complement (with or without'
echo '# XECUTE) returned before setting its result, so the use of the result issued LVUNDEF.'
echo '#'
echo '# Stage 1 compiles and runs one routine per case. Each routine XECUTEs a string literal and writes'
echo '# the mnemonic of the error the XECUTE issues, or the value the XECUTE sets. Stages 2 and 3 run'
echo '# $ZYCOMPILE() of a line with such a complement, with and without XECUTE. Without the fix, the cases'
echo '# com, comonly, comcom, comneg and ifcom of stage 1 and stages 2 and 3 print FAIL, and the other'
echo '# cases of stage 1 PASS.'
echo

cp $gtm_tst/$tst/inref/ydb1362.m .
set names = `$gtm_dist/mumps -run gen^ydb1362`

echo '# Stage 1 : compile and run x<case>.m for each case'
echo '# Before the fix : for com, comonly, comcom, comneg and ifcom, the compile issued NUMOFLOW and'
echo '#                  produced no object file, so the routine could not run (ZLINKFILE, ZLNOOBJECT)'
echo '# With the fix   : expect each routine to compile with no error and produce an object file, and the'
echo '#                  XECUTE to issue NUMOFLOW when it runs (the result 0 for comsmall, whose number is'
echo '#                  not too large)'
foreach name ($names)
	set rtn = x$name
	if ("comsmall" == "$name") then
		set exp = 0
	else
		set exp = "%YDB-E-NUMOFLOW"
	endif
	echo "# Case $name : "`sed -n 2p $rtn.m | sed 's/^\t//'`
	echo '# Command : $gtm_dist/mumps '"$rtn.m"
	$gtm_dist/mumps $rtn.m >& $rtn.cmp
	if (! -z $rtn.cmp) then
		echo "FAIL : compiling $rtn.m issued the errors below"
		cat $rtn.cmp
	else
		echo "PASS: compiling $rtn.m issued no error"
	endif
	if (-e $rtn.o) then
		echo "PASS: $rtn.o was produced"
	else
		echo "FAIL : $rtn.o was not produced"
	endif
	echo '# Command : $gtm_dist/mumps -run '"$rtn"
	$gtm_dist/mumps -run $rtn >& $rtn.run
	set got = "`cat $rtn.run`"
	if ("$exp" == "$got") then
		echo "PASS: $rtn wrote $exp"
	else
		echo "FAIL : $rtn wrote the lines below instead of $exp"
		cat $rtn.run
	endif
end
echo

echo '# Stage 2 : $ZYCOMPILE() of a line that XECUTEs a string literal with a complement of a number that'
echo '#           is too large'
echo '# Before the fix : $ZYCOMPILE() left the result undefined, so the SET of the result issued LVUNDEF'
echo '# With the fix   : expect "", as the XECUTE issues NUMOFLOW when it runs'
echo '# Command : $gtm_dist/mumps -run zycx^ydb1362'
$gtm_dist/mumps -run zycx^ydb1362
echo

echo '# Stage 3 : $ZYCOMPILE() of a line with a complement of a number that is too large (no XECUTE)'
echo '# Before the fix : $ZYCOMPILE() left the result undefined, so the SET of the result issued LVUNDEF'
echo '# With the fix   : expect the NUMOFLOW error at column 21'
echo '# Command : $gtm_dist/mumps -run zycs^ydb1362'
$gtm_dist/mumps -run zycs^ydb1362
echo

echo "# Done"
