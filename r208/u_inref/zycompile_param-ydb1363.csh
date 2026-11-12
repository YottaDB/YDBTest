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
echo '# [YDB#1363] $ZYCOMPILE() returns the text of a compile error with the values of its parameters      #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# $ZYCOMPILE() returns POS,%YDB-E-MNEMONIC,text for a line with an error. For an error whose message'
echo '# has a parameter, the text had the placeholder of the message (for example \!UL) instead of the value.'
echo '# Each stage runs a label of ydb1363.m in a new process, and checks each line it writes. The output'
echo '# files are named stageN.outx, as the errors in them are expected.'
echo

cp $gtm_tst/$tst/inref/ydb1363.m .
foreach stage (1 2 3 4 5 6)
	switch ($stage)
	case 1:
		set label = maxargcnt
		echo '# Stage 1 : $ZYCOMPILE() of a line with more than 253 arguments of the _ operator (MAXARGCNT)'
		set before = ('Maximum number of arguments \!UL exceeded')
		set expect = ('$zycompile=513,%YDB-E-MAXARGCNT,Maximum number of arguments 253 exceeded')
		breaksw
	case 2:
		set label = badcase
		echo '# Stage 2 : $ZYCOMPILE() of a line with $ZCONVERT() and the case code "Q" (BADCASECODE)'
		set before = ('\!AD is not a valid case conversion code')
		set expect = ('$zycompile=25,%YDB-E-BADCASECODE,Q is not a valid case conversion code')
		breaksw
	case 3:
		set label = foroflow
		echo '# Stage 3 : $ZYCOMPILE() of a line with 40 nested FOR commands (FOROFLOW)'
		set before = ('FOR commands nested more than \!UL deep on a line')
		set expect = ('$zycompile=431,%YDB-E-FOROFLOW,FOR commands nested more than 31 deep on a line')
		breaksw
	case 4:
		set label = twoerrs
		echo '# Stage 4 : $ZYCOMPILE() of a line with two BADCASECODE errors, case codes "Q" and "R"'
		set before = ('\!AD is not a valid case conversion code')
		set expect = ('$zycompile=25,%YDB-E-BADCASECODE,Q is not a valid case conversion code')
		breaksw
	case 5:
		set label = noparm
		echo '# Stage 5 : $ZYCOMPILE() of a line with BADCASECODE, then of a line with COMMA (no parameter)'
		set before = ('\!AD is not a valid case conversion code, then the text of COMMA')
		set expect = ('$zycompile=25,%YDB-E-BADCASECODE,Q is not a valid case conversion code' \
			'$zycompile=18,%YDB-E-COMMA,Comma expected in this context')
		breaksw
	case 6:
		set label = invdlrcval
		echo '# Stage 6 : $ZYCOMPILE() of a line with $CHAR(10000000) in UTF-8 mode (INVDLRCVAL)'
		$switch_chset "UTF-8" >& switch_chset_utf8.out
		set before = ('Invalid $CHAR() value \!UL')
		set expect = ('$zycompile=23,%YDB-E-INVDLRCVAL,Invalid $CHAR() value 10000000')
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run '"${label}^ydb1363, where the label has these lines"
	sed -n "/^$label\t/,/^\tquit/p" ydb1363.m | sed 's/^/#   /'
	echo "# Before the fix : the text was $before"
	echo "# With the fix   : expect only these lines, each once :"
	foreach line ($expect:q)
		echo "#                  $line"
	end
	$gtm_dist/mumps -run ${label}^ydb1363 >& stage$stage.outx
	foreach line ($expect:q)
		if (1 == `$grep -cFx -- "$line" stage$stage.outx`) then
			echo "PASS : stage$stage.outx has $line"
		else
			echo "FAIL : stage$stage.outx does not have $line once"
		endif
	end
	set nlines = `cat stage$stage.outx | wc -l`
	if ($#expect == $nlines) then
		echo "PASS : stage$stage.outx has no other line"
	else
		echo "FAIL : stage$stage.outx has $nlines lines, but $#expect were expected"
	endif
	echo
end
echo "# Done"
