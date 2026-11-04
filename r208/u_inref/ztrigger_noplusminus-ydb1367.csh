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
echo '# [YDB#1367] A $ZTRIGGER("ITEM") error for a line without + or - does not affect a later global SET  #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage creates a database in its own directory, runs the lines shown in a new process, and'
echo '# checks the output ($REFERENCE after the SET), the nodes of ^b in a new process, and MUPIP INTEG of'
echo '# the database.'
echo

cp $gtm_tst/$tst/inref/ydb1367.m .
# The input lines of each stage (written with echo, as a tcsh here document with a quoted delimiter does not end)
echo 'set x=$ztrigger("item","x") set ^b=1 write "$reference=",$reference,!' > stage1.inp
echo 'set x=$ztrigger("item"," +^a -commands=S -xecute=""set y=1""") set ^b=1 write "$reference=",$reference,!' > stage2.inp
echo 'set x=$ztrigger("item","+^a -badqual") set ^b=1 write "$reference=",$reference,!' > stage4.inp
echo 'set x=$ztrigger("item","+^a -commands=S -xecute=""set y=1""") set ^b=1 write "$reference=",$reference,!' > stage5.inp
foreach stage (1 2 3 4 5)
	set nref = 1
	switch ($stage)
	case 1:
		echo '# Stage 1 : $ZTRIGGER("ITEM") with the line x, then a SET of ^b on the same Direct Mode line'
		set before = ('a Release build stored the value under an empty global name ($REFERENCE was ^, ^b' \
			'was not there, and MUPIP INTEG reported DBBADKYNM). A Debug build failed an assert' \
			'in gv_srch_map.c')
		set expect = ('$reference=^b')
		set nodes = 1
		breaksw
	case 2:
		echo '# Stage 2 : the same with a trigger definition that starts with a space before the +'
		set before = ('a Release build stored the value under an empty global name ($REFERENCE was ^, ^b' \
			'was not there, and MUPIP INTEG reported DBBADKYNM). A Debug build failed an assert' \
			'in gv_srch_map.c')
		set expect = ('$reference=^b')
		set nodes = 1
		breaksw
	case 3:
		echo '# Stage 3 : the same 3 times in a loop of a compiled routine (ydb1367.m)'
		set before = ('a Release build stored the 3 values under an empty global name, and MUPIP INTEG' \
			'reported DBBADKYNM and DBCOMPTOOLRG. A Debug build failed an assert in' \
			'gv_srch_map.c')
		set expect = ('$reference=^b(1)' '$reference=^b(2)' '$reference=^b(3)')
		set nodes = 3
		set nref = 3
		breaksw
	case 4:
		echo '# Stage 4 : $ZTRIGGER("ITEM") with a line that has an unknown qualifier, then a SET of ^b'
		set before = ('$REFERENCE was ^b, ^b was there, and MUPIP INTEG reported no error (this stage is a' \
			'control)')
		set expect = ('$reference=^b')
		set nodes = 1
		breaksw
	case 5:
		echo '# Stage 5 : $ZTRIGGER("ITEM") with a valid line, then a SET of ^b'
		set before = ('$REFERENCE was ^b, ^b was there, and MUPIP INTEG reported no error (this stage is a' \
			'control)')
		set expect = ('$reference=^b')
		set nodes = 1
		breaksw
	endsw
	if (3 == $stage) then
		echo '# Command : $gtm_dist/mumps -run ydb1367, where ydb1367.m has these lines'
		sed -n '/^ydb1367/,$p' ydb1367.m | sed 's/^/#   /'
	else
		echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has this line"
		sed 's/^/#   /' stage$stage.inp
	endif
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	echo "# With the fix   : expect $expect,"
	echo "#                  $nodes node(s) of ^b, and no MUPIP INTEG error"
	mkdir stage$stage
	cd stage$stage
	$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
	if ($status) then
		echo "FAIL : dbcreate.csh failed - see stage$stage/dbcreate.out"
	endif
	if (3 == $stage) then
		$gtm_dist/mumps -run ydb1367 >& stage$stage.out
	else
		$gtm_dist/mumps -direct < ../stage$stage.inp >& stage$stage.out
	endif
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	set nfound = 0
	foreach line ($expect:q)
		@ nfound += `$grep -cFx -- "$line" stage$stage.out`
	end
	if ($nref == $nfound) then
		echo "PASS : stage$stage.out has $expect"
	else
		echo "FAIL : stage$stage.out does not have $expect"
	endif
	echo 'set n=$data(^b)#2,s="" for  set s=$order(^b(s)) quit:s=""  set n=n+1' > count.inp
	echo 'write "nodes=",n,!' >> count.inp
	set n = `$gtm_dist/mumps -direct < count.inp |& $grep -a "^nodes=" | sed 's/nodes=//'`
	if ("$nodes" == "$n") then
		echo "PASS : a new process sees $n node(s) of ^b"
	else
		echo "FAIL : a new process sees $n node(s) of ^b, but $nodes were expected"
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
