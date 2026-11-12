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
echo "#-----------------------------------------------------------------------------------------------#"
echo "# [YDB#1357] A ZCONTINUE that would QUIT the frame of an active transaction started in Direct   #"
echo "# Mode issues TPQUIT once and leaves the transaction active                                     #"
echo "#-----------------------------------------------------------------------------------------------#"
echo
echo '# A TSTART in Direct Mode makes the frame under the Direct Mode frame the frame of the transaction.'
echo '# After a BREAK typed in Direct Mode, or a BREAK in $ZTRAP code or in a ZBREAK, ZSTEP or device'
echo '# EXCEPTION action, that frame is not a counted frame, and ZCONTINUE resumes that frame, which then'
echo '# QUITs with the transaction active and gets TPQUIT. Before the fix, the error handling after that'
echo '# TPQUIT rolled back the transaction (stages 1 to 3, and stage 8, which also left Direct Mode in'
echo '# $ZTRAP code), or left Direct Mode in $ZTRAP code with $ECODE set and the transaction active'
echo '# (stages 6 and 7, and stages 1 to 3 in YottaDB r2.06 and earlier, which issued TPQUIT twice). With'
echo '# the fix, the ZCONTINUE issues TPQUIT before the ZCONTINUE unwinds anything, so the transaction'
echo '# stays active and Direct Mode stays at the same level. After a TCOMMIT or TROLLBACK, ZCONTINUE'
echo '# works.'
echo '#'
echo '# Without the fix, stages 1 to 3 and 6 to 8 print FAIL, and stages 4 and 5 PASS.'
echo

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif
set dm = "$tst_tcsh $gtm_tst/$tst/u_inref/ydbfuzzdm.csh ydb1357dm"

echo '# Stage 1 : ZCONTINUE after a BREAK in Direct Mode and a TSTART, then TCOMMIT and ZCONTINUE'
echo '# Before the fix : TPQUIT, and the transaction was rolled back, so the next line ran with $TLEVEL 0'
echo '#                  and the TCOMMIT issued TLVLZERO'
echo '# With the fix   : expect TPQUIT once, the next line to run with $TLEVEL 1, and the ZCONTINUE after'
echo '#                  the TCOMMIT to work'
$dm -count zcont TPQUIT
echo

echo '# Stage 2 : the same with code after the BREAK on the line, and TROLLBACK in place of TCOMMIT'
echo '# Before the fix : the rest of the BREAK line ran with $TLEVEL 1, then TPQUIT and the roll back, so'
echo '#                  the TROLLBACK issued TLVLZERO'
echo '# With the fix   : expect TPQUIT once, the next line to run with $TLEVEL 1, and the rest of the BREAK'
echo '#                  line to run with $TLEVEL 0 after the TROLLBACK and the second ZCONTINUE'
$dm -count zcontline TPQUIT
echo

echo '# Stage 3 : ZCONTINUE after the BREAK that $ZTRAP gives for an error in a routine, and a TSTART'
echo '# Before the fix : TPQUIT, and the next line ran with $TLEVEL 0'
echo '# With the fix   : expect DIVZERO, TPQUIT once, and the next line to run with $TLEVEL 1'
$dm -count ztrap DIVZERO TPQUIT
echo

echo '# Stage 4 : control, ZCONTINUE after a BREAK in a routine and a TSTART'
echo '# Before the fix : the routine resumed in the transaction and committed the transaction, with no'
echo '#                  TPQUIT (this stage is a control)'
echo '# With the fix   : expect the routine to resume in the transaction and commit the transaction, with'
echo '#                  no TPQUIT'
$dm rtn
echo

echo '# Stage 5 : control, TSTART and TCOMMIT at the prompt of a BREAK in Direct Mode, then ZCONTINUE'
echo '# Before the fix : no TPQUIT, and the next line ran with $TLEVEL 0 (this stage is a control)'
echo '# With the fix   : expect no TPQUIT, and the next line to run with $TLEVEL 0'
$dm prompt
echo

echo '# Stage 6 : ZCONTINUE after the BREAK of a ZBREAK action and a TSTART, then TROLLBACK and ZCONTINUE'
echo '# Before the fix : ERRWZBRK with TPQUIT, and Direct Mode was left in $ZTRAP code with $ECODE set'
echo '#                  (the transaction stayed active)'
echo '# With the fix   : expect TPQUIT once, the next line to run with $TLEVEL 1 and an empty $ECODE, no'
echo '#                  $ZTRAP frame, and the routine to finish after the TROLLBACK and the ZCONTINUE'
$dm -count zbrk TPQUIT
echo

echo '# Stage 7 : the same after the BREAK of a ZSTEP action'
echo '# Before the fix : ERRWEXC with TPQUIT, and Direct Mode was left in $ZTRAP code with $ECODE set (the'
echo '#                  transaction stayed active)'
echo '# With the fix   : expect TPQUIT once, the next line to run with $TLEVEL 1 and an empty $ECODE, no'
echo '#                  $ZTRAP frame, and the routine to finish after the TROLLBACK and the ZCONTINUE'
$dm -count zstp TPQUIT
echo

echo '# Stage 8 : ZCONTINUE after the BREAK of a device EXCEPTION action (for a READ past the end of a'
echo '#           file) and a TSTART'
echo '# Before the fix : ERRWIOEXC with TPQUIT, the transaction was rolled back, and Direct Mode was left in'
echo '#                  $ZTRAP code'
echo '# With the fix   : expect TPQUIT once, the next line to run with $TLEVEL 1, and no $ZTRAP frame'
$dm -count exc TPQUIT
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif

echo "# Done"
