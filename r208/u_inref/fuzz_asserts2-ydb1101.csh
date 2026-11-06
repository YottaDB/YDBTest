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
echo "# [YDB#1101] Error paths found by fuzz testing that failed asserts in a Debug build issue the error   #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage feeds the lines shown to "mumps -direct" in a new process, checks that the output has no'
echo '# fatal error, and checks that it has the errors named (which a Release build issued before the fix too).'
echo

# The input lines of each stage (written with echo, as a tcsh here document with a quoted delimiter does not end)
echo 'set x=""""' > stage1.inp
echo 'set @x@(1)=2' >> stage1.inp
echo 'zcompile "-object=0/ 0"' > stage2.inp
printf '\twrite "x",!\n' > x.m
echo 'zcompile "-object=0/ x"' > stage3.inp
echo 'for i=1:1:3000 set y(i)=$justify(i,300)' >> stage3.inp
echo 'write "after the loop, y has ",$order(y(""),-1)," nodes",!' >> stage3.inp
echo 'write $fnumber(1,"P"_$char(0)),!' > stage4.inp
echo 'set x=$ztrigger("item","+^zz -commands=S -xecute=""set y=1"""),x=$ztrigger("item","-*")' > stage5.inp
echo 'ZTSTART' >> stage5.inp
echo 'SET ^a=1' >> stage5.inp
echo 'ZTCOMMIT' >> stage5.inp
echo 'ZTSTART' >> stage5.inp
echo 'SET ^a=2' >> stage5.inp
echo 'write "after the second SET, $data(^a)=",$data(^a),!' >> stage5.inp
echo 'ZTCOMMIT' >> stage5.inp
echo 'set s="s" open s:(ioerror="")::"SOCKET"' > stage6.inp
echo 'set a=$translate($justify("",87)," ","0")_$char(0)_$translate($justify("",40)," ","0")' >> stage6.inp
echo 'use s:(LISTEN=a)' >> stage6.inp
echo 'set *a=$$"' > stage7.inp
echo 'write $zycompile(" set $x(1)=2"),!' > stage8.inp
echo 'write $select("1E47"&1:1)' > stage9.inp
echo 'write $select(1!"1E47":2)' >> stage9.inp
echo 'tstart' > stage10.inp
foreach i (1 2 3 4)
	echo 'trestart' >> stage10.inp
end
echo 'write "after the TRESTART commands, $tlevel=",$tlevel,!' >> stage10.inp
echo 'set a(1)="for a(2)=1:1:3 if $increment(a) xecute a(1)"' > stage11.inp
echo 'xecute a(1)' >> stage11.inp
echo 'write $select(a>1024:"PASS : more than 1024",1:"FAIL : only "_a)," levels of XECUTE were active when the stack ran low",!' >> stage11.inp
echo 'set f="t.file" tstart ()' > stage12.inp
echo 'open f:newversion use f write "x"' >> stage12.inp
echo 'open f:readonly' >> stage12.inp

# Stage 5 needs a database
echo '# Command : $gtm_tst/com/dbcreate.csh mumps (stage 5 uses the database)'
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
echo

foreach stage (1 2 3 4 5 6 7 8 9 10 11 12)
	switch ($stage)
	case 1:
		echo '# Stage 1 : an indirect name whose value has an unbalanced quote'
		set before = ('Before the fix, a Debug build failed an assert in op_indname.c in place of the VAREXPECTED error below')
		set errs = (VAREXPECTED)
		breaksw
	case 2:
		echo '# Stage 2 : ZCOMPILE with an -OBJECT qualifier that names a directory without a file name'
		set before = ('Before the fix, a Debug build failed an assert in zl_cmd_qlf.c in place of the FILENOTFND error below')
		set errs = (FILENOTFND)
		breaksw
	case 3:
		echo '# Stage 3 : the same ZCOMPILE with a routine that exists (x.m), and then enough use of the string pool'
		echo '# to need a garbage collection'
		set before = ('Before the fix, a Debug build failed an assert in zl_cmd_qlf.c after the errors below, and with only' \
			'that assert fixed, the loop then failed an assert in stp_gcol_src.h, as the error had not marked the' \
			'string pool usable again')
		set errs = (FILEPARSE FILENOTFND)
		breaksw
	case 4:
		echo '# Stage 4 : $FNUMBER with a format specifier that has a <NUL> byte'
		set before = ('Before the fix, a Debug build failed an assert in util_output.c in place of the FNUMARG error below')
		set errs = (FNUMARG)
		breaksw
	case 5:
		echo '# Stage 5 : a SET inside a ZTSTART fence, twice, in a database that has had a trigger (here on ^zz). Each'
		echo '# SET does an implicit TSTART (as the database has had a trigger), which a ZTSTART fence does not allow.'
		set before = ('Before the fix, a Debug build issued the first TPMIXUP error below and then failed an assert in' \
			'gvcst_put.c in the second SET')
		set errs = (TPMIXUP)
		breaksw
	case 6:
		echo '# Stage 6 : USE of a socket device with a LISTEN address that is too long and has a <NUL> byte'
		set before = ('Before the fix, a Debug build failed an assert in util_output.c in place of the ADDRTOOLONG error below')
		set errs = (ADDRTOOLONG)
		breaksw
	case 7:
		echo '# Stage 7 : a SET with an alias target and an extrinsic whose label is an unterminated string'
		set before = ('Before the fix, a Debug build failed an assert in exfunc.c in place of the LABELEXPECTED error below')
		set errs = (LABELEXPECTED)
		breaksw
	case 8:
		echo '# Stage 8 : $ZYCOMPILE of a SET whose target is an invalid function name'
		set before = ('Before the fix, a Debug build failed an assert in m_set.c in place of returning the INVFCN error below')
		set errs = (INVFCN)
		breaksw
	case 9:
		echo '# Stage 9 : $SELECT whose condition is a Boolean operation on a string literal that overflows as a number'
		set before = ('Before the fix, a Debug build failed an assert in put_tjmp.c in place of the first NUMOFLOW error below')
		set errs = (NUMOFLOW)
		breaksw
	case 10:
		echo '# Stage 10 : 4 TRESTART commands in a transaction that is not restartable (TSTART with no argument)'
		set before = ('Before the fix, a Debug build issued the TRESTNOT error below 4 times and then failed an assert in' \
			'op_dmode.c at the next Direct Mode prompt')
		set errs = (TRESTNOT)
		breaksw
	case 11:
		echo '# Stage 11 : a recursive XECUTE of a FOR whose control variable is subscripted, until STACKCRIT'
		set before = ('Before the fix, a Debug build failed an assert in glvn_pool.c (beyond 1024 levels) in place of the' \
			'STACKCRIT error below')
		set errs = (STACKCRIT)
		breaksw
	case 12:
		echo '# Stage 12 : the process exits with a transaction active, and closing a device at exit issues an error'
		set before = ('Before the fix, a Debug build failed an assert in exi_ch.c at exit and created core files' \
			'(no error is reported)')
		set errs = ()
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has these lines"
	sed 's/^/#   /' stage$stage.inp
	foreach line ($before:q)
		echo "# $line"
	end
	set ncorebefore = `ls -1 | $grep -c "^core"`
	$gtm_dist/mumps -direct < stage$stage.inp >& stage$stage.out
	set ncoreafter = `ls -1 | $grep -c "^core"`
	@ ncore = $ncoreafter - $ncorebefore
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	if (3 == $stage) $grep "after the loop" stage$stage.out
	if (5 == $stage) then
		$grep "after the second SET" stage$stage.out
		set ntpmixup = `$grep -c TPMIXUP stage$stage.out`
		if (2 == $ntpmixup) then
			echo "PASS : TPMIXUP was issued 2 times, once for each SET"
		else
			echo "FAIL : TPMIXUP was issued $ntpmixup times but 2 (once for each SET) were expected"
		endif
	endif
	if (10 == $stage) then
		$grep "after the TRESTART commands" stage$stage.out
		set ntrestnot = `$grep -c "TRESTNOT," stage$stage.out`
		if (4 == $ntrestnot) then
			echo "PASS : TRESTNOT was issued 4 times, once for each TRESTART"
		else
			echo "FAIL : TRESTNOT was issued $ntrestnot times but 4 (once for each TRESTART) were expected"
		endif
	endif
	if (11 == $stage) $grep "levels of XECUTE" stage$stage.out
	if (12 == $stage) then
		if (0 == $ncore) then
			echo "PASS : the process exited without creating a core file"
		else
			echo "FAIL : the process created $ncore core files at exit"
		endif
	endif
	if (4 == $stage) then
		# How the <NUL> byte in the format specifier shows in FNUMARG depends on the M or UTF-8 mode (chosen at random)
		$gtm_tst/com/check_error_exist.csh stage$stage.out $errs \
			| sed 's/^%YDB-E-FNUMARG, .*/%YDB-E-FNUMARG, <message showing the format specifier, which differs in M and UTF-8 modes>/'
	else if (6 == $stage) then
		# How the <NUL> byte in the address shows in ADDRTOOLONG depends on the M or UTF-8 mode (chosen at random)
		$gtm_tst/com/check_error_exist.csh stage$stage.out $errs \
			| sed 's/^\(%YDB-E-ADDRTOOLONG, Socket address \)[0.]* /\1<address, which differs in M and UTF-8 modes> /'
	else if (0 != $#errs) then
		$gtm_tst/com/check_error_exist.csh stage$stage.out $errs
	endif
	echo
end

$gtm_tst/com/dbcheck.csh >& dbcheck.out
echo "# Done"
