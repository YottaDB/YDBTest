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
echo "# [YDB#1339] Compiling an expression nested too deeply issues EXPRTOODEEP instead of a SIG-11        #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# The compiler processes an expression with recursive C functions. Tens of thousands of nested'
echo '# expression items (unary operators, parentheses, function arguments, subscripts), or a chain of tens of'
echo '# thousands of binary operators, used up the C stack and the process terminated with a SIG-11.'
echo '# The compiler now issues EXPRTOODEEP beyond 1024 levels of nested expression items or 4096 levels of'
echo '# operators. Each stage runs its case in a new process, and prints PASS or FAIL for each check.'
echo '# Stages 1 to 6 compile the expression with argument indirection (SET @arg), which accepts an argument'
echo '# longer than the maximum line length of 32766 bytes, then check that a later SET @arg still works.'
echo

cp $gtm_tst/$tst/inref/ydb1339.m .

foreach label (minus paren func subs plus and xecute routine limits)
	switch ($label)
	case "minus":
		echo '# Stage 1 : 100,000 unary minus operators'
		echo '# Before the fix : SIG-11'
		echo '# With the fix   : expect EXPRTOODEEP'
		breaksw
	case "paren":
		echo '# Stage 2 : 100,000 levels of parentheses'
		echo '# Before the fix : SIG-11'
		echo '# With the fix   : expect EXPRTOODEEP'
		breaksw
	case "func":
		echo '# Stage 3 : 100,000 nested $LENGTH() calls'
		echo '# Before the fix : SIG-11'
		echo '# With the fix   : expect EXPRTOODEEP'
		breaksw
	case "subs":
		echo '# Stage 4 : a local variable reference with 100,000 nested subscripts'
		echo '# Before the fix : SIG-11'
		echo '# With the fix   : expect EXPRTOODEEP'
		breaksw
	case "plus":
		echo '# Stage 5 : a chain of 100,000 + operators'
		echo '# Before the fix : SIG-11'
		echo '# With the fix   : expect EXPRTOODEEP'
		breaksw
	case "and":
		echo '# Stage 6 : a chain of 100,000 & operators'
		echo '# Before the fix : SIG-11'
		echo '# With the fix   : expect EXPRTOODEEP'
		breaksw
	case "xecute":
		echo '# Stage 7 : XECUTE of a SET with 30,000 unary minus operators, then XECUTE of a simple SET'
		echo '# Before the fix : no error in a Release build, and a SIG-11 in a Debug build'
		echo '# With the fix   : expect EXPRTOODEEP, and the later XECUTE to work'
		breaksw
	case "routine":
		echo '# Stage 8 : ZLINK a routine whose line 3 has 2,000 unary minus operators, line 4 a chain of 5,000 +'
		echo '#           operators, line 5 1,024 unary minus operators and line 6 a chain of 4,095 + operators (the'
		echo '#           maximum depths), then run it'
		echo '# Before the fix : the routine compiled and ran without an error'
		echo '# With the fix   : expect EXPRTOODEEP when compiling and when running lines 3 and 4, and lines 2, 5 and 6'
		echo '#                  to run'
		breaksw
	case "limits":
		echo '# Stage 9 : 1,000 levels of parentheses, a chain of 4,000 + operators and a chain of 2,000 & operators'
		echo '# Before the fix : the same result'
		echo '# With the fix   : expect all three to compile and evaluate correctly'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run '"$label"'^ydb1339'
	$gtm_dist/mumps -run $label^ydb1339
	echo
end
echo "# Done"
