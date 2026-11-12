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
echo '# [YDB#1386] $NAME() of an indirect extended reference with no environment issues EXPR               #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage runs a label of ydb1386.m in a new process, checks that the output has no fatal error,'
echo '# and checks the lines that the stage writes. ydb1386.m writes "error=<mnemonic>" for an error, and each'
echo '# stage writes "end" at the end.'
echo

cp $gtm_tst/$tst/inref/ydb1386.m .
foreach stage (1 2)
	switch ($stage)
	case 1:
		echo '# Stage 1 : $NAME(@x) with x="^["'
		breaksw
	case 2:
		echo '# Stage 2 : $NAME(@x) with x="^[1,"'
		breaksw
	endsw
	set expect = ('error=EXPR' 'end')
	echo '# Command : $gtm_dist/mumps -run '"stage${stage}^ydb1386, where the label has these lines"
	sed -n "/^stage$stage\t/,/^\tquit/p" ydb1386.m | sed 's/^/#   /'
	sed -n "/^name(x)/,/^\tquit/p" ydb1386.m | sed 's/^/#   /'
	echo '# Before the fix : a Release build wrote error=INDRCOMPFAIL. A Debug build failed an assert in'
	echo '#                  comp_fini.c'
	echo "# With the fix   : expect each of these lines once : $expect"
	$gtm_dist/mumps -run stage${stage}^ydb1386 >& stage$stage.out
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	foreach line ($expect:q)
		if (1 == `$grep -cFx -- "$line" stage$stage.out`) then
			echo "PASS : stage$stage.out has $line"
		else
			echo "FAIL : stage$stage.out does not have $line once"
		endif
	end
	set nlines = `cat stage$stage.out | wc -l`
	if ($#expect == $nlines) then
		echo "PASS : stage$stage.out has no other line"
	else
		echo "FAIL : stage$stage.out has $nlines lines, but $#expect were expected"
	endif
	echo
end
echo "# Done"
