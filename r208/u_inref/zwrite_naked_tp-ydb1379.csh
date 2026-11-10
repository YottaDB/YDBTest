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
echo '# [YDB#1379] ZWRITE of a naked reference                                                             #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage creates a database in its own directory, runs the lines shown in Direct Mode in a new'
echo '# process, and checks that the output has no fatal error, has the lines expected, and that the last'
echo '# line of input ran.'
echo

# The input lines of each stage (written with echo, as a tcsh here document with a quoted delimiter does not end)
echo 'set ^d(1)=1,^d(2)=2' > stage1.inp
echo 'tstart ()' >> stage1.inp
echo 'zwrite ^(2)' >> stage1.inp
echo 'tcommit' >> stage1.inp
echo 'write "end",!' >> stage1.inp
echo 'set ^d(1)=1,^d(2)=2' > stage2.inp
echo 'tstart ()' >> stage2.inp
echo 'zwrite ^(*)' >> stage2.inp
echo 'tcommit' >> stage2.inp
echo 'write "end",!' >> stage2.inp
echo 'set ^d(1)=1 kill ^d' > stage3.inp
echo 'merge ^d(4)=^aglobalvar(1)' >> stage3.inp
echo 'tstart ()' >> stage3.inp
echo 'zwrite ^(2,"",1)' >> stage3.inp
echo 'tcommit' >> stage3.inp
echo 'write "end",!' >> stage3.inp
echo 'set ^d(1)=1,^d(2)=2' > stage4.inp
echo 'zwrite ^(2)' >> stage4.inp
echo 'write "end",!' >> stage4.inp
echo 'write $data(^d(1)),!' > stage5.inp
echo 'zsystem "$gtm_dist/mumps -run %XCMD ""set ^d(1)=5"""' >> stage5.inp
echo 'zwrite ^(1)' >> stage5.inp
echo 'write "end",!' >> stage5.inp
echo 'write $data(^d(1)),!' > stage6.inp
echo 'zsystem "$gtm_dist/mumps -run %XCMD ""set ^d(1)=5"""' >> stage6.inp
echo 'tstart ()' >> stage6.inp
echo 'zwrite ^(1)' >> stage6.inp
echo 'tcommit' >> stage6.inp
echo 'write "end",!' >> stage6.inp
echo 'set ^d("a",2)=3' > stage7.inp
echo 'write $order(^d("a","")),!' >> stage7.inp
echo 'zwrite ^(2)' >> stage7.inp
echo 'write "end",!' >> stage7.inp
echo 'set ^d("",2)=3,^d("",1,2)=4' > stage8.inp
echo 'write $order(^d("","")),!' >> stage8.inp
echo 'zwrite ^(2)' >> stage8.inp
echo 'write $order(^d("",1,"")),!' >> stage8.inp
echo 'zwrite ^(2)' >> stage8.inp
echo 'write "end",!' >> stage8.inp
foreach stage (1 2 3 4 5 6 7 8)
	set dbargs = ""
	set crash = ('a Release build terminated with a SIG-11 in gvcst_search(), and a Debug build' 'failed an assert in gvcst_data.c')
	switch ($stage)
	case 1:
		echo '# Stage 1 : ZWRITE of a naked reference in a transaction, after a SET before the transaction'
		set before = ($crash:q)
		set expect = ( '^d(2)=2' )
		set err = ""
		breaksw
	case 2:
		echo '# Stage 2 : the same with ^(*)'
		set before = ($crash:q)
		set expect = ( '^d(1)=1' '^d(2)=2' )
		set err = ""
		breaksw
	case 3:
		echo '# Stage 3 : ZWRITE of a naked reference in a transaction after a MERGE from an undefined global (from'
		echo '# fuzz testing)'
		set before = ($crash:q)
		set expect = ( )
		set err = GVUNDEF
		breaksw
	case 4:
		echo '# Stage 4 : ZWRITE of a naked reference with no transaction'
		set before = ('^d(2)=2 (this stage is a control)')
		set expect = ( '^d(2)=2' )
		set err = ""
		breaksw
	case 5:
		echo '# Stage 5 : ZWRITE of a naked reference to a global that another process created after the previous'
		echo '# reference found it undefined'
		set before = ('GVUNDEF')
		set expect = ( '^d(1)=5' )
		set err = ""
		breaksw
	case 6:
		echo '# Stage 6 : the same in a transaction'
		set before = ('GVUNDEF')
		set expect = ( '^d(1)=5' )
		set err = ""
		breaksw
	case 7:
		echo '# Stage 7 : ZWRITE of a naked reference after a $ORDER() with a null last subscript, on a region'
		echo '# with null subscripts NEVER (the key that ZWRITE uses, ^d("a",2), has no null subscript)'
		set dbargs = "-null_subscripts=NEVER"
		set before = ('NULSUBSC')
		set expect = ( '2' '^d("a",2)=3' )
		set err = ""
		breaksw
	case 8:
		echo '# Stage 8 : ZWRITE of naked references whose key has a null last subscript, ^d(""), and a null'
		echo '# subscript that is not the last, ^d("",1), on a region with null subscripts ALWAYS'
		set dbargs = "-null_subscripts=ALWAYS"
		set before = ('^d("",2)=3 and ^d("",1,2)=4 (this stage is a control)')
		set expect = ( '1' '^d("",2)=3' '2' '^d("",1,2)=4' )
		set err = ""
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has these lines"
	sed 's/^/#   /' stage$stage.inp
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	if ("" == "$err") then
		echo "# With the fix   : expect the lines $expect"
	else
		echo "# With the fix   : expect $err once"
	endif
	mkdir stage$stage
	cd stage$stage
	$gtm_tst/com/dbcreate.csh mumps 1 $dbargs >& dbcreate.out
	if ($status) then
		echo "FAIL : dbcreate.csh failed - see stage$stage/dbcreate.out"
	endif
	$gtm_dist/mumps -direct < ../stage$stage.inp >& stage$stage.out
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	foreach line ($expect:q)
		if (1 == `$grep -c -F -x -- "$line" stage$stage.out`) then
			echo "PASS : stage$stage.out has $line"
		else
			echo "FAIL : stage$stage.out does not have $line once - see stage$stage/stage$stage.out"
		endif
	end
	if ("" != "$err") then
		if (1 == `$grep -c -- "-E-$err," stage$stage.out`) then
			echo "PASS : $err was issued once"
		else
			echo "FAIL : $err was not issued once - see stage$stage/stage$stage.out"
		endif
		$gtm_tst/com/check_error_exist.csh stage$stage.out $err >& /dev/null
	endif
	if (1 == `$grep -c -F -x "end" stage$stage.out`) then
		echo "PASS : the last line of input ran"
	else
		echo "FAIL : the last line of input did not run - see stage$stage/stage$stage.out"
	endif
	$gtm_tst/com/dbcheck.csh >& dbcheck.out
	if ($status) then
		echo "FAIL : dbcheck.csh failed - see stage$stage/dbcheck.out"
	endif
	cd ..
	echo
end
