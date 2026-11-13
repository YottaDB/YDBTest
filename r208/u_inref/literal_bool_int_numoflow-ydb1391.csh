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
echo "# [YDB#1391] A string literal that is a number that is too large issues NUMOFLOW as a Boolean      #"
echo "# condition or an integer argument                                                                 #"
echo "#--------------------------------------------------------------------------------------------------#"
echo
echo '# The compiler computes the truth value of a literal condition (of IF, a postconditional or $SELECT())'
echo '# and the value of a literal integer argument of a function at compile time. It did not check that a'
echo '# string literal is a valid number, so a string literal that is a number that is too large, like'
echo '# "1E47", was true as a condition and 0 as an integer argument, instead of issuing NUMOFLOW, as the'
echo '# same code does when the string is in a variable. Stages 1 to 4 run in one process, and stage 5'
echo '# compiles and runs a routine.'
echo

cp $gtm_tst/$tst/inref/ydb1391.m .
foreach stage (1 2 3 4)
	switch ($stage)
	case 1:
		echo '# Stage 1 : the literal as a Boolean condition, compiled at run time (as in Direct Mode)'
		echo '# Before the fix : no error for each, as the literal was true'
		echo '# With the fix   : expect NUMOFLOW for each'
		breaksw
	case 2:
		echo '# Stage 2 : the literal as an integer argument of a function, compiled at run time'
		echo '# Before the fix : no error for each, as the literal was 0'
		echo '# With the fix   : expect NUMOFLOW for each'
		breaksw
	case 3:
		echo '# Stage 3 : $ZYCOMPILE() of a line with the literal as a condition and as an integer argument'
		echo '# Before the fix : $ZYCOMPILE() returned "" (no error)'
		echo '# With the fix   : expect NUMOFLOW'
		breaksw
	case 4:
		echo '# Stage 4 : literals that are numbers that are not too large, a string that is not a number,'
		echo '#           conditions that the compiler turns into a literal, the literal in a variable, and'
		echo '#           $CHAR() of the literal'
		echo '# Before the fix : the values below, and NUMOFLOW for the variable and for $CHAR() (this stage is'
		echo '#                  a control)'
		echo '# With the fix   : expect the same'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run '"stage$stage^ydb1391"
	$gtm_dist/mumps -run stage$stage^ydb1391 >& stage$stage.out
	$grep -E "^(PASS|FAIL) " stage$stage.out
	echo
end

set nlabels = `$gtm_dist/mumps -run gen^ydb1391`
echo '# Stage 5 : compile and run a routine with one label for each line of stages 1 and 2, and one for'
echo '#           $CHAR() of the literal'
echo '# Before the fix : the routine compiled with NUMOFLOW only for the $CHAR() line, and each label but'
echo '#                  the $CHAR() one ran with no error'
echo '# With the fix   : expect the compile to issue NUMOFLOW (a compile time warning) once for each label'
echo '#                  and produce an object file, and each label to issue NUMOFLOW when it runs'
echo '# Command : $gtm_dist/mumps xlit.m'
$gtm_dist/mumps xlit.m >& xlit.cmp
set nerr = `$grep -c -- "-E-NUMOFLOW," xlit.cmp`
if ($nlabels == $nerr) then
	echo "PASS : compiling xlit.m issued NUMOFLOW once for each of the $nlabels labels"
else
	echo "FAIL : compiling xlit.m issued NUMOFLOW $nerr times for $nlabels labels - see xlit.cmp"
endif
$gtm_tst/com/check_error_exist.csh xlit.cmp NUMOFLOW >& /dev/null
if (-e xlit.o) then
	echo "PASS : xlit.o was produced"
else
	echo "FAIL : xlit.o was not produced"
endif
echo '# Command : $gtm_dist/mumps -run stage5^ydb1391 '"$nlabels"
$gtm_dist/mumps -run stage5^ydb1391 $nlabels >& stage5.out
$grep -E "^(PASS|FAIL) " stage5.out
