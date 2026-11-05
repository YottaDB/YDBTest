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
echo '# [YDB#1373] A FOR with a subscripted control variable leaves no node without a value                #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage runs the FOR shown in Direct Mode in a new process, then writes $DATA(a) and'
echo '# $ORDER(a("")), and checks that the output has no error and has the line expected.'
echo

set check = 'write "$data(a)=",$data(a)," $order(a(""""))=",$order(a("")),!'
echo 'for a(1)=1 new' > stage1.inp
echo "$check" >> stage1.inp
echo 'for a(1)=1 new' > stage2.inp
echo 'kill (x)' >> stage2.inp
echo "$check" >> stage2.inp
echo 'for a(1)=1,2 new' > stage3.inp
echo "$check" >> stage3.inp
echo 'kill a for a(1)=1 kill a' > stage4.inp
echo "$check" >> stage4.inp
echo 'kill a for a(1)=1 kill a(1)' > stage5.inp
echo "$check" >> stage5.inp
echo 'set y="a(1)" for @y=1 new' > stage6.inp
echo "$check" >> stage6.inp
echo 'kill a for a(1)=1:1:3 set b=a(1)' > stage7.inp
echo "$check" >> stage7.inp
echo 'kill a for a(1)=1 set b=a(1)' > stage8.inp
echo "$check" >> stage8.inp
foreach stage (1 2 3 4 5 6 7 8)
	switch ($stage)
	case 1:
		echo '# Stage 1 : a FOR whose scope has an argumentless NEW'
		set before = ('the FOR left the node a(1) without a value: $data(a)=10 $order(a(""))=1')
		set expect = '$data(a)=0 $order(a(""))='
		breaksw
	case 2:
		echo '# Stage 2 : the same as stage 1, then an exclusive KILL (from fuzz testing)'
		set before = ('a Debug build failed an assert in op_putindx.c at the KILL. A Release build left' \
			'the node a(1) without a value: $data(a)=10 $order(a(""))=1')
		set expect = '$data(a)=0 $order(a(""))='
		breaksw
	case 3:
		echo '# Stage 3 : the same as stage 1 with two values'
		set before = ('the FOR left the node a(1) without a value: $data(a)=10 $order(a(""))=1')
		set expect = '$data(a)=0 $order(a(""))='
		breaksw
	case 4:
		echo '# Stage 4 : a FOR whose scope kills the variable of the control variable'
		set before = ('the FOR left the node a(1) without a value: $data(a)=10 $order(a(""))=1')
		set expect = '$data(a)=0 $order(a(""))='
		breaksw
	case 5:
		echo '# Stage 5 : a FOR whose scope kills the control variable'
		set before = ('the FOR left the node a(1) without a value: $data(a)=10 $order(a(""))=1')
		set expect = '$data(a)=0 $order(a(""))='
		breaksw
	case 6:
		echo '# Stage 6 : the same as stage 1 with an indirect control variable'
		set before = ('the FOR left the node a(1) without a value: $data(a)=10 $order(a(""))=1')
		set expect = '$data(a)=0 $order(a(""))='
		breaksw
	case 7:
		echo '# Stage 7 : a FOR with a subscripted control variable and an increment (no NEW or KILL)'
		set before = ('$data(a)=10 $order(a(""))=1 (this stage is a control)')
		set expect = '$data(a)=10 $order(a(""))=1'
		breaksw
	case 8:
		echo '# Stage 8 : a FOR with a subscripted control variable and one value (no NEW or KILL)'
		set before = ('$data(a)=10 $order(a(""))=1 (this stage is a control)')
		set expect = '$data(a)=10 $order(a(""))=1'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has these lines"
	sed 's/^/#   /' stage$stage.inp
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	echo "# With the fix   : expect $expect"
	$gtm_dist/mumps -direct < stage$stage.inp >& stage$stage.out
	if (`$grep -c -- "-[EF]-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has an error"
	else
		echo "PASS : no error in stage$stage.out"
	endif
	if (1 == `$grep -c -F -x -- "$expect" stage$stage.out`) then
		echo "PASS : stage$stage.out has $expect"
	else
		echo "FAIL : stage$stage.out does not have $expect once"
	endif
	echo
end
echo "# Done"
