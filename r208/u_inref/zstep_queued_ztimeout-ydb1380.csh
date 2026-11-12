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
echo '# [YDB#1380] A $ZTIMEOUT that expires before a ZSTEP runs after the ZSTEP action, and a FOR     #'
echo '# loop after the ZSTEP does not fail an assert                                                  #'
echo "#-----------------------------------------------------------------------------------------------#"
echo
echo '# ZSTEP queues the events that are pending, to run after the ZSTEP action, but left the event that'
echo '# outofband names (a $ZTIMEOUT, the job interrupt of a MUPIP INTRPT, or a TP timeout) in outofband'
echo '# and in the transfer table entries of FOR loops. An event in the queue is replayed only when'
echo '# outofband is no_event, so the event never ran. A FOR loop after the ZSTEP recognized the queued'
echo '# event. For a $ZTIMEOUT, a Debug build failed an assert in ztimeout_routines.c, and a Release build'
echo '# ran the $ZTIMEOUT vector before the ZSTEP action. For a job interrupt, $ZINTERRUPT ran before the'
echo '# ZSTEP action in both builds. For a TP timeout, a Debug build failed an assert in tp_timeout.c, and'
echo '# a Release build issued TPTIMEOUT before the ZSTEP action. With the fix, ZSTEP also takes such an'
echo '# event out of outofband and the transfer table, so the event runs after the ZSTEP action.'
echo '#'
echo '# Each case records what runs, in order: S@<place> for a ZSTEP action, Z@<place> for the $ZTIMEOUT'
echo '# vector, J@<place> for $ZINTERRUPT, E@<place>=<mnemonic> for an error and L<n> for line <n> of the'
echo '# case (see r208/inref/ydb1380.m). After an event, the ZSTEP is reinstated, so a ZSTEP action'
echo '# follows the line of the event.'
echo '#'
echo '# Without the fix, stages 1, 2 and 5 to 10 print FAIL, stage 4 prints FAIL in a Debug build (where'
echo '# stages 2, 4 and 10 fail an assert), and stage 3 PASSes.'
echo

cp $gtm_tst/$tst/inref/ydb1380.m .

echo '# Stage 1 : a $ZTIMEOUT that expires at once, then ZSTEP INTO, and no FOR loop'
echo '# Before the fix : the $ZTIMEOUT vector never ran'
echo '# With the fix   : expect the $ZTIMEOUT vector to run once, at the line start after the ZSTEP action'
echo '# Command : $gtm_dist/mumps -run nofor^ydb1380'
$gtm_dist/mumps -run nofor^ydb1380
echo

echo '# Stage 2 : the same with a FOR loop on the line of the ZSTEP'
echo '# Before the fix : assert failure in ztimeout_routines.c (Debug), the vector ran before the ZSTEP'
echo '#                  action (Release)'
echo '# With the fix   : expect the $ZTIMEOUT vector to run once, at the line start after the ZSTEP action'
echo '# Command : $gtm_dist/mumps -run for^ydb1380'
$gtm_dist/mumps -run for^ydb1380 >& for.out
$grep -q -- "-F-ASSERT" for.out
if (! $status) then
	echo "FAIL : for^ydb1380 failed an assert"
	$gtm_tst/com/check_error_exist.csh for.out ASSERT >& for.errors.logx
	rm -f core*
else
	cat for.out
endif
echo

echo '# Stage 3 : control, the same as stage 1 without the ZSTEP'
echo '# Before the fix : the $ZTIMEOUT vector ran at once (this stage is a control)'
echo '# With the fix   : expect the $ZTIMEOUT vector to run at once'
echo '# Command : $gtm_dist/mumps -run nozstep^ydb1380'
$gtm_dist/mumps -run nozstep^ydb1380
echo

set dm = "$tst_tcsh $gtm_tst/$tst/u_inref/ydbfuzzdm.csh ydb1380dm"
echo '# Stage 4 : in Direct Mode, a $ZTIMEOUT that expires at once, then ZSTEP and a FOR loop'
echo '# Before the fix : assert failure in ztimeout_routines.c (Debug), ZTIMEOUT (Release)'
echo '# With the fix   : expect ZTIMEOUT, then the next line to run'
$dm dmfor ZTIMEOUT
echo

echo '# Stage 5 : in Direct Mode, a $ZTIMEOUT with a vector that expires at once, then ZSTEP and a DO of a'
echo '#           routine'
echo '# Before the fix : the $ZTIMEOUT vector never ran'
echo '# With the fix   : expect the $ZTIMEOUT vector to run when the routine starts'
$dm dmrtn
echo

echo '# Stage 6 : the case of stage 1, then a later $ZTIMEOUT and a job interrupt'
echo '# Before the fix : the first $ZTIMEOUT vector never ran, and the later vector and $ZINTERRUPT ran once'
echo '# With the fix   : expect each $ZTIMEOUT vector and $ZINTERRUPT to run once'
echo '# Command : $gtm_dist/mumps -run later^ydb1380'
$gtm_dist/mumps -run later^ydb1380
echo

echo '# Stage 7 : a MUPIP INTRPT of the process (through ZSYSTEM), then ZSTEP INTO, and no FOR loop'
echo '# Before the fix : $ZINTERRUPT never ran'
echo '# With the fix   : expect $ZINTERRUPT to run once, at the line start after the ZSTEP action'
echo '# Command : $gtm_dist/mumps -run jinofor^ydb1380'
$gtm_dist/mumps -run jinofor^ydb1380
echo

echo '# Stage 8 : the same with a FOR loop on the line of the ZSTEP'
echo '# Before the fix : $ZINTERRUPT ran in the FOR loop, before the ZSTEP action'
echo '# With the fix   : expect $ZINTERRUPT to run once, at the line start after the ZSTEP action'
echo '# Command : $gtm_dist/mumps -run jifor^ydb1380'
$gtm_dist/mumps -run jifor^ydb1380
echo

echo '# Stage 9 : a TP timeout ($ZMAXTPTIME) that expires during a ZSYSTEM in a transaction, then ZSTEP INTO,'
echo '#           and no FOR loop'
echo '# Before the fix : TPTIMEOUT was never issued, and the transaction went on'
echo '# With the fix   : expect TPTIMEOUT once, at the line start after the ZSTEP action'
echo '# Command : $gtm_dist/mumps -run tpnofor^ydb1380'
$gtm_dist/mumps -run tpnofor^ydb1380
echo

echo '# Stage 10 : the same with a FOR loop on the line of the ZSTEP'
echo '# Before the fix : assert failure in tp_timeout.c (Debug), TPTIMEOUT in the FOR loop, before the ZSTEP'
echo '#                  action (Release)'
echo '# With the fix   : expect TPTIMEOUT once, at the line start after the ZSTEP action'
echo '# Command : $gtm_dist/mumps -run tpfor^ydb1380'
$gtm_dist/mumps -run tpfor^ydb1380 >& tpfor.out
$grep -q -- "-F-ASSERT" tpfor.out
if (! $status) then
	echo "FAIL : tpfor^ydb1380 failed an assert"
	$gtm_tst/com/check_error_exist.csh tpfor.out ASSERT >& tpfor.errors.logx
	rm -f core*
else
	cat tpfor.out
endif
echo

echo "# Done"
