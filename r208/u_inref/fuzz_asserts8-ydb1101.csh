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
echo '# [YDB#1101] SET * of an undefined alias container with VIEW "NOUNDEF" does not fail                 #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage runs the lines shown in Direct Mode in a new process, and checks that the output has no'
echo '# fatal error, has the number of ALIASEXPECTED errors expected, and that the last line of input ran.'
echo

# The input lines of each stage (written with echo, as a tcsh here document with a quoted delimiter does not end)
echo 'view "NOUNDEF"' > stage1.inp
echo 'set *kk=c(2)' >> stage1.inp
echo 'write "end",!' >> stage1.inp
echo 'view "NOUNDEF"' > stage2.inp
echo 'set *a(1)=c(2)' >> stage2.inp
echo 'write "end",!' >> stage2.inp
echo 'set c(2)=1' > stage3.inp
echo 'set *kk=c(2)' >> stage3.inp
echo 'set *a(1)=c(2)' >> stage3.inp
echo 'write "end",!' >> stage3.inp
echo 'set d=5' > stage4.inp
echo 'set *c(2)=d' >> stage4.inp
echo 'set *kk=c(2)' >> stage4.inp
echo 'set *a(1)=c(2)' >> stage4.inp
echo 'write "kk=",kk," $zdata(kk)=",$zdata(kk),!' >> stage4.inp
echo 'write "end",!' >> stage4.inp
foreach stage (1 2 3 4)
	switch ($stage)
	case 1:
		echo '# Stage 1 : SET *alias=container with VIEW "NOUNDEF" and an undefined container (from fuzz testing)'
		set nexp = 1
		set before = ('a Debug build failed with a SIG-11 in op_setalsctin2als.c. A Release build issued' \
			'ALIASEXPECTED')
		breaksw
	case 2:
		echo '# Stage 2 : SET *container=container with VIEW "NOUNDEF" and an undefined source container'
		set nexp = 1
		set before = ('a Debug build failed with a SIG-11 in op_setalsct2alsct.c. A Release build issued' \
			'ALIASEXPECTED')
		breaksw
	case 3:
		echo '# Stage 3 : the same SET commands with a source that is defined but not an alias container'
		set nexp = 2
		set before = ('ALIASEXPECTED twice (this stage is a control)')
		breaksw
	case 4:
		echo '# Stage 4 : the same SET commands with an alias container'
		set nexp = 0
		set before = ('no error (this stage is a control)')
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has these lines"
	sed 's/^/#   /' stage$stage.inp
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	echo "# With the fix   : expect $nexp ALIASEXPECTED error(s)"
	$gtm_dist/mumps -direct < stage$stage.inp >& stage$stage.out
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	set nerr = `$grep -c -- "-E-ALIASEXPECTED," stage$stage.out`
	set nend = `$grep -Fxc "end" stage$stage.out`
	if (($nexp == $nerr) && (1 == $nend)) then
		echo "PASS : ALIASEXPECTED was issued $nerr time(s), and the last line of input ran"
	else
		echo "FAIL : ALIASEXPECTED was issued $nerr times ($nexp expected), and end is there $nend times"
	endif
	if (4 == $stage) then
		if (1 == `$grep -Fxc 'kk=5 $zdata(kk)=101' stage4.out`) then
			echo "PASS : kk is an alias of d"
		else
			echo "FAIL : kk is not an alias of d - see stage4.out"
		endif
	endif
	if ($nerr) $gtm_tst/com/check_error_exist.csh stage$stage.out ALIASEXPECTED >& /dev/null
	echo
end
