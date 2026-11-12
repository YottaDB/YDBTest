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
echo '# [YDB#1389] A naked reference whose subscripts are too long issues GVSUBOFLOW with the correct global  #'
echo '# variable in the GVIS message                                                                       #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage runs the lines shown in Direct Mode in a new process, and checks that the output has no'
echo '# fatal error, has the number of GVSUBOFLOW errors expected, has the GVIS line expected (when there is'
echo '# a GVSUBOFLOW error), and that the last line of input ran.'
echo
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "FAIL : dbcreate.csh failed - see dbcreate.out"
	exit 1
endif
# The input lines of each stage (written with echo, as a tcsh here document with a quoted delimiter does not end)
echo 'set ^b(1)="x" set ^($justify(9,2525))="y"' > stage1.inp
echo 'set ^b("a","b")="x" set ^($justify(9,2525))="y"' > stage2.inp
echo 'set ^b($justify(9,2525))="y"' > stage3.inp
echo 'set ^b("a",$justify(9,2525))="y"' > stage4.inp
echo 'set ^b(1,2)="x" set ^(3)="y" write "^b(1,3)=",^b(1,3),!' > stage5.inp
foreach stage (1 2 3 4 5)
	echo 'write "end",!' >> stage$stage.inp
end
foreach stage (1 2 3 4 5)
	set nexp = 1
	switch ($stage)
	case 1:
		echo '# Stage 1 : a naked reference that replaces the only subscript with one that is too long (from fuzz testing)'
		set gvis = '^b...'
		set before = ('a Debug build failed an assert in mval2subsc.c. A Release build issued GVSUBOFLOW' \
			'with bytes from past the end of the key in the GVIS message')
		breaksw
	case 2:
		echo '# Stage 2 : a naked reference that replaces the second subscript with one that is too long'
		set gvis = '^b("a"...'
		set before = ('a Debug build failed an assert in mval2subsc.c. A Release build issued GVSUBOFLOW' \
			'with bytes from past the end of the key in the GVIS message')
		breaksw
	case 3:
		echo '# Stage 3 : the global variable of stage 1 without a naked reference'
		set gvis = '^b...'
		set before = ('GVSUBOFLOW (this stage is a control)')
		breaksw
	case 4:
		echo '# Stage 4 : the global variable of stage 2 without a naked reference'
		set gvis = '^b("a"...'
		set before = ('GVSUBOFLOW (this stage is a control)')
		breaksw
	case 5:
		echo '# Stage 5 : a naked reference whose subscripts fit'
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
	if ($nexp) then
		echo "# With the fix   : expect 1 GVSUBOFLOW error, with $gvis in the GVIS message"
	else
		echo "# With the fix   : expect no error, and ^b(1,3) is y"
	endif
	$gtm_dist/mumps -direct < stage$stage.inp >& stage$stage.out
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	set nerr = `$grep -c -- "-E-GVSUBOFLOW," stage$stage.out`
	set nend = `$grep -Fxc "end" stage$stage.out`
	if (($nexp == $nerr) && (1 == $nend)) then
		echo "PASS : GVSUBOFLOW was issued $nerr time(s), and the last line of input ran"
	else
		echo "FAIL : GVSUBOFLOW was issued $nerr times ($nexp expected), and end is there $nend times"
	endif
	if ($nexp) then
		set ngvis = `$grep -Fxc "%YDB-I-GVIS, 		Global variable: $gvis" stage$stage.out`
		if (1 == $ngvis) then
			echo "PASS : the GVIS message is for $gvis"
		else
			echo "FAIL : the GVIS message is not for $gvis - see stage$stage.out"
		endif
	else
		if (1 == `$grep -Fxc '^b(1,3)=y' stage5.out`) then
			echo "PASS : ^b(1,3) is y"
		else
			echo "FAIL : ^b(1,3) is not y - see stage5.out"
		endif
	endif
	if ($nerr) $gtm_tst/com/check_error_exist.csh stage$stage.out GVSUBOFLOW >& /dev/null
	echo
end
$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "FAIL : dbcheck.csh failed - see dbcheck.out"
endif
