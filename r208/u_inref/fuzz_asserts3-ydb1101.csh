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
echo "# [YDB#1101] More code paths found by fuzz testing that failed asserts in a Debug build              #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage feeds the lines shown to "mumps -direct" in a new process, checks that the output has no'
echo '# fatal error, and checks the output that is expected.'
echo

# The input lines of each stage (written with echo and printf, as a tcsh here document with a quoted delimiter does not end)
printf 'f(n)\t; Recursive extrinsic function, each level called from an IF\n\tif n<20,$$f(n+1)\n\tquit 1\n' > f.m
echo 'write "$$^f(1)=",$$^f(1),!' > stage1.inp
echo 'set x=$ztrigger("item","+^x(index=:) -commands=S -xecute=""if $ztlevel<20,$increment(^x(index))""")' > stage2.inp
echo 'set ^x(1)=1' >> stage2.inp
echo 'write "^x(1)=",^x(1),!' >> stage2.inp
echo 'set x=$ztrigger("item","+^y -name=abc -commands=S -xecute=""set z=1""")' > stage3.inp
echo 'write "[",$text(^t0000000000000000000#0000000000#/DEFAULT),"]",!' >> stage3.inp
echo 'write "[",$text(^abc#/DEFAULT),"]",!' >> stage3.inp

# Stages 2 and 3 need a database
echo '# Command : $gtm_tst/com/dbcreate.csh mumps (stages 2 and 3 use the database)'
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
echo

foreach stage (1 2 3)
	switch ($stage)
	case 1:
		echo '# Stage 1 : an extrinsic function that calls itself 20 levels deep from an IF in each level (f.m)'
		set before = ('a Debug build failed an assert in bool_init.c, as the Debug build counted the IF of' \
			'every level as one more nested Boolean expression. GT.M and a Release build gave' \
			'$$^f(1)=1')
		set with = ('expect $$^f(1)=1')
		set expect = ('$$^f(1)=1')
		breaksw
	case 2:
		echo '# Stage 2 : a trigger that updates the node it is defined on from an IF, until $ZTLEVEL is 20'
		set before = ('a Debug build failed an assert in bool_init.c, as the Debug build counted the IF of' \
			'every trigger level as one more nested Boolean expression. GT.M and a Release build' \
			'gave ^x(1)=20')
		set with = ('expect ^x(1)=20 (the SET and an $INCREMENT() at each of the levels 1 to 19)')
		set expect = ('^x(1)=20')
		breaksw
	case 3:
		echo '# Stage 3 : $TEXT() of a trigger name that is too long for a trigger (32 bytes) in a region, and of a'
		echo '# trigger name that exists in that region'
		set before = ('a Debug build failed an assert in trigger_locate_andor_load.c (after the fix there,' \
			'also in trigger_source_read_andor_verify.c). GT.M and a Release build gave [] and' \
			'then the trigger code of abc')
		set with = ('expect [] (no such trigger) and then the trigger code of abc')
		set expect = ('[]' '[ set z=1]')
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has these lines"
	sed 's/^/#   /' stage$stage.inp
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	set label = "# With the fix   :"
	foreach line ($with:q)
		echo "$label $line"
		set label = "#                 "
	end
	$gtm_dist/mumps -direct < stage$stage.inp >& stage$stage.out
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	foreach line ($expect:q)
		if (`$grep -cFx -- "$line" stage$stage.out`) then
			echo "PASS : stage$stage.out has the line $line"
		else
			echo "FAIL : stage$stage.out does not have the line $line"
		endif
	end
	echo
end

$gtm_tst/com/dbcheck.csh >& dbcheck.out
echo "# Done"
