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
echo '# [YDB#1101] A socket OPEN with an empty ATTACH handle does not fail an assert                       #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage runs a label of ydb1101sock.m in a new process, checks that the output has no fatal'
echo '# error, and checks the lines that the stage writes. ydb1101sock.m writes "error=<mnemonic>" for an'
echo '# error, and each stage writes "end" at the end.'
echo

cp $gtm_tst/$tst/inref/ydb1101sock.m .
foreach stage (1 2 3)
	set before = 'a Release build wrote the lines expected. A Debug build failed an assert in'
	set before2 = 'iosocket_open.c'
	switch ($stage)
	case 1:
		echo '# Stage 1 : an OPEN of a listening socket with ATTACH="", then WRITE /LISTEN(1)'
		set expect = ('$key starts with LISTENING||' 'end')
		breaksw
	case 2:
		echo '# Stage 2 : the same OPEN twice for the same device (the second OPEN finds the socket with the empty'
		echo '# handle)'
		set expect = ('error=SOCKETEXIST' 'end')
		breaksw
	case 3:
		echo '# Stage 3 : an OPEN of a socket that connects to a listening socket of the process, with ATTACH=""'
		set expect = ('$key starts with ESTABLISHED||' 'end')
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run '"stage${stage}^ydb1101sock, where the label has these lines"
	sed -n "/^stage$stage\t/,/^\tquit/p" ydb1101sock.m | sed 's/^/#   /'
	if (2 == $stage) sed -n '/^open2(s)/,/^\tquit/p' ydb1101sock.m | sed 's/^/#   /'
	echo "# Before the fix : $before"
	echo "#                  $before2"
	echo "# With the fix   : expect each of these lines once : $expect"
	$gtm_dist/mumps -run stage${stage}^ydb1101sock >& stage$stage.out
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
