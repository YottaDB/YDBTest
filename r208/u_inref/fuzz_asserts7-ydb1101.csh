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
echo '# [YDB#1101] $VIEW() with a long invalid global or local name does not fail an assert                #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage runs the lines shown in Direct Mode in a new process, and checks that the output has no'
echo '# fatal error, has the error expected once, and that the last line of input ran.'
echo

# The input lines of each stage (written with echo, as a tcsh here document with a quoted delimiter does not end)
echo 'set x="^a"_$justify("",300)_"b"' > stage1.inp
echo 'write $view("REGION",x),!' >> stage1.inp
echo 'write "end",!' >> stage1.inp
echo 'set x="^a"_$translate($justify("",40)," ",$char(0))_"b"' > stage2.inp
echo 'write $view("REGION",x),!' >> stage2.inp
echo 'write "end",!' >> stage2.inp
echo 'set y="a"_$translate($justify("",300)," ","#")' > stage3.inp
echo 'write $view("LV_REF",y),!' >> stage3.inp
echo 'write "end",!' >> stage3.inp
echo 'write $view("REGION","^a$"),!' > stage4.inp
echo 'write "end",!' >> stage4.inp
# $VIEW("REGION") needs a global directory
$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out
if ($status) then
	echo "FAIL : dbcreate.csh failed - see dbcreate.out"
endif
set ctl = ""
foreach stage (1 2 3 4)
	switch ($stage)
	case 1:
		echo '# Stage 1 : $VIEW("REGION") with an invalid global name of 303 bytes'
		set err = VIEWGVN
		set before = 'a Debug build failed an assert in format2zwr.c'
		breaksw
	case 2:
		echo '# Stage 2 : $VIEW("REGION") with a global name that has 40 NUL bytes (from fuzz testing)'
		set err = VIEWGVN
		set before = 'a Debug build failed an assert in format2zwr.c'
		breaksw
	case 3:
		echo '# Stage 3 : $VIEW("LV_REF") with an invalid local name of 301 bytes'
		set err = VIEWLVN
		set before = 'a Debug build failed an assert in format2zwr.c'
		breaksw
	case 4:
		echo '# Stage 4 : $VIEW("REGION") with a short invalid global name'
		set err = VIEWGVN
		set before = 'VIEWGVN in a Debug build'
		set ctl = ' (this stage is a control)'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has these lines"
	sed 's/^/#   /' stage$stage.inp
	echo "# Before the fix : $before. A Release build issued $err$ctl"
	echo "# With the fix   : expect $err"
	$gtm_dist/mumps -direct < stage$stage.inp >& stage$stage.out
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	set nerr = `$grep -c -- "-E-$err," stage$stage.out`
	set nend = `$grep -Fxc "end" stage$stage.out`
	if ((1 == $nerr) && (1 == $nend)) then
		echo "PASS : $err was issued once, and the next line of input ran"
	else
		echo "FAIL : $err was issued $nerr times, and end is there $nend times"
	endif
	$gtm_tst/com/check_error_exist.csh stage$stage.out $err >& /dev/null
	echo
end
echo "# Done"
