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
echo "# [YDB#1359] An undefined local variable as an indirect routine name issues LVUNDEF                 #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# zz.m is a routine that says when it is called. In stages 1 to 4, the local variable rtn held the'
echo '# name zz and was then killed, after zz was linked. Each stage runs in a new process, checks that the'
echo '# output has no fatal error and has the LVUNDEF error expected, and that zz was not used.'
echo

# The routines and the input lines of each stage (written with echo and printf, as a tcsh here document with a quoted
# delimiter does not end)
printf 'zz\twrite "zz was called",!\n\tquit:$quit 1\n\tquit\n' > zz.m
printf 'newy\t; A routine that does a NEW of a local variable\n\tnew y\n\tquit\n' > newy.m
printf 'caller\tset $etrap="write $zstatus,! set $ecode="""""\n\tzlink "zz"\n\tset rtn="zz",x="^@rtn"\n\tkill rtn\n' > caller.m
printf '\tdo d1,d2\n\tquit\nd1\tdo ^@rtn\n\tquit\nd2\tdo @x\n\tquit\n' >> caller.m
foreach stage (1 2 3)
	echo 'zlink "zz"' > stage$stage.inp
	echo 'set rtn="zz" kill rtn' >> stage$stage.inp
end
echo 'do ^@rtn' >> stage1.inp
echo 'write "[",$text(+1^@rtn),"]",!' >> stage2.inp
echo 'write $$^@rtn,!' >> stage3.inp
echo 'do ^newy' > stage5.inp
echo 'do ^@M' >> stage5.inp
echo 'do ^newy' > stage6.inp
echo 'write $text(^@E),!' >> stage6.inp

foreach stage (1 2 3 4 5 6)
	set nlvundef = 1
	switch ($stage)
	case 1:
		echo '# Stage 1 : DO ^@rtn in Direct Mode'
		set before = ('called zz (zz was called), with no error')
		set with = ('expect LVUNDEF')
		breaksw
	case 2:
		echo '# Stage 2 : $TEXT(+1^@rtn) in Direct Mode'
		set before = ('returned the first line of zz, with no error')
		set with = ('expect LVUNDEF')
		breaksw
	case 3:
		echo '# Stage 3 : $$^@rtn in Direct Mode'
		set before = ('found zz and issued FMLLSTMISSING for it in place of LVUNDEF')
		set with = ('expect LVUNDEF')
		breaksw
	case 4:
		echo '# Stage 4 : DO ^@rtn and DO @x (x="^@rtn") in a compiled routine (caller.m), with a $ETRAP that writes'
		echo '# $ZSTATUS and goes on'
		set before = ('called zz twice (zz was called), with no error')
		set with = ('expect LVUNDEF twice')
		set nlvundef = 2
		breaksw
	case 5:
		echo '# Stage 5 : DO ^@M with M undefined, after a call of a routine that does a NEW of a local variable'
		echo '#           (newy.m)'
		set before = ('a Release build issued LVUNDEF. A Debug build terminated with a SIG-11 in' \
			'find_rtn_tabent(), as the storage of M held the 0xFD bytes that a Debug build' \
			'fills new memory with')
		set with = ('expect LVUNDEF')
		breaksw
	case 6:
		echo '# Stage 6 : $TEXT(^@E) with E undefined, after the same call'
		set before = ('a Release build issued RTNNAME. A Debug build failed an assert in' \
			'gtm_memcpy_validate_and_execute.c')
		set with = ('expect LVUNDEF')
		breaksw
	endsw
	if (4 == $stage) then
		echo '# Command : $gtm_dist/mumps -run caller, where caller.m has these lines'
		sed 's/^/#   /' caller.m
	else
		echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has these lines"
		sed 's/^/#   /' stage$stage.inp
	endif
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	echo "# With the fix   : $with"
	if (4 == $stage) then
		$gtm_dist/mumps -run caller >& stage$stage.out
	else
		$gtm_dist/mumps -direct < stage$stage.inp >& stage$stage.out
	endif
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	set ncalled = `$grep -c "^zz was called" stage$stage.out`
	set ntext = `$grep -c '^\[zz' stage$stage.out`
	if (0 == $ncalled && 0 == $ntext) then
		echo "PASS : zz was not called and its text was not returned"
	else
		echo "FAIL : zz was called $ncalled times and its text was returned $ntext times"
	endif
	set nerr = `$grep -c "LVUNDEF" stage$stage.out`
	if ($nlvundef == $nerr) then
		echo "PASS : LVUNDEF was issued $nerr times"
	else
		echo "FAIL : LVUNDEF was issued $nerr times but $nlvundef were expected"
	endif
	$gtm_tst/com/check_error_exist.csh stage$stage.out LVUNDEF
	echo
end
echo "# Done"
