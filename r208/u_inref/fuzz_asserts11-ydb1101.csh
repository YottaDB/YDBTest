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
echo '# [YDB#1101] JOB or an OPEN of a PIPE device with no file descriptor free does not fail an assert    #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage runs a label of ydb1101pipefd.m in a new process with a file descriptor limit of 64, checks that'
echo '# the output has no fatal error, and checks the lines that the stage writes. A stage opens files until'
echo '# an OPEN fails, and writes "usefds errno=<mnemonic>" for that failure. ydb1101pipefd.m writes the mnemonic,'
echo '# text and errno of an error, and each stage writes "end" at the end.'
echo

cp $gtm_tst/$tst/inref/ydb1101pipefd.m .
foreach stage (1 2)
	switch ($stage)
	case 1:
		echo '# Stage 1 : JOB with no file descriptor free'
		set expect = ('usefds errno=ENO24' 'error=JOBFAIL' 'text=Error creating pipe' 'errno=ENO24' 'end')
		breaksw
	case 2:
		echo '# Stage 2 : an OPEN of a PIPE device with no file descriptor free'
		set expect = ('usefds errno=ENO24' 'error=DEVOPENFAIL' 'text=PIPE - pipe(pfd_write) failed' 'errno=ENO24' 'end')
		breaksw
	endsw
	echo '# Command : limit descriptors 64 ; $gtm_dist/mumps -run '"stage${stage}^ydb1101pipefd, where the label has these lines"
	sed -n "/^stage$stage\t/,/^\tquit/p" ydb1101pipefd.m | sed 's/^/#   /'
	echo '# Before the fix : a Release build wrote the lines expected. A Debug build failed an assert in'
	echo '#                  gtm_fd_trace.c'
	echo "# With the fix   : expect each of these lines once : $expect"
	(limit descriptors 64 ; $gtm_dist/mumps -run stage${stage}^ydb1101pipefd >& stage$stage.out)
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
