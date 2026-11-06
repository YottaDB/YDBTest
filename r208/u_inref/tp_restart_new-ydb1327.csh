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
echo '# [YDB#1327] TP restart after an argumentless or exclusive NEW that follows TSTART                   #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# A TRESTART, or an implicit restart, of a transaction after an argumentless or exclusive NEW that'
echo '# follows its TSTART failed with GTMASSERT2 or a SIG-11 when the TSTART and the NEW were in the same'
echo '# XECUTE. Now the restart works as it does in a routine. In Direct Mode, which has no frame of its own'
echo '# for the symbol table of the NEW, the restart now issues TRESTNEW and TRESTLOC instead, and leaves the'
echo '# transaction as it was. And an argumentless NEW in Direct Mode after a BREAK moved the M stack'
echo '# without adjusting the pointers the transaction keeps into it, which stages 5 to 7 check.'
echo '#'
echo '# Each case of stages 1 and 2 runs in its own process. It records the local variables it sees in the'
echo '# transaction after the restart and after the transaction, compares them with the values the restart'
echo '# rules give, and prints PASS or FAIL.'
echo

cp $gtm_tst/$tst/inref/ydb1327.m .
set dm = "$tst_tcsh $gtm_tst/$tst/u_inref/ydbfuzzdm.csh ydb1327dm"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

echo '# Stage 1 : TSTART and an argumentless or exclusive NEW in the same XECUTE, then a restart'
echo '# Before the fix, each case except xn2, whose NEW is in an inner XECUTE, ended with GTMASSERT2 in tp_restart.c'
echo '# (or a SIG-11, depending on the layout of the routine), and xn2 passed'
echo '#   expect the restart to restore the local variables and undo the NEW'
foreach case (xa xi xx xn2 im)
	echo '# Command : $gtm_dist/mumps -run one^ydb1327 '"$case"
	$gtm_dist/mumps -run one^ydb1327 $case
end
echo

echo '# Stage 2 : the same restarts where the TSTART and the NEW are not in the same XECUTE'
echo '# Before the fix, the same result'
echo '#   expect the restart to restore the local variables and undo the NEW'
foreach case (ri b c d e f g h j)
	echo '# Command : $gtm_dist/mumps -run one^ydb1327 '"$case"
	$gtm_dist/mumps -run one^ydb1327 $case
end
echo

echo '# Stage 3 : TRESTART after TSTART (x) and an argumentless NEW in Direct Mode, after a BREAK'
echo '# Before the fix, GTMASSERT2 in tp_unwind.c'
echo '#   expect TRESTNEW and TRESTLOC, then the transaction to be still active until the TROLLBACK'
$dm trnewdm TRESTNEW TRESTLOC
echo

echo '# Stage 4 : the same in Direct Mode with an implicit restart, from a concurrent update'
echo '# Before the fix, GTMASSERT2 in tp_unwind.c'
echo '#   expect TRESTNEW and TRESTLOC, the transaction to be still active until the TROLLBACK, and ^b not'
echo '#   to be set'
$dm trnewdmimp TRESTNEW TRESTLOC
echo

echo '# Stage 5 : ZCONTINUE after a BREAK and a TSTART'
echo '# Before the fix, the same result'
echo '#   expect TPQUIT, as the ZCONTINUE would QUIT the frame where the transaction started'
$dm tpzcont TPQUIT
echo

echo '# Stage 6 : ZCONTINUE after a BREAK, a TSTART and two argumentless NEWs'
echo '# Before the fix, no TPQUIT, as the transaction pointed to where the M stack frame had been before the NEW'
echo '#   expect TPQUIT, as in stage 5'
$dm tpzcontnew TPQUIT
echo

echo '# Stage 7 : TRESTART after a BREAK, a TSTART and two argumentless NEWs'
echo '# Before the fix, a SIG-11, sometimes after TPQUIT (in a Debug build, after an assert failure in'
echo '# mdb_condition_handler.c)'
echo '#   expect TRESTNEW and TRESTLOC, as the restart cannot undo a NEW in Direct Mode'
$dm tptrestart TRESTNEW TRESTLOC
echo

echo '# Stage 8 : TRESTART after TSTART (x) and an exclusive NEW in Direct Mode, after a BREAK'
echo '# Before the fix, GTMASSERT2 in tp_unwind.c'
echo '#   expect TRESTNEW and TRESTLOC, as in stage 3'
$dm trexdm TRESTNEW TRESTLOC
echo

echo '# Stage 9 : as stage 3, with the TRESTART in a routine whose $ETRAP handles the error'
echo '# Before the fix, GTMASSERT2 in tp_unwind.c'
echo '#   expect the handler to get TRESTNEW with the transaction still active, and its TROLLBACK to end it'
$dm trnewhdl
echo

echo '# Stage 10 : as stage 3, with the TSTART, NEW and TRESTART in a ZBREAK action'
echo '# Before the fix, GTMASSERT2 in tp_unwind.c'
echo '#   expect TRESTNEW and TRESTLOC, reported as the error of the ZBREAK action, with the transaction still active'
$dm zbrdm ERRWZBRK TRESTNEW TRESTLOC
echo

echo '# Stage 11 : as stage 10, in a ZSTEP action'
echo '# Before the fix, GTMASSERT2 in tp_unwind.c'
echo '#   expect TRESTNEW and TRESTLOC, reported as the error of the ZSTEP action, with the transaction still active'
$dm zstdm ERRWEXC TRESTNEW TRESTLOC
echo

echo '# Stage 12 : as stage 3, without the BREAK, so the TSTART and the NEW are on the same frame'
echo '# Before the fix, the same result'
echo '#   expect the TRESTART to undo the NEW and go back to the prompt, with x restored'
$dm nobrkdm
echo

echo '# Stage 13 : TSTART (x), an argumentless NEW and TRESTART in a $ZTIMEOUT action, which runs as indirect code'
echo '# Before the fix, a SIG-11'
echo '#   expect the transaction to restart once in the action, with x restored'
$dm ztodm
echo

echo '# Stage 14 : as stage 13, in $ZINTERRUPT'
echo '# Before the fix, a SIG-11'
echo '#   expect the transaction to restart once in the action, with x restored'
$dm zindm
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
