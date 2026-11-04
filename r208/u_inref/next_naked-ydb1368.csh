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
echo '# [YDB#1368] A naked global reference after $NEXT() returns -1 uses the right node                   #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage creates a database in its own directory, runs a label of ydb1368.m in a new process, and'
echo '# checks the output of the label, the nodes of ^x that a new process sees (with ZWRITE), and MUPIP'
echo '# INTEG.'
echo

cp $gtm_tst/$tst/inref/ydb1368.m .
foreach stage (1 2 3 4 5 6 7)
	set label = stage$stage
	set dbopt = ""
	switch ($stage)
	case 1:
		echo '# Stage 1 : a SET of a naked reference after a $NEXT() that returns -1'
		set before = ('the SET stored the value under an invalid subscript ($REFERENCE was ^x(-1.04*8*)),' \
			'a new process saw no node of ^x, and MUPIP INTEG reported DBBADNSUB')
		set expect = ('$next=-1' '$reference=^x(7)')
		set nodes = ('^x(1)=1' '^x(7)="seven"')
		breaksw
	case 2:
		echo '# Stage 2 : a $GET() of a naked reference after a $NEXT() that returns -1'
		set before = ('$GET() returned an empty string and $REFERENCE was ^x(-1.04*1+)')
		set expect = ('$next=-1' '$get=1' '$reference=^x(1)')
		set nodes = ('^x(1)=1')
		breaksw
	case 3:
		echo '# Stage 3 : a loop of 40 $NEXT() of a naked reference, each of which returns -1'
		set before = ('a Release build issued GVSUBOFLOW, with an invalid subscript in GVIS. A Debug build' \
			'failed an assert in format_targ_key.c')
		set expect = ('$next=-1' 'i=40 y=-1' '$reference=^x(-1)')
		set nodes = ()
		breaksw
	case 4:
		echo '# Stage 4 : a SET of a naked reference with 2 subscripts after a $NEXT() that returns -1'
		set before = ('the SET stored the value under an invalid subscript ($REFERENCE was' \
			'^x(3,-1.04*6*)), a new process saw no node of ^x, and MUPIP INTEG reported' \
			'DBBADNSUB')
		set expect = ('$next=-1' '$reference=^x(3,9)')
		set nodes = ('^x(3,1)=31' '^x(3,9)="nine"')
		breaksw
	case 5:
		echo '# Stage 5 : stage 1 with a database that allows null subscripts, with standard null collation'
		set label = stage1
		set dbopt = "-null_subscripts=TRUE -stdnull"
		set before = ('the SET stored the value under an invalid subscript ($REFERENCE was ^x(-1.04*8*)),' \
			'a new process saw no node of ^x, and MUPIP INTEG reported DBBADNSUB')
		set expect = ('$next=-1' '$reference=^x(7)')
		set nodes = ('^x(1)=1' '^x(7)="seven"')
		breaksw
	case 6:
		echo '# Stage 6 : stage 1 with a database that allows null subscripts, with GT.M null collation'
		set label = stage1
		set dbopt = "-null_subscripts=TRUE -nostdnull"
		set before = ('the SET stored the value under an invalid subscript ($REFERENCE was ^x(-1.04*8*)),' \
			'a new process saw no node of ^x, and MUPIP INTEG reported DBBADNSUB')
		set expect = ('$next=-1' '$reference=^x(7)')
		set nodes = ('^x(1)=1' '^x(7)="seven"')
		breaksw
	case 7:
		echo '# Stage 7 : a $ORDER() and then a SET of a naked reference after a $NEXT() that returns -1'
		set before = ('$ORDER() returned an empty string ($REFERENCE was ^x(-1.07*)), the SET stored the' \
			'value under an invalid subscript ($REFERENCE was ^x(-1.04*8*)), a new process saw' \
			'no node of ^x, and MUPIP INTEG reported DBBADNSUB')
		set expect = ('$next=-1' '$order=1' '$reference=^x(0)' '$reference=^x(7)')
		set nodes = ('^x(1)=1' '^x(7)="seven"')
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run '"${label}^ydb1368, where the label has these lines"
	sed -n "/^$label\t/,/^\tquit/p" ydb1368.m | sed 's/^/#   /'
	if ("" != "$dbopt") echo "# Database : dbcreate.csh mumps 1 $dbopt"
	set prefix = "# Before the fix :"
	foreach line ($before:q)
		echo "$prefix $line"
		set prefix = "#                 "
	end
	echo "# With the fix   : expect each of these lines once :"
	echo "#                  $expect"
	if ($#nodes) then
		echo "#                  a new process sees only these nodes of ^x : $nodes"
	else
		echo "#                  a new process sees no node of ^x"
	endif
	echo "#                  and MUPIP INTEG reports no error"
	mkdir stage$stage
	cd stage$stage
	$gtm_tst/com/dbcreate.csh mumps 1 $dbopt >& dbcreate.out
	if ($status) then
		echo "FAIL : dbcreate.csh failed - see stage$stage/dbcreate.out"
	endif
	$gtm_dist/mumps -run ${label}^ydb1368 >& stage$stage.out
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	foreach line ($expect:q)
		if (1 == `$grep -cFx -- "$line" stage$stage.out`) then
			echo "PASS : stage$stage.out has $line"
		else
			echo "FAIL : stage$stage.out does not have $line once"
		endif
	end
	set nlines = `cat stage$stage.out | wc -l`
	if ($#expect == $nlines) then
		echo "PASS : stage$stage.out has no other line"
	else
		echo "FAIL : stage$stage.out has $nlines lines, but $#expect were expected"
	endif
	echo 'if $data(^x) zwrite ^x' > zwr.inp
	$gtm_dist/mumps -direct < zwr.inp |& $grep -a '^\^x' > zwr.out
	set nfound = 0
	foreach line ($nodes:q)
		@ nfound += `$grep -cFx -- "$line" zwr.out`
	end
	set nzwr = `cat zwr.out | wc -l`
	if (($#nodes == $nfound) && ($#nodes == $nzwr)) then
		echo "PASS : a new process sees only the $#nodes node(s) of ^x expected"
	else
		echo "FAIL : a new process sees $nzwr node(s) of ^x, $nfound of the $#nodes expected - see stage$stage/zwr.out"
	endif
	$gtm_dist/mupip integ -region "*" >& integ.out
	if (`$grep -c "No errors detected by integ" integ.out`) then
		echo "PASS : MUPIP INTEG reports no error"
	else
		echo "FAIL : MUPIP INTEG reports errors - see stage$stage/integ.out"
		mv integ.out integ.outx
	endif
	cd ..
	echo
end
echo "# Done"
