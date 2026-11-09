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
echo '# [YDB#1376] $ZTRIGGER("SELECT") and MUPIP TRIGGER -SELECT of a 31-character global name and *       #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# The database has a trigger on a global of 31 characters (^aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa). Each'
echo '# stage runs the command shown in a new process, and checks that the output has no fatal error and'
echo '# lists the trigger once.'
echo
$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out
if ($status) then
	echo "FAIL : dbcreate.csh failed - see dbcreate.out"
endif
set g31 = "^aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
set g30 = "^aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
echo "+$g31 -commands=S -xecute="'"set y=1"' > g31.trg
$gtm_exe/mupip trigger -triggerfile=g31.trg >& trigger_load.out
if (! `$grep -c "Added SET trigger on $g31 named" trigger_load.out`) then
	echo "FAIL : the trigger was not added - see trigger_load.out"
endif
set expect = "+$g31 -commands=S -xecute="'"set y=1"'
# The input lines of the Direct Mode stages (written with echo, as a tcsh here document with a quoted delimiter does not end)
echo 'set x=$ztrigger("select","'"$g31"'*")' > stage1.inp
echo 'write "end",!' >> stage1.inp
echo 'set x=$ztrigger("select","'"$g30"'*")' > stage2.inp
echo 'write "end",!' >> stage2.inp
foreach stage (1 2 3)
	switch ($stage)
	case 1:
		echo '# Stage 1 : $ZTRIGGER("SELECT") of the 31-character name followed by *'
		set before = ('a Debug build failed an assert in trigger_select.c, and a Release build was killed' \
			'by signal 6 (buffer overflow)')
		breaksw
	case 2:
		echo '# Stage 2 : $ZTRIGGER("SELECT") of the first 30 characters of the name followed by *'
		set before = ('the trigger was listed once (this stage is a control)')
		breaksw
	case 3:
		echo '# Stage 3 : MUPIP TRIGGER -SELECT of the 31-character name followed by *'
		set before = ('a Debug build failed an assert in trigger_select.c, and a Release build was killed' \
			'by signal 6 (buffer overflow)')
		breaksw
	endsw
	if (3 == $stage) then
		echo '# Command : $gtm_exe/mupip trigger -select="'"$g31"'*" stage3.trg'
		$gtm_exe/mupip trigger -select="$g31*" stage3.trg >& stage3.out
		if (-e stage3.trg) cat stage3.trg >>& stage3.out
		echo "end" >> stage3.out
	else
		echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has these lines"
		sed 's/^/#   /' stage$stage.inp
		$gtm_dist/mumps -direct < stage$stage.inp >& stage$stage.out
	endif
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	echo "# With the fix   : expect the trigger to be listed once"
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	set nlist = `$grep -c -F -x -- "$expect" stage$stage.out`
	set nend = `$grep -c -F -x "end" stage$stage.out`
	if ((1 == $nlist) && (1 == $nend)) then
		echo "PASS : the trigger is listed once, and the command finished"
	else
		echo "FAIL : the trigger is listed $nlist times, and end is there $nend times - see stage$stage.out"
	endif
	echo
end
$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "FAIL : dbcheck.csh failed - see dbcheck.out"
endif
