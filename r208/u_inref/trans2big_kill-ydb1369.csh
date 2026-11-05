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
echo '# [YDB#1369] A TCOMMIT after a KILL that fails with TRANS2BIG does not damage the database           #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage creates a database in its own directory, runs the lines shown in Direct Mode (or the routine'
echo '# shown) in a new process, and checks that the output has the lines expected, the values that a new'
echo '# process sees, and MUPIP INTEG.'
echo

# The input lines of each stage (written with echo, as a tcsh here document with a quoted delimiter does not end)
echo 'set ^a(1)=1' > stage1.inp
echo 'tstart ()' >> stage1.inp
echo 'for i=1:1:1E6 kill ^a(1) set ^a(1)=$justify(1,150)' >> stage1.inp
echo 'tcommit' >> stage1.inp
echo 'write "$tlevel=",$tlevel,!' >> stage1.inp
echo 'trollback' >> stage1.inp
echo 'write "end",!' >> stage1.inp
echo 'set ^a(1)=1' > stage2.inp
echo 'tstart ()' >> stage2.inp
echo 'for i=1:1:1E6 kill ^a(1) set ^a(1)=$justify(1,150)' >> stage2.inp
echo 'trollback' >> stage2.inp
echo 'tstart ()' >> stage2.inp
echo 'set ^b=2' >> stage2.inp
echo 'tcommit' >> stage2.inp
echo 'write "$tlevel=",$tlevel,!' >> stage2.inp
echo 'write "end",!' >> stage2.inp
echo 'set ^a(1)=1' > stage3.inp
echo 'tstart ()' >> stage3.inp
echo 'set ^c=3' >> stage3.inp
echo 'tstart ()' >> stage3.inp
echo 'for i=1:1:1E6 kill ^a(1) set ^a(1)=$justify(1,150)' >> stage3.inp
echo 'tcommit' >> stage3.inp
echo 'write "inner $tlevel=",$tlevel,!' >> stage3.inp
echo 'tcommit' >> stage3.inp
echo 'write "outer $tlevel=",$tlevel,!' >> stage3.inp
echo 'trollback' >> stage3.inp
echo 'write "end",!' >> stage3.inp
echo 'set ^a(1)=1' > stage4.inp
echo 'tstart ()' >> stage4.inp
echo 'set ^c=3' >> stage4.inp
echo 'tstart ()' >> stage4.inp
echo 'for i=1:1:1E6 kill ^a(1) set ^a(1)=$justify(1,150)' >> stage4.inp
echo 'trollback -1' >> stage4.inp
echo 'tcommit' >> stage4.inp
echo 'write "$tlevel=",$tlevel,!' >> stage4.inp
echo 'write "end",!' >> stage4.inp
echo 'set ^a(1)=1' > stage5.inp
echo 'tstart ()  if '"'"'$trestart for i=1:1:1E6 kill ^a(1) set ^a(1)=$justify(1,150)' >> stage5.inp
echo 'trestart' >> stage5.inp
echo 'write "$tlevel=",$tlevel," $trestart=",$trestart,!' >> stage5.inp
echo 'set ^d=4' >> stage5.inp
echo 'tcommit' >> stage5.inp
echo 'write "$tlevel=",$tlevel,!' >> stage5.inp
echo 'write "end",!' >> stage5.inp
echo 'set n=0,j="" for  set j=$order(^a(5,j)) quit:j=""  set n=n+1' > values.inp
echo 'write "a(1)=",$get(^a(1))," b=",$get(^b)," c=",$get(^c)," d=",$get(^d)," a(5,*) nodes=",n,!' >> values.inp
foreach stage (1 2 3 4 5 6 7)
	switch ($stage)
	case 1:
		echo '# Stage 1 : a loop of KILL and SET of ^a(1) in a transaction until TRANS2BIG, then TCOMMIT'
		set before = ('the TCOMMIT committed part of the KILL that issued TRANS2BIG ($TLEVEL was 0), a new' \
			'process got GVDATAFAIL for ^a, and MUPIP INTEG reported DBBDBALLOC')
		set expect = ('$tlevel=1' 'end')
		set ntrans2big = 2
		set values = 'a(1)=1 b= c= d= a(5,*) nodes=0'
		breaksw
	case 2:
		echo '# Stage 2 : the same with TROLLBACK after TRANS2BIG, then a new transaction that sets ^b'
		set before = ('the new transaction committed, and a new process saw ^b=2 (this stage is a control)')
		set expect = ('$tlevel=0' 'end')
		set ntrans2big = 1
		set values = 'a(1)=1 b=2 c= d= a(5,*) nodes=0'
		breaksw
	case 3:
		echo '# Stage 3 : the loop in a nested transaction (that sets ^c first), then TCOMMIT of both levels'
		set before = ('the inner TCOMMIT went on, the outer TCOMMIT issued TRANS2BIG, and a new process' \
			'saw no ^c (this stage is a control)')
		set expect = ('inner $tlevel=1' 'outer $tlevel=1' 'end')
		set ntrans2big = 2
		set values = 'a(1)=1 b= c= d= a(5,*) nodes=0'
		breaksw
	case 4:
		echo '# Stage 4 : the same as stage 3 with TROLLBACK -1 after TRANS2BIG, then TCOMMIT of the outer level'
		set before = ('the outer TCOMMIT committed, and a new process saw ^c=3 (this stage is a control)')
		set expect = ('$tlevel=0' 'end')
		set ntrans2big = 1
		set values = 'a(1)=1 b= c=3 d= a(5,*) nodes=0'
		breaksw
	case 5:
		echo '# Stage 5 : the loop of stage 1 in a transaction, then TRESTART in Direct Mode (the restarted transaction'
		echo '#           does not run the loop), then a SET of ^d and TCOMMIT'
		set before = ('the restarted transaction committed, and a new process saw ^d=4 (this stage is a control)')
		set expect = ('$tlevel=1 $trestart=1' '$tlevel=0' 'end')
		set ntrans2big = 1
		set values = 'a(1)=1 b= c= d=4 a(5,*) nodes=0'
		breaksw
	case 6:
		echo '# Stage 6 : the same as stage 5 in a routine (restart^ydb1369), whose error trap goes to a label at the'
		echo '#           level of the TSTART that does the TRESTART'
		set before = ('the restarted transaction committed, and a new process saw ^d=4 (this stage is a control)')
		set expect = ('retry $tlevel=1 $trestart=0' '$tlevel=1 $trestart=1' '$tlevel=0' 'end')
		set ntrans2big = 1
		set values = 'a(1)=1 b= c= d=4 a(5,*) nodes=0'
		breaksw
	case 7:
		echo '# Stage 7 : in a routine (partial^ydb1369), a transaction 2 cw_set elements short of its limit, then a KILL'
		echo '#           of a subtree that spans many blocks (^a(5,*)), which issues TRANS2BIG after it changed some'
		echo '#           blocks, then TCOMMIT. ^a(4,*), ^a(5,*) and ^a(6,*) have 3000 nodes each (fill^ydb1369 sets'
		echo '#           them first). The database has a block size of 1024 and 1024 global buffers (BG)'
		set before = ('the TCOMMIT committed part of the KILL ($TLEVEL was 0), a new process saw fewer than 3000' \
			'nodes of ^a(5,*), and MUPIP INTEG reported DBMRKFREE')
		set expect = ('after the KILL $tlevel=1' 'after the TCOMMIT $tlevel=1' 'end')
		set ntrans2big = 2
		set values = 'a(1)= b= c= d= a(5,*) nodes=3000'
		breaksw
	endsw
	if (6 == $stage) then
		echo '# Command : $gtm_dist/mumps -run restart^ydb1369'
	else if (7 == $stage) then
		echo '# Commands : $gtm_dist/mumps -run fill^ydb1369, then $gtm_dist/mumps -run partial^ydb1369'
	else
		echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has these lines"
		sed 's/^/#   /' stage$stage.inp
	endif
	set prefix = "# Before the fix :"
	foreach line ($before:q)
		echo "$prefix $line"
		set prefix = "#                 "
	end
	echo "# With the fix   : expect TRANS2BIG $ntrans2big time(s), then each of these lines once :"
	echo "#                  $expect"
	echo "#                  a new process sees $values, and MUPIP INTEG reports no error"
	mkdir stage$stage
	cd stage$stage
	if (7 == $stage) then
		# A fixed block size and number of global buffers (BG only, as the cw_set limit is half the global buffers)
		# so that the transaction is a known number of cw_set elements short of the limit, and a record size that
		# allows the 900-byte values of ^e
		set save_acc_meth = "$acc_meth"
		setenv acc_meth BG
		$gtm_tst/com/dbcreate.csh mumps 1 -block_size=1024 -record_size=1000 -global_buffer_count=1024 >& dbcreate.out
		setenv acc_meth "$save_acc_meth"
	else
		$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out
	endif
	if ($status) then
		echo "FAIL : dbcreate.csh failed - see stage$stage/dbcreate.out"
	endif
	if (6 == $stage) then
		$gtm_dist/mumps -run restart^ydb1369 >& stage$stage.out
	else if (7 == $stage) then
		$gtm_dist/mumps -run fill^ydb1369 >& fill.out
		$gtm_dist/mumps -run partial^ydb1369 >& stage$stage.out
	else
		$gtm_dist/mumps -direct < ../stage$stage.inp >& stage$stage.out
	endif
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	set n = `$grep -c -- "-E-TRANS2BIG," stage$stage.out`
	if ("$ntrans2big" == "$n") then
		echo "PASS : stage$stage.out has TRANS2BIG $n time(s)"
	else
		echo "FAIL : stage$stage.out has TRANS2BIG $n time(s), but $ntrans2big were expected"
	endif
	foreach line ($expect:q)
		if (1 == `$grep -cFx -- "$line" stage$stage.out`) then
			echo "PASS : stage$stage.out has $line"
		else
			echo "FAIL : stage$stage.out does not have $line once"
		endif
	end
	$gtm_tst/com/check_error_exist.csh stage$stage.out TRANS2BIG >& /dev/null
	$gtm_dist/mumps -direct < ../values.inp >& values.out
	if (`$grep -c -F -x -- "$values" values.out`) then
		echo "PASS : a new process sees $values"
	else
		echo "FAIL : a new process does not see $values - see stage$stage/values.out"
		mv values.out values.outx
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
