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
echo '# [YDB#1372] $ZTRIGGER("ITEM") of an item that ends inside a subscript does not read past the item   #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage creates a database in its own directory, runs the lines shown in a new process, and'
echo '# checks that the output has no fatal error and has the lines expected, and the triggers that'
echo '# $ZTRIGGER("SELECT") lists at the end.'
echo

# The input lines of each stage (written with echo, as a tcsh here document with a quoted delimiter does not end)
set first = 'write $ztrigger("item","+^b(""ab"") -commands=S -xecute=""write 1"""),!'
set delete = 'write $ztrigger("item","-*"),!'
set select = 'write $ztrigger("select"),!'
echo "$first" > stage1.inp
echo "$delete" >> stage1.inp
echo 'write $ztrigger("item","+^b(""ab"),!' >> stage1.inp
echo "$select" >> stage1.inp
echo 'write $ztrigger("item","+^b(abc=1) -commands=S -xecute=""write 1"""),!' > stage2.inp
echo "$delete" >> stage2.inp
echo 'write $ztrigger("item","+^b(ab"),!' >> stage2.inp
echo "$select" >> stage2.inp
echo 'write $ztrigger("item","+^b(""ab"),!' > stage3.inp
echo "$select" >> stage3.inp
echo "$first" > stage4.inp
echo "$select" >> stage4.inp
echo 'set x="+^b(""ab"") -commands=S -xecute=""write 1""",y=$extract(x,1,7)' > stage5.inp
echo 'write $ztrigger("item",y),!' >> stage5.inp
echo "$select" >> stage5.inp
foreach stage (1 2 3 4 5)
	switch ($stage)
	case 1:
		echo '# Stage 1 : an item whose string subscript has no closing quote, after a longer item that had the'
		echo '# closing quote at the same place'
		set before = ('the third $ZTRIGGER() added +^b("ab") -commands=S -xecute="write 1", made from the' \
			'bytes of the first item')
		set expect = ('Invalid string')
		set trig = 0
		breaksw
	case 2:
		echo '# Stage 2 : an item that ends in a local variable name in a subscript, after a longer item with a'
		echo '# longer variable name at the same place'
		set before = ('Empty subscript not allowed (the parse went on with the bytes of the first item)')
		set expect = ('Invalid variable name in subscript')
		set trig = 0
		breaksw
	case 3:
		echo '# Stage 3 : the item of stage 1 as the first item of the process'
		set before = ('Invalid string, and no trigger (this stage is a control)')
		set expect = ('Invalid string')
		set trig = 0
		breaksw
	case 4:
		echo '# Stage 4 : the first item of stage 1 alone (a valid item with a string subscript)'
		set before = ('Added SET trigger on ^b named b#1 (this stage is a control)')
		set expect = ('Added SET trigger on ^b named b#1')
		set trig = 1
		breaksw
	case 5:
		echo '# Stage 5 : an item whose string subscript has no closing quote, which is the first part of a longer'
		echo '# string ($EXTRACT() of a valid item), so the closing quote of the longer string follows it'
		set before = ('Invalid string, and no trigger (this stage is a control. GT.M V7.2-001, which parses the' \
			'item where it is, reported Invalid XECUTE string, from the bytes after the item)')
		set expect = ('Invalid string')
		set trig = 0
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
	echo "#                  and $trig trigger(s) listed by "'$ZTRIGGER("SELECT")'" at the end"
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
	if (`$grep -c -F -- "$expect" stage$stage.out`) then
		echo "PASS : stage$stage.out has $expect"
	else
		echo "FAIL : stage$stage.out does not have $expect"
	endif
	set n = `$grep -c '^;trigger name:' stage$stage.out`
	if ("$trig" == "$n") then
		echo 'PASS : $ZTRIGGER("SELECT") lists '"$n trigger(s)"
	else
		echo 'FAIL : $ZTRIGGER("SELECT") lists '"$n trigger(s), but $trig was expected - see stage$stage/stage$stage.out"
	endif
	cd ..
	echo
end
echo "# Done"
