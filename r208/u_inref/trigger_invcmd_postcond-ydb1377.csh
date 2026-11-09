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
echo '# [YDB#1377] $ZTRIGGER("ITEM") of trigger code with an invalid command with a postconditional       #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage creates a database in its own directory, runs the lines shown in Direct Mode in a new'
echo '# process, and checks that the output has no fatal error, has the INVCMD error (or none), the value'
echo '# that $ZTRIGGER() returns, and the number of triggers that $ZTRIGGER("SELECT") lists. Stage 7 does'
echo '# the same with MUPIP TRIGGER.'
echo

# Stages 8 and 9 have bytes that are not valid in M code in M mode (in UTF-8 mode, $CHAR(255) is a valid character)
$switch_chset M >& switch_chset_m.out

# The xecute strings of the stages (stage 7 uses the one of stage 1)
set xec1 = 'f k=1:st repeat1:'
set xec2 = 'f k=1:2 repeat1:'
set xec3 = 'repeat1:'
set xec4 = 'repeat1:1 set y=1'
set xec5 = 'f k=1:2 zz'
set xec6 = 'set y=1'
# The input lines of stages 8 and 9 (written with echo, as a tcsh here document with a quoted delimiter does not end)
echo 'set t="+^c -commands=S -xecute=""zzz:y "_$char(255)_""""' > stage8.inp
echo 'set t="+^c -commands=S -xecute=""sxt:$ztlevel=1 ^%im"_$char(127)_"odtrigintp=10"""' > stage9.inp
foreach i (8 9)
	echo 'set x=$ztrigger("item",t)' >> stage$i.inp
	echo 'write "x=",x,!' >> stage$i.inp
	echo 'write $ztrigger("select"),!' >> stage$i.inp
	echo 'write "end",!' >> stage$i.inp
end
foreach stage (1 2 3 4 5 6 7 8 9)
	switch ($stage)
	case 1:
		echo '# Stage 1 : a FOR with a variable increment, then an invalid command with an empty postconditional'
		echo '# (from fuzz testing)'
		set before = ('Debug and Release builds failed with GTMASSERT2 (or an assert) in emit_code.c')
		breaksw
	case 2:
		echo '# Stage 2 : a FOR with a literal increment, then an invalid command with an empty postconditional'
		set before = ('INVCMD as a warning (-W-), and no trigger')
		breaksw
	case 3:
		echo '# Stage 3 : only an invalid command with an empty postconditional'
		set before = ('INVCMD as a warning (-W-), and no trigger')
		breaksw
	case 4:
		echo '# Stage 4 : an invalid command with a postconditional, then a valid command'
		set before = ('INVCMD as a warning (-W-), and no trigger')
		breaksw
	case 5:
		echo '# Stage 5 : a FOR, then an invalid command without a postconditional'
		set before = ('INVCMD as an error, and no trigger (this stage is a control)')
		breaksw
	case 6:
		echo '# Stage 6 : valid trigger code'
		set before = ('the trigger was added (this stage is a control)')
		breaksw
	case 7:
		echo '# Stage 7 : MUPIP TRIGGER -TRIGGERFILE with the trigger code of stage 1'
		set before = ('MUPIP TRIGGER failed with GTMASSERT2 in emit_code.c')
		breaksw
	case 8:
		echo '# Stage 8 : an invalid command with the postconditional y, then $CHAR(255) (from fuzz testing)'
		set before = ('a Release build terminated with a SIG-11, and a Debug build failed an assert in' \
			'jmp_opto.c')
		breaksw
	case 9:
		echo '# Stage 9 : an invalid command with the postconditional $ztlevel=1, then $CHAR(127) (from fuzz'
		echo '# testing)'
		set before = ('a Release build terminated with a SIG-11, and a Debug build failed an assert in' \
			'jmp_opto.c')
		breaksw
	endsw
	mkdir stage$stage
	cd stage$stage
	$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out
	if ($status) then
		echo "FAIL : dbcreate.csh failed - see stage$stage/dbcreate.out"
	endif
	if (6 == $stage) then
		set nerr_expect = 0
		set ret = 1
	else
		set nerr_expect = 1
		set ret = 0
	endif
	if (7 == $stage) then
		echo "+^c -commands=S -xecute="'"'"$xec1"'"' > stage7.trg
		echo '# Command : $gtm_exe/mupip trigger -triggerfile=stage7.trg -noprompt, where stage7.trg has this line'
		sed 's/^/#   /' stage7.trg
		$gtm_exe/mupip trigger -triggerfile=stage7.trg -noprompt >& stage7.out
		echo 'write $ztrigger("select"),!' > select.inp
		$gtm_dist/mumps -direct < select.inp >>& stage7.out
		echo "end" >> stage7.out
		set nret = `$grep -c "^0 trigger file entries have no errors" stage7.out`
	else
		if (8 > $stage) then
			eval 'set xec = "$xec'$stage'"'
			echo 'set x=$ztrigger("item","+^c -commands=S -xecute=""'"$xec"'""")' > stage$stage.inp
			echo 'write "x=",x,!' >> stage$stage.inp
			echo 'write $ztrigger("select"),!' >> stage$stage.inp
			echo 'write "end",!' >> stage$stage.inp
		else
			cp ../stage$stage.inp .
		endif
		echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has these lines"
		sed 's/^/#   /' stage$stage.inp
		$gtm_dist/mumps -direct < stage$stage.inp >& stage$stage.out
		set nret = `$grep -c -F -x "x=$ret" stage$stage.out`
	endif
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	if ($nerr_expect) then
		echo "# With the fix   : expect INVCMD as an error once and no trigger"
	else
		echo "# With the fix   : expect no INVCMD and the trigger to be added"
	endif
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	set nerr = `$grep -c -- "-E-INVCMD," stage$stage.out`
	set nwarn = `$grep -c -- "-W-INVCMD," stage$stage.out`
	if (($nerr_expect == $nerr) && (0 == $nwarn)) then
		echo "PASS : INVCMD was issued as an error $nerr time(s)"
	else
		echo "FAIL : INVCMD was issued as an error $nerr time(s) and as a warning $nwarn time(s) - see stage$stage/stage$stage.out"
	endif
	if (1 == $nret) then
		echo 'PASS : the trigger load returned the expected status'
	else
		echo 'FAIL : the trigger load did not return the expected status'" - see stage$stage/stage$stage.out"
	endif
	set n = `$grep -c '^;trigger name:' stage$stage.out`
	set nend = `$grep -c -F -x "end" stage$stage.out`
	if (("$ret" == "$n") && (1 == $nend)) then
		echo 'PASS : $ZTRIGGER("SELECT") lists '"$n trigger(s), and the last line of input ran"
	else
		echo 'FAIL : $ZTRIGGER("SELECT") lists '"$n trigger(s) ($ret expected), and end is there $nend times"
	endif
	if (7 == $stage) then
		$gtm_tst/com/check_error_exist.csh stage$stage.out INVCMD MUNOACTION >& /dev/null
	else if ($nerr) then
		$gtm_tst/com/check_error_exist.csh stage$stage.out INVCMD >& /dev/null
	endif
	$gtm_tst/com/dbcheck.csh >& dbcheck.out
	if ($status) then
		echo "FAIL : dbcheck.csh failed - see stage$stage/dbcheck.out"
	endif
	cd ..
	echo
end
