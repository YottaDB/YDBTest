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
echo '# [YDB#1374] $ZTRIGGER("ITEM") rejects a trigger subscript with two values next to each other        #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage creates a database in its own directory, runs the lines shown in Direct Mode in a new'
echo '# process, and checks that the output has no fatal error, has the line expected, the value that'
echo '# $ZTRIGGER() returns, and the number of triggers that $ZTRIGGER("SELECT") lists.'
echo

# The input lines of each stage (written with echo, as a tcsh here document with a quoted delimiter does not end)
echo 'set x=$ztrigger("item","+^x1(index=:--5) -commands=S,ZTR -xecute=""set y=1""")' > stage1.inp
echo 'write "x=",x,!' >> stage1.inp
echo 'write $ztrigger("select"),!' >> stage1.inp
echo 'write "end",!' >> stage1.inp
echo 'set x=$ztrigger("item","+^x1(-) -commands=S,ZTR -xecute=""set y=1""")' > stage2.inp
echo 'write "x=",x,!' >> stage2.inp
echo 'write $ztrigger("select"),!' >> stage2.inp
echo 'write "end",!' >> stage2.inp
echo 'set x=$ztrigger("item","+^x1(1.5.2) -commands=S,ZTR -xecute=""set y=1""")' > stage3.inp
echo 'write "x=",x,!' >> stage3.inp
echo 'write $ztrigger("select"),!' >> stage3.inp
echo 'write "end",!' >> stage3.inp
echo 'set x=$ztrigger("item","+^x1(1""a"") -commands=S,ZTR -xecute=""set y=1""")' > stage4.inp
echo 'write "x=",x,!' >> stage4.inp
echo 'write $ztrigger("select"),!' >> stage4.inp
echo 'write "end",!' >> stage4.inp
echo 'set x=$ztrigger("item","+^x1(index=:------""H""-------------------) -commands=S,ZTR -xecute=""set y=1""")' > stage5.inp
echo 'write "x=",x,!' >> stage5.inp
echo 'ztrigger ^x1(2)' >> stage5.inp
echo 'write $ztrigger("select"),!' >> stage5.inp
echo 'write "end",!' >> stage5.inp
echo 'set x=$ztrigger("item","+^x1(1;2;""a"") -commands=S,ZTR -xecute=""set y=1""")' > stage6.inp
echo 'write "x=",x,!' >> stage6.inp
echo 'write $ztrigger("select"),!' >> stage6.inp
echo 'write "end",!' >> stage6.inp
echo 'set x=$ztrigger("item","+^x1(-.5:.5) -commands=S,ZTR -xecute=""set y=1""")' > stage7.inp
echo 'write "x=",x,!' >> stage7.inp
echo 'write $ztrigger("select"),!' >> stage7.inp
echo 'write "end",!' >> stage7.inp
foreach stage (1 2 3 4 5 6 7)
	switch ($stage)
	case 1:
		echo '# Stage 1 : a range whose upper end is --5'
		set before = ('the trigger was added with the range index=:0-5')
		set expect = 'Invalid subscript'
		set ret = 0
		breaksw
	case 2:
		echo '# Stage 2 : a subscript that is only -'
		set before = ('the trigger was added on ^x1(0)')
		set expect = 'Invalid subscript'
		set ret = 0
		breaksw
	case 3:
		echo '# Stage 3 : a subscript with two decimal points'
		set before = ('the trigger was added on ^x1(1.52)')
		set expect = 'Invalid subscript'
		set ret = 0
		breaksw
	case 4:
		echo '# Stage 4 : a number followed by a string'
		set before = ('the trigger was added on ^x1(1"a")')
		set expect = 'Invalid subscript'
		set ret = 0
		breaksw
	case 5:
		echo '# Stage 5 : the range from fuzz testing, then a ZTRIGGER of ^x1(2)'
		set before = ('the trigger was added, and a Debug build failed an assert in gv_trigger.c at the' \
			'ZTRIGGER')
		set expect = 'Invalid subscript'
		set ret = 0
		breaksw
	case 6:
		echo '# Stage 6 : a subscript with three values separated by ;'
		set before = ('the trigger was added (this stage is a control)')
		set expect = 'Added SET and/or Non-SET trigger on ^x1 named x1#1'
		set ret = 1
		breaksw
	case 7:
		echo '# Stage 7 : a range with decimal ends'
		set before = ('the trigger was added (this stage is a control)')
		set expect = 'Added SET and/or Non-SET trigger on ^x1 named x1#1'
		set ret = 1
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has these lines"
	sed 's/^/#   /' stage$stage.inp
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	echo "# With the fix   : expect $expect,"
	echo "#                  "'$ZTRIGGER()'" returns $ret, and $ret trigger(s) listed"
	mkdir stage$stage
	cd stage$stage
	$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out
	if ($status) then
		echo "FAIL : dbcreate.csh failed - see stage$stage/dbcreate.out"
	endif
	$gtm_dist/mumps -direct < ../stage$stage.inp >& stage$stage.out
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	if (1 == `$grep -c -F -x -- "$expect" stage$stage.out`) then
		echo "PASS : stage$stage.out has $expect"
	else
		echo "FAIL : stage$stage.out does not have $expect once"
	endif
	if (1 == `$grep -c -F -x -- "x=$ret" stage$stage.out`) then
		echo 'PASS : $ZTRIGGER() returns '"$ret"
	else
		echo 'FAIL : $ZTRIGGER() does not return '"$ret - see stage$stage/stage$stage.out"
	endif
	set n = `$grep -c '^;trigger name:' stage$stage.out`
	if ("$ret" == "$n") then
		echo 'PASS : $ZTRIGGER("SELECT") lists '"$n trigger(s)"
	else
		echo 'FAIL : $ZTRIGGER("SELECT") lists '"$n trigger(s), but $ret was expected"
	endif
	if (1 == `$grep -c -x "end" stage$stage.out`) then
		echo "PASS : the last line of input ran"
	else
		echo "FAIL : the last line of input did not run"
	endif
	cd ..
	echo
end
echo "# Done"
