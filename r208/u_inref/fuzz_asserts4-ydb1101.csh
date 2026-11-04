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
echo "# [YDB#1101] An @# indirect name or a postconditional that overflows does not fail an assert         #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage feeds the lines shown to "mumps -direct" in a new process, checks that the output has no'
echo '# fatal error, and checks for the error that is expected and that the next line of input ran.'
echo

# The input lines of each stage (written with echo and printf, as a tcsh here document with a quoted delimiter does not end)
echo 'set a="@#" new (@a)' > stage1.inp
echo 'set a="@#" kill (@a)' > stage2.inp
echo 'set a="@#" xecute "new (@a)"' > stage3.inp
echo 'set a="@#x" new (@a)' > stage4.inp
printf 'zz\tquit\nc\twrite "in c",!\n\tquit\n' > zz.m
echo 'do c^zz:"1E47"&1' > stage5.inp
echo 'goto c^zz:"1E47"&1' > stage6.inp
echo 'xecute "write 1,!":"1E47"&1' > stage7.inp
echo 'if "1E47"&1 do c^zz' > stage8.inp
echo 'write $select("1E47"&1:"yes",1:"no"),!' > stage9.inp
echo 'do:"1E47"&1 c^zz' > stage10.inp
foreach stage (1 2 3 4 5 6 7 8 9 10)
	echo 'write "end",!' >> stage$stage.inp
	set err = EXPR
	set assertfile = indirection.c
	set before = ""
	switch ($stage)
	case 1:
		echo '# Stage 1 : an exclusive NEW of @a, with a="@#" (the at-hash token, then nothing)'
		breaksw
	case 2:
		echo '# Stage 2 : the same with an exclusive KILL'
		breaksw
	case 3:
		echo '# Stage 3 : the same NEW as stage 1 in an XECUTE'
		breaksw
	case 4:
		echo '# Stage 4 : an exclusive NEW of @a, with a="@#x"'
		set err = LVUNDEF
		breaksw
	case 5:
		echo '# Stage 5 : a DO with a postconditional on its argument whose string literal overflows as a number'
		echo '# (zz.m has the label c, which writes "in c")'
		set err = NUMOFLOW
		set assertfile = put_tjmp.c
		breaksw
	case 6:
		echo '# Stage 6 : the same with a GOTO'
		set err = NUMOFLOW
		set assertfile = put_tjmp.c
		breaksw
	case 7:
		echo '# Stage 7 : the same with an XECUTE'
		set err = NUMOFLOW
		set assertfile = put_tjmp.c
		breaksw
	case 8:
		echo '# Stage 8 : the same Boolean expression as the argument of an IF (this stage is a control)'
		set err = NUMOFLOW
		set before = "Debug and Release builds issued $err"
		breaksw
	case 9:
		echo '# Stage 9 : the same Boolean expression as a $SELECT() condition (this stage is a control)'
		set err = NUMOFLOW
		set before = "Debug and Release builds issued $err"
		breaksw
	case 10:
		echo '# Stage 10 : the same Boolean expression as a postconditional on DO (this stage is a control)'
		set err = NUMOFLOW
		set before = "Debug and Release builds issued $err"
		breaksw
	endsw
	if ("" == "$before") set before = "a Release build issued $err. A Debug build failed an assert in $assertfile"
	echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has these lines"
	sed 's/^/#   /' stage$stage.inp
	echo "# Before the fix : $before"
	echo "# With the fix   : expect $err"
	$gtm_dist/mumps -direct < stage$stage.inp >& stage$stage.out
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	set nerr = `$grep -c -- "-E-$err," stage$stage.out`
	set nend = `$grep -Fxc "end" stage$stage.out`
	set ncall = `$grep -Fxc "in c" stage$stage.out`
	if ((1 == $nerr) && (1 == $nend) && (0 == $ncall)) then
		echo "PASS : $err was issued once, c^zz did not run, and the next line of input ran"
	else
		echo "FAIL : $err was issued $nerr times, c^zz ran $ncall times, and end is there $nend times"
	endif
	$gtm_tst/com/check_error_exist.csh stage$stage.out $err
	echo
end
echo "# Done"
