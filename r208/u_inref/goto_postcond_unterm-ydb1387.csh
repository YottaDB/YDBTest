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
echo '# [YDB#1387] GOTO or ZGOTO with a TRUE literal postconditional followed by a string with no closing    #'
echo '# quote issues SPOREOL instead of looping forever in the compiler                                    #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage runs the command shown in a new process (killed after 120 seconds), and checks that the'
echo '# process ended by itself, that the output has no fatal error, has the number of SPOREOL errors'
echo '# expected, and that the last line of input ran.'
echo
echo '# Create routine gx.m that GOTO jumps to'
echo 'x	write "at x",!' > gx.m
echo '	quit' >> gx.m
# The input lines of each stage (written with echo, as a tcsh here document with a quoted delimiter does not end)
echo 'goto x^gx:1 write "' > stage1.inp
echo 'zgoto 1:x^gx:1 write "' > stage2.inp
echo 'xecute "goto x^gx:1 write """' > stage3.inp
echo 'gp	goto x^gx:1 write "' > gp.m
echo '	quit' >> gp.m
echo 'goto x^gx:0 write "' > stage5.inp
echo 'xecute "goto x^gx:1 write ~"' > stage6.inp
# Each line of stage 7 has "*", "]" or "@" followed by the 2 bytes of the UTF-8 encoding of e with acute accent
printf 'goto x^gx:1 write 1*\303\251\ngoto x^gx:1 write 1]\303\251\ngoto x^gx:1 write 1@\303\251\n' > stage7.inp
foreach stage (1 2 3 5 6 7)
	echo 'write "end",!' >> stage$stage.inp
end
foreach stage (1 2 3 4 5 6 7)
	switch ($stage)
	case 1:
		echo '# Stage 1 : GOTO with a TRUE literal postconditional, then a string with no closing quote (from fuzz testing)'
		set nexp = 1
		set before = ('Debug and Release builds looped forever in m_goto_postcond.c (SIGTERM did not stop them)')
		breaksw
	case 2:
		echo '# Stage 2 : the same with ZGOTO'
		set nexp = 1
		set before = ('Debug and Release builds looped forever in m_goto_postcond.c (SIGTERM did not stop them)')
		breaksw
	case 3:
		echo '# Stage 3 : the same line as stage 1 in an XECUTE'
		set nexp = 1
		set before = ('Debug and Release builds looped forever in m_goto_postcond.c (SIGTERM did not stop them)')
		breaksw
	case 4:
		echo '# Stage 4 : the same line as stage 1 in a routine that is compiled'
		set nexp = 1
		set before = ('Debug and Release builds looped forever in m_goto_postcond.c (SIGTERM did not stop them)')
		breaksw
	case 5:
		echo '# Stage 5 : the same line as stage 1 with a FALSE literal postconditional'
		set nexp = 1
		set before = ('SPOREOL (this stage is a control)')
		breaksw
	case 6:
		echo '# Stage 6 : an invalid character after a TRUE literal postconditional is dead code and not checked'
		set nexp = 0
		set before = ('GOTO jumped to x^gx with no error (this stage is a control)')
		breaksw
	case 7:
		echo '# Stage 7 : "*", "]" or "@" followed by a byte above 127 after a TRUE literal postconditional'
		set nexp = 3
		set before = ('Debug and Release builds looped forever in m_goto_postcond.c (SIGTERM did not stop them)')
		breaksw
	endsw
	if (4 == $stage) then
		echo '# Command : $gtm_dist/mumps gp.m, where gp.m has these lines'
		sed 's/^/#   /' gp.m
	else
		echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has these lines"
		if (7 == $stage) echo '#   (cat -v shows the 2 bytes above 127 as M-C M-))'
		cat -v stage$stage.inp | sed 's/^/#   /'
	endif
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	if (6 == $stage) then
		echo "# With the fix   : expect no error, and the GOTO jumps to x^gx"
	else if (7 == $stage) then
		echo "# With the fix   : expect $nexp SPOREOL errors (one for each line)"
	else
		echo "# With the fix   : expect $nexp SPOREOL error"
	endif
	if (4 == $stage) then
		timeout --signal=KILL 120 $gtm_dist/mumps gp.m >& stage$stage.out
		set exitstat = $status
	else
		timeout --signal=KILL 120 $gtm_dist/mumps -direct < stage$stage.inp >& stage$stage.out
		set exitstat = $status
	endif
	if (137 == $exitstat) then
		echo "FAIL : the process was still running after 120 seconds and was killed"
	else
		echo "PASS : the process ended by itself"
	endif
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	set nerr = `$grep -c -- "-E-SPOREOL," stage$stage.out`
	if (4 == $stage) then
		if ((1 == $nerr) && (-e gp.o)) then
			echo "PASS : SPOREOL was issued once, and the compiler produced gp.o"
		else
			echo "FAIL : SPOREOL was issued $nerr times (1 expected), or gp.o is missing - see stage4.out"
		endif
	else
		set nend = `$grep -Fxc "end" stage$stage.out`
		if (($nexp == $nerr) && (1 == $nend)) then
			echo "PASS : SPOREOL was issued $nerr time(s), and the last line of input ran"
		else
			echo "FAIL : SPOREOL was issued $nerr times ($nexp expected), and end is there $nend times"
		endif
	endif
	if (6 == $stage) then
		if (1 == `$grep -Fxc "at x" stage6.out`) then
			echo "PASS : the GOTO jumped to x^gx"
		else
			echo "FAIL : the GOTO did not jump to x^gx - see stage6.out"
		endif
	endif
	if ($nerr) $gtm_tst/com/check_error_exist.csh stage$stage.out SPOREOL >& /dev/null
	echo
end
