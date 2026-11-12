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
echo '# [YDB#1101] A socket OPEN with an empty LISTEN or CONNECT address does not fail an assert           #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage runs a label of ydb1101addr.m in a new process, checks that the output has no fatal'
echo '# error, and checks the lines that the stage writes. ydb1101addr.m writes "error=<mnemonic>" for an'
echo '# error, and each stage writes "end" at the end.'
echo

cp $gtm_tst/$tst/inref/ydb1101addr.m .
foreach stage (1 2)
	switch ($stage)
	case 1:
		echo '# Stage 1 : an OPEN of a socket with LISTEN=""'
		breaksw
	case 2:
		echo '# Stage 2 : an OPEN of a socket with CONNECT=""'
		breaksw
	endsw
	set expect = ('error=INVPORTSPEC' 'end')
	echo '# Command : $gtm_dist/mumps -run '"stage${stage}^ydb1101addr, where the label has these lines"
	sed -n "/^stage$stage\t/,/^\tquit/p" ydb1101addr.m | sed 's/^/#   /'
	sed -n "/^open$stage(s)/,/^\tquit/p" ydb1101addr.m | sed 's/^/#   /'
	echo '# Before the fix : a Release build wrote the lines expected. A Debug build failed an assert in'
	echo '#                  iosocket_open.c'
	echo "# With the fix   : expect each of these lines once : $expect"
	$gtm_dist/mumps -run stage${stage}^ydb1101addr >& stage$stage.out
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
