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
echo "# [YDB#1361] A syntax error in an invalid command with a negated invalid special variable name in    #"
echo "# its postconditional issues CMD                                                                     #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# T is not a command. Each stage feeds the line shown to "mumps -direct" in a new process (stage 3'
echo '# compiles a routine), checks that the output has no fatal error, and checks the errors expected.'
echo

# The input lines of each stage (written with echo and printf, as a tcsh here document with a quoted delimiter does not end)
echo "t:'"'$foo 0"' > stage1.inp
echo "t:'"'$t0 0"' > stage2.inp
printf "invcmd\tt:'"'$foo 0"\n\tquit\n' > invcmd.m
echo 't:1 0"' > stage4.inp

foreach stage (1 2 3 4)
	switch ($stage)
	case 1:
		echo '# Stage 1 : an invalid command whose postconditional negates an invalid special variable name, with'
		echo '# an unterminated string literal as its argument'
		set before = ('GT.M and a Release build issued INDRCOMPFAIL, which does not say what the error is.' \
			'A Debug build failed an assert in linetail.c')
		set with = ('expect CMD, as stage 4 issues')
		set errs = (CMD)
		breaksw
	case 2:
		echo '# Stage 2 : the same with $T0 as the invalid special variable name'
		set before = ('GT.M and a Release build issued INDRCOMPFAIL. A Debug build failed an assert in' \
			'linetail.c')
		set with = ('expect CMD')
		set errs = (CMD)
		breaksw
	case 3:
		echo '# Stage 3 : compiling a routine (invcmd.m) that has the line of stage 1'
		set before = ('GT.M and a Release build issued the INVCMD warning and the INVSVN error, but no' \
			'error for the rest of the line. A Debug build failed an assert in linetail.c after the' \
			'INVSVN error')
		set with = ('expect INVCMD, INVSVN and CMD')
		set errs = (INVCMD INVSVN CMD)
		breaksw
	case 4:
		echo '# Stage 4 : the line of stage 1 with a postconditional of 1'
		set before = ('CMD (this stage is a control)')
		set with = ('expect CMD')
		set errs = (CMD)
		breaksw
	endsw
	if (3 == $stage) then
		echo '# Command : $gtm_dist/mumps invcmd.m, where invcmd.m has these lines'
		sed 's/^/#   /' invcmd.m
	else
		echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has this line"
		sed 's/^/#   /' stage$stage.inp
	endif
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	echo "# With the fix   : $with"
	if (3 == $stage) then
		$gtm_dist/mumps invcmd.m >& stage$stage.out
	else
		$gtm_dist/mumps -direct < stage$stage.inp >& stage$stage.out
	endif
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	if (`$grep -c "INDRCOMPFAIL" stage$stage.out`) then
		echo "FAIL : stage$stage.out has INDRCOMPFAIL"
	else
		echo "PASS : no INDRCOMPFAIL in stage$stage.out"
	endif
	# check_error_exist.csh also takes the INVCMD warning for CMD, so count the CMD error itself
	set ncmd = `$grep -c -- "-E-CMD," stage$stage.out`
	if (1 == $ncmd) then
		echo "PASS : the CMD error was issued once"
	else
		echo "FAIL : the CMD error was issued $ncmd times but once was expected"
	endif
	$gtm_tst/com/check_error_exist.csh stage$stage.out $errs
	echo
end
echo "# Done"
