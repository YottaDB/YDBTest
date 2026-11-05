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
echo '# [YDB#1372] $ZTRIGGER("ITEM") of an item that ends in a number subscript does not read past the item#'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage creates a database in its own directory, runs the lines shown in Direct Mode in a new'
echo '# process, and checks that the output has no fatal error, has the line expected, and the number of'
echo '# triggers that $ZTRIGGER("SELECT") lists at the end.'
echo

# The input lines of each stage (written with echo, as a tcsh here document with a quoted delimiter does not end)
echo 'set x=$ztrigger("item","+^b(000000) -commands=S -xecute=""write 1""")' > stage1.inp
echo 'set x=$ztrigger("item","-*")' >> stage1.inp
echo 'set x=$ztrigger("item","+^b(100")' >> stage1.inp
echo 'write $ztrigger("select"),!' >> stage1.inp
echo 'write "end",!' >> stage1.inp
echo 'set x=$ztrigger("item","+^someglobal(1:000000) -commands=S -xecute=""set x=1""")' > stage2.inp
echo 'set x=$ztrigger("item","-*")' >> stage2.inp
echo 'set x=$ztrigger("item","+^someglobal(1:100")' >> stage2.inp
echo 'write $ztrigger("select"),!' >> stage2.inp
echo 'write "end",!' >> stage2.inp
echo 'set x=$ztrigger("item","+^b(100")' > stage3.inp
echo 'write $ztrigger("select"),!' >> stage3.inp
echo 'write "end",!' >> stage3.inp
echo 'set x=$ztrigger("item","+^b(000000) -commands=S -xecute=""write 1""")' > stage4.inp
echo 'write $ztrigger("select"),!' >> stage4.inp
echo 'write "end",!' >> stage4.inp
echo 'set x="+^b(100000) -commands=S -xecute=""write 1""",y=$extract(x,1,7)' > stage5.inp
echo 'set x=$ztrigger("item",y)' >> stage5.inp
echo 'write $ztrigger("select"),!' >> stage5.inp
echo 'write "end",!' >> stage5.inp
echo 'set x=$ztrigger("item","+^b(""abc"") -commands=S -xecute=""write 1""")' > stage6.inp
echo 'set x=$ztrigger("item","-*")' >> stage6.inp
echo 'set x=$ztrigger("item","+^b")' >> stage6.inp
echo 'write $ztrigger("select"),!' >> stage6.inp
echo 'write "end",!' >> stage6.inp
echo 'set x=$ztrigger("item","+^b($C(65,66)) -commands=S -xecute=""write 1""")' > stage7.inp
echo 'set x=$ztrigger("item","-*")' >> stage7.inp
echo 'set x=$ztrigger("item","+^b($C(65,66")' >> stage7.inp
echo 'write $ztrigger("select"),!' >> stage7.inp
echo 'write "end",!' >> stage7.inp
echo 'set x=$ztrigger("item","+^b($C(65,66),1) -commands=S -xecute=""write 1""")' > stage8.inp
echo 'set x=$ztrigger("item","-*")' >> stage8.inp
echo 'set x=$ztrigger("item","+^b($C(65,66)")' >> stage8.inp
echo 'write $ztrigger("select"),!' >> stage8.inp
echo 'write "end",!' >> stage8.inp
echo 'set x=$ztrigger("item","+^b(1:20) -commands=S -xecute=""write 1""")' > stage9.inp
echo 'set x=$ztrigger("item","-*")' >> stage9.inp
echo 'set x=$ztrigger("item","+^b(1:")' >> stage9.inp
echo 'write $ztrigger("select"),!' >> stage9.inp
echo 'write "end",!' >> stage9.inp
echo 'set x=$ztrigger("item","+^b(?1N.E) -commands=S -xecute=""write 1""")' > stage10.inp
echo 'set x=$ztrigger("item","-*")' >> stage10.inp
echo 'set x=$ztrigger("item","+^b(?1N.")' >> stage10.inp
echo 'write $ztrigger("select"),!' >> stage10.inp
echo 'write "end",!' >> stage10.inp
echo 'set x=$ztrigger("item","+^b(?1N) -commands=S -xecute=""write 1""")' > stage11.inp
echo 'set x=$ztrigger("item","-*")' >> stage11.inp
echo 'set x=$ztrigger("item","+^b(?1")' >> stage11.inp
echo 'write $ztrigger("select"),!' >> stage11.inp
echo 'write "end",!' >> stage11.inp
foreach stage (1 2 3 4 5 6 7 8 9 10 11)
	switch ($stage)
	case 1:
		echo '# Stage 1 : an item that ends in a number, after a longer item with digits at the same place'
		set before = ('the third $ZTRIGGER() added +^b(100000) -commands=S -xecute="write 1",' \
			'made from the bytes of the first item. With gtmdbglvl 0x40000 (which fills new storage with' \
			'0xdeadbeef), Invalid XECUTE string, from the bytes after the first item')
		set expect = 'Missing ")" after global subscript'
		set ntrig = 0
		breaksw
	case 2:
		echo '# Stage 2 : the same with a range (from fuzz testing)'
		set before = ('the third $ZTRIGGER() added +^someglobal(1:100000) -commands=S -xecute="set x=1",' \
			'made from the bytes of the first item. With gtmdbglvl 0x40000 (which fills new storage with' \
			'0xdeadbeef), Invalid XECUTE string, from the bytes after the first item')
		set expect = 'Missing ")" after global subscript'
		set ntrig = 0
		breaksw
	case 3:
		echo '# Stage 3 : the item of stage 1 as the first item of the process'
		set before = ('Missing ")" after global subscript, and no trigger (this stage is a control)')
		set expect = 'Missing ")" after global subscript'
		set ntrig = 0
		breaksw
	case 4:
		echo '# Stage 4 : the first item of stage 1 alone'
		set before = ('Added SET trigger on ^b named b#1 (this stage is a control)')
		set expect = 'Added SET trigger on ^b named b#1'
		set ntrig = 1
		breaksw
	case 5:
		echo '# Stage 5 : an item that ends in a number, which is the first part of a longer string ($EXTRACT()'
		echo '# of a valid item), so the digits and the ")" of the longer string follow it'
		set before = ('Missing ")" after global subscript, and no trigger (this stage is a control. GT.M' \
			'V7.2-001, which parses the item where it is, reported Invalid XECUTE string, from the bytes' \
			'after the item)')
		set expect = 'Missing ")" after global subscript'
		set ntrig = 0
		breaksw
	case 6:
		echo '# Stage 6 : an item that ends right after the global name, after a longer item'
		set before = ('Error: XECUTE value missing (the parse went on with the bytes of the first item)')
		set expect = 'Error : Invalid global name:'
		set ntrig = 0
		breaksw
	case 7:
		echo '# Stage 7 : an item that ends inside a $CHAR() subscript, after a longer item with the closing ")"'
		echo '# at the same place'
		set before = ('the third $ZTRIGGER() added +^b("AB") -commands=S -xecute="write 1",' \
			'made from the bytes of the first item. With gtmdbglvl 0x40000 (which fills new storage with' \
			'0xdeadbeef), Invalid XECUTE string, from the bytes after the first item')
		set expect = 'Invalid subscript'
		set ntrig = 0
		breaksw
	case 8:
		echo '# Stage 8 : an item that ends right after the ")" of a $CHAR() subscript, before the ")" that ends the'
		echo '# subscripts, after a longer item'
		set before = ('the third $ZTRIGGER() added +^b("AB",1) -commands=S -xecute="write 1",' \
			'made from the bytes of the first item. With gtmdbglvl 0x40000 (which fills new storage with' \
			'0xdeadbeef), Invalid XECUTE string, from the bytes after the first item')
		set expect = 'Missing ")" after global subscript'
		set ntrig = 0
		breaksw
	case 9:
		echo '# Stage 9 : an item that ends right after the ":" of a range, after a longer item'
		set before = ('the third $ZTRIGGER() added +^b(1:20) -commands=S -xecute="write 1",' \
			'made from the bytes of the first item. With gtmdbglvl 0x40000 (which fills new storage with' \
			'0xdeadbeef), Invalid XECUTE string, from the bytes after the first item')
		set expect = 'Missing ")" after global subscript'
		set ntrig = 0
		breaksw
	case 10:
		echo '# Stage 10 : an item that ends inside a pattern, after a longer item'
		set before = ('the third $ZTRIGGER() added +^b(*) -commands=S -xecute="write 1",' \
			'made from the bytes of the first item. With gtmdbglvl 0x40000 (which fills new storage with' \
			'0xdeadbeef), Invalid XECUTE string, from the bytes after the first item')
		set expect = 'Invalid pattern code'
		set ntrig = 0
		breaksw
	case 11:
		echo '# Stage 11 : an item that ends right after the repeat count of a pattern, after a longer item'
		set before = ('the third $ZTRIGGER() added +^b(?1N) -commands=S -xecute="write 1",' \
			'made from the bytes of the first item. With gtmdbglvl 0x40000 (which fills new storage with' \
			'0xdeadbeef), Invalid XECUTE string, from the bytes after the first item')
		set expect = 'Invalid pattern code'
		set ntrig = 0
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has these lines"
	sed 's/^/#   /' stage$stage.inp
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	echo "# With the fix   : expect $expect, and $ntrig trigger(s) listed at the end"
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
	set n = `$grep -c '^;trigger name:' stage$stage.out`
	if ("$ntrig" == "$n") then
		echo 'PASS : $ZTRIGGER("SELECT") lists '"$n trigger(s)"
	else
		echo 'FAIL : $ZTRIGGER("SELECT") lists '"$n trigger(s), but $ntrig was expected"
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
