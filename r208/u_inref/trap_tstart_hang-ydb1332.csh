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
echo '# [YDB#1332] $ETRAP or $ZTRAP code that does a TSTART and ends without TCOMMIT or TROLLBACK          #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# When error trap code started a transaction and ended without a TCOMMIT or TROLLBACK, the QUIT out of'
echo '# its frame issued TPQUIT, which ran the same error trap code again, and the process looped forever.'
echo '# Now the TPQUIT is reported with ERRWZTRAP or ERRWETRAP, as for any other error in error trap code.'
echo '#'
echo '# Each stage runs its case in a new process, with a timeout so that a case that hangs fails instead.'
echo
cp $gtm_tst/$tst/inref/ydb1332.m .
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

echo '# Stage 1 : $ZTRAP or $ETRAP code that does a TSTART and ends without TCOMMIT or TROLLBACK'
echo '# Before the fix : the process looped in the error trap code until it was stopped'
echo '# With the fix   : expect the process to end by itself with ERRWZTRAP or ERRWETRAP and TPQUIT'
foreach case (a b c)
	if ("a" == $case) then
		set err = ERRWZTRAP
	else
		set err = ERRWETRAP
	endif
	echo '# Command : $gtm_dist/mumps -run ydb1332 '"$case"' < /dev/null'
	timeout -k 10 60 $gtm_dist/mumps -run ydb1332 $case < /dev/null >& $case.out
	set stat = $status
	if ((124 == $stat) || (137 == $stat)) then
		echo "WRONG : case $case did not end within 60 seconds"
	else
		echo "PASS : case $case ended by itself"
	endif
	if ({ $grep -q "E-$err.*E-TPQUIT" $case.out }) then
		echo "PASS : case $case issued $err with TPQUIT"
	else
		echo "WRONG : case $case did not issue $err with TPQUIT. See $case.out"
	endif
	$gtm_tst/com/check_error_exist.csh $case.out $err
end
echo

echo '# Stage 2 : TSTART outside error trap code, and error trap code that ends its own transaction'
echo '# Before the fix : each case produced the line shown (these cases are controls)'
echo '# With the fix   : expect each case to produce the line shown'
foreach case (d e f g h i)
	switch ($case)
	case d:
	case e:
		set exp = 'after d1 $tlevel=0'
		set err = TPQUIT
		breaksw
	case f:
		set exp = 'after f1 $tlevel=0'
		set err = DIVZERO
		breaksw
	case g:
		set exp = 'outer etrap $tlevel=0'
		set err = ""
		breaksw
	case h:
		set exp = 'after b1 $tlevel=0 ^h=1'
		set err = ""
		breaksw
	case i:
		set exp = 'after tcommit ^i=1'
		set err = ""
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run ydb1332 '"$case"' < /dev/null'
	timeout -k 10 60 $gtm_dist/mumps -run ydb1332 $case < /dev/null >& $case.out
	if ({ $grep -qF "$exp" $case.out }) then
		echo "PASS : case $case output has $exp"
	else
		echo "WRONG : case $case output does not have $exp. See $case.out"
	endif
	if ("" != "$err") $gtm_tst/com/check_error_exist.csh $case.out $err
end
echo

echo '# Stage 3 : in Direct Mode, an error in a routine, then TSTART and ZCONTINUE at the BREAK it gives'
echo '# Before the fix : the process looped in the error trap code until it was stopped'
echo '# With the fix   : expect DIVZERO, then TPQUIT for the ZCONTINUE, and the next line to run with'
echo '#                  $TLEVEL 0'
set dm = "$tst_tcsh $gtm_tst/$tst/u_inref/ydbfuzzdm.csh ydb1332dm"
$dm trapdm DIVZERO TPQUIT
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
