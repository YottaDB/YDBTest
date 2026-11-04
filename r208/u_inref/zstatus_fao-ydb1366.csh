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
echo '# [YDB#1366] SET $ZSTATUS in the error trap of a SET $ECODE displays a ! in the value as is          #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# t^ydb1366(val) does a SET $ECODE, whose $ETRAP sets $ZSTATUS to val and lets the error go to Direct'
echo '# Mode, which displays the error text and the entry reference of the new $ZSTATUS. Each stage feeds'
echo '# the lines shown to "mumps -direct" in a new process, checks that the output has no fatal YDB error,'
echo '# and checks the lines that are expected (shown with a tab as <TAB>).'
echo

cp $gtm_tst/$tst/inref/ydb1366.m .
# The input and the expected lines of each stage (written with printf, as a tcsh here document with a quoted delimiter does
# not end). \041 is the ! character, which is written that way here so that tcsh does not take the character as a history substitution.
printf 'do t^ydb1366("1,x,plain text")\n' > stage1.inp
printf 'do t^ydb1366("1,x,100%% done\041")\n' > stage2.inp
printf 'do t^ydb1366("1,x,a\041ADb")\n' > stage3.inp
printf 'do t^ydb1366("1,x,\041AD\041AD\041AD\041AD")\n' > stage4.inp
printf 'do t^ydb1366("1,x\041AD,text")\n' > stage5.inp
printf 'do t^ydb1366("no commas \041AD")\n' > stage6.inp
printf 'do INGEST^%%YDBJNLF("\041")\n' > stage7.inp
printf 'plain text\n\t\tAt M source location x\n' > stage1.exp
printf '100%% done\041\n\t\tAt M source location x\n' > stage2.exp
printf 'a\041ADb\n\t\tAt M source location x\n' > stage3.exp
printf '\041AD\041AD\041AD\041AD\n\t\tAt M source location x\n' > stage4.exp
printf 'text\n\t\tAt M source location x\041AD\n' > stage5.exp
printf 'no commas \041AD\n' > stage6.exp
printf '%%YDBJNLF-F-FILENOTEXIST Journal file \041 not found\n\t\tAt M source location INGEST+8^%%YDBJNLF\n' > stage7.exp
foreach stage (1 2 3 4 5 6 7)
	printf 'write "end",\041\n' >> stage$stage.inp
	switch ($stage)
	case 1:
		echo '# Stage 1 : $ZSTATUS with no ! in the value'
		set before = ('plain text, then the entry reference x (this stage is a control)')
		breaksw
	case 2:
		echo '# Stage 2 : a ! at the end of the error text'
		set before = ('a Release build displayed 100% done without the exclamation mark, followed by other' \
			'bytes from memory. A Debug build failed an assert in util_output.c')
		breaksw
	case 3:
		printf '# Stage 3 : \041AD in the error text\n'
		set before = ('a Release build terminated with a SIG-11. A Debug build displayed ab')
		breaksw
	case 4:
		printf '# Stage 4 : four \041AD in the error text\n'
		set before = ('Debug and Release builds terminated with a SIG-11')
		breaksw
	case 5:
		printf '# Stage 5 : \041AD in the entry reference\n'
		set before = ('a Release build terminated with a SIG-11. A Debug build displayed the entry' \
			'reference as x')
		breaksw
	case 6:
		printf '# Stage 6 : \041AD in a value with no comma (displayed as a whole)\n'
		set before = ('a Release build displayed "no commas " many times over, or terminated with a SIG-11' \
			'(each seen in different runs). A Debug build displayed "no commas "')
		breaksw
	case 7:
		echo '# Stage 7 : %YDBJNLF, which sets $ZSTATUS in this way with the journal file name in the error text'
		set before = ('a Release build displayed "Journal file ot found". A Debug build failed an assert' \
			'in util_output.c')
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has these lines"
	sed 's/^/#   /' stage$stage.inp
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	echo "# With the fix   : expect these lines"
	sed 's/\t/<TAB>/g;s/^/#   /' stage$stage.exp
	$gtm_dist/mumps -direct < stage$stage.inp >& stage$stage.out
	if (`$grep -c -- "%YDB-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	set nexp = `$grep -c "" stage$stage.exp`
	set nfound = `$grep -Fxc -f stage$stage.exp stage$stage.out`
	set nend = `$grep -Fxc "end" stage$stage.out`
	if (($nexp == $nfound) && (1 == $nend)) then
		echo "PASS : the $nexp expected lines are in stage$stage.out, and the next line of input ran"
	else
		echo "FAIL : $nfound of the $nexp expected lines are in stage$stage.out, and end is there $nend times"
	endif
	if (7 == $stage) then
		$gtm_tst/com/check_error_exist.csh stage$stage.out FILENOTEXIST
	endif
	echo
end
echo "# Done"
