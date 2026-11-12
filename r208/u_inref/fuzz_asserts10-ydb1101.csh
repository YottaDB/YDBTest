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
echo '# [YDB#1101] ZMESSAGE with more parameters than the text of the message has ! directives does not    #'
echo '# fail an assert                                                                                     #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage runs a ZMESSAGE in a new process, checks that the output has no fatal error, and checks'
echo '# that the output is the message and nothing else.'
echo

foreach stage (1 2)
	switch ($stage)
	case 1:
		echo '# Stage 1 : a ZMESSAGE of message number 150375463 (UNUSEDMSG571), whose entry in merrors.msg has a'
		echo '#           parameter count of 1 but whose text has no ! directive, with a parameter'
		set cmd = 'zmessage 150375463:"x"'
		set sev = U
		set err = UNUSEDMSG571
		set text = 'CCECCPPID nixed in r2.02 because it is a VMS only error'
		breaksw
	case 2:
		echo '# Stage 2 : a ZMESSAGE of message number 151027874 (TCPCONNTIMEOUT), whose text has one ! directive,'
		echo '#           with two parameters. The entry in ydberrors.msg had a parameter count of 2 before the fix'
		echo '#           and has 1 with the fix'
		set cmd = 'zmessage 151027874:5:6'
		set sev = E
		set err = TCPCONNTIMEOUT
		set text = 'Connection wait timeout (5 seconds) has expired'
		breaksw
	endsw
	echo "# Command : "'$gtm_dist/mumps -run %XCMD '"'$cmd'"
	echo '# Before the fix : a Release build wrote the message. A Debug build failed an assert in mval2fao.c'
	echo "# With the fix   : expect $err once, with the text : $text"
	$gtm_dist/mumps -run %XCMD "$cmd" >& stage$stage.out
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	if (1 == `$grep -cFx -- "%YDB-$sev-$err, $text" stage$stage.out`) then
		echo "PASS : stage$stage.out has $err once, with the text expected"
	else
		echo "FAIL : stage$stage.out does not have $err once with the text expected"
	endif
	set nlines = `cat stage$stage.out | wc -l`
	if (1 == $nlines) then
		echo "PASS : stage$stage.out has no other line"
	else
		echo "FAIL : stage$stage.out has $nlines lines, but 1 was expected"
	endif
	if ("E" == $sev) then
		$gtm_tst/com/check_error_exist.csh stage$stage.out $err
	endif
	echo
end
echo "# Done"
