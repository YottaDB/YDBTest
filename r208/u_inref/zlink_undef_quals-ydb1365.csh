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
echo "# [YDB#1365] ZLINK with an undefined local variable as the qualifiers issues LVUNDEF                 #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage runs in a new process, checks that the output has no fatal error, and counts the LVUNDEF'
echo '# and CLIERR errors and the calls of zz.m (a routine that says when zz.m is called).'
echo

# The routines and the input lines of each stage (written with echo and printf, as a tcsh here document with a quoted
# delimiter does not end)
printf 'zz\twrite "zz was called",!\n\tquit\n' > zz.m
printf 'caller\tset $etrap="write $zstatus,! set $ecode="""""\n\tset q="-bogus"\n\tkill q\n\tzlink "zz":q\n\tquit\n' > caller.m
echo 'set q="-bogus" kill q zlink "zz":q' > stage1.inp
echo 'zlink "zz":undefq' > stage2.inp
echo 'write $$^%PEEKBYNAME("")' > stage4.inp
echo 'zlink "zz":qlf' >> stage4.inp
echo 'view "NOUNDEF" zlink "zz":undefq do ^zz' > stage5.inp
echo 'set q="-nolist" zlink "zz":q do ^zz' > stage6.inp

foreach stage (1 2 3 4 5 6)
	set nlvundef = 1
	set ncall = 0
	switch ($stage)
	case 1:
		echo '# Stage 1 : ZLINK with a qualifiers variable that held -bogus and was killed, in Direct Mode'
		set before = ('used -bogus (CLIERR Unrecognized option : BOGUS)')
		set with = ('expect LVUNDEF')
		breaksw
	case 2:
		echo '# Stage 2 : ZLINK with a qualifiers variable that was never set, in Direct Mode'
		set before = ('linked zz with no qualifiers and no error')
		set with = ('expect LVUNDEF')
		breaksw
	case 3:
		echo '# Stage 3 : the same as stage 1 in a compiled routine (caller.m), with a $ETRAP that writes $ZSTATUS'
		echo '# and goes on'
		set before = ('used -bogus (CLIERR Unrecognized option : BOGUS)')
		set with = ('expect LVUNDEF')
		breaksw
	case 4:
		echo '# Stage 4 : ZLINK with the qualifiers variable qlf undefined, after $$^%PEEKBYNAME("")'
		set before = ('a Release build linked zz with no error. A Debug build failed an assert in' \
			'zl_cmd_qlf.c, as the storage of qlf held the 0xFD bytes that a Debug build fills' \
			'new memory with')
		set with = ('expect LVUNDEF')
		breaksw
	case 5:
		echo '# Stage 5 : ZLINK with a qualifiers variable that was never set, after VIEW "NOUNDEF", then DO ^zz'
		set before = ('linked zz with no qualifiers, with no error (this stage is a control)')
		set with = ('expect no error (NOUNDEF makes the variable an empty string), and zz to be called')
		set nlvundef = 0
		set ncall = 1
		breaksw
	case 6:
		echo '# Stage 6 : ZLINK with a qualifiers variable that holds -nolist, then DO ^zz'
		set before = ('linked zz, with no error (this stage is a control)')
		set with = ('expect no error, and zz to be called')
		set nlvundef = 0
		set ncall = 1
		breaksw
	endsw
	if (3 == $stage) then
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
	rm -f zz.o
	if (3 == $stage) then
		$gtm_dist/mumps -run caller >& stage$stage.out
	else
		$gtm_dist/mumps -direct < stage$stage.inp >& stage$stage.out
	endif
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	set nerr = `$grep -c "LVUNDEF" stage$stage.out`
	set nclierr = `$grep -c "CLIERR" stage$stage.out`
	set ncalled = `$grep -c "^zz was called" stage$stage.out`
	if (($nlvundef == $nerr) && (0 == $nclierr) && ($ncall == $ncalled)) then
		echo "PASS : LVUNDEF was issued $nerr times, CLIERR 0 times, and zz was called $ncalled times"
	else
		echo "FAIL : LVUNDEF was issued $nerr times, CLIERR $nclierr times, and zz was called $ncalled times," \
			"but $nlvundef, 0 and $ncall were expected"
	endif
	if (4 == $stage) then
		$gtm_tst/com/check_error_exist.csh stage$stage.out LVUNDEF PBNNOFIELD
	else if ($nlvundef) then
		$gtm_tst/com/check_error_exist.csh stage$stage.out LVUNDEF
	endif
	echo
end
echo "# Done"
