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

echo "#----------------------------------------------------------------------------------------------#"
echo "# [YDB#1383] [YDB#1302] A TP restart or a ZGOTO that abandons a LOCK command makes the next    #"
echo "# lock command issue BADLOCKNEST, and a LOCK that resumes after a transaction or an error in an #"
echo "# extrinsic that a lock name calls terminates with a SIG-11 or does not acquire every name      #"
echo "#----------------------------------------------------------------------------------------------#"
echo
echo '# While a LOCK is processed, lks_this_cmd counts its names and the trans flag of each name is set.'
echo '# A TP restart from inside the LOCK resumes at the outermost TSTART, so the LOCK never completes, but'
echo '# the restart left lks_this_cmd and the flags set. The next lock command that starts with op_lkinit()'
echo '# (LOCK +, LOCK -, ZALLOCATE, ZDEALLOCATE, and the simpleAPI ydb_lock_incr_s() and ydb_lock_decr_s())'
echo '# then issued BADLOCKNEST. A ZGOTO out of an extrinsic that a lock name calls abandons the LOCK the same'
echo '# way. And a LOCK whose lock name calls an extrinsic resumes when the extrinsic returns: a transaction'
echo '# in the extrinsic deleted the list entries of the names that the LOCK had not yet acquired, which'
echo '# terminated the process with a SIG-11 when the LOCK resumed, and an error that the $ETRAP of the'
echo '# extrinsic handles cleared those names (YDB#1302), so the LOCK did not acquire them.'
echo '#'
echo '# Each stage runs in a new process, with ^x in region DEFAULT and ^a in region AREG. The transaction'
echo '# restarts with TRESTART until the final retry, where the process holds crit on DEFAULT. There, a'
echo '# LOCK of ^x and ^a has to open region AREG, and opening a region while holding crit restarts the'
echo '# transaction. Each stage checks the transaction restarted this way, then runs its command as the'
echo '# first lock command of the restarted try, and checks the locks the process holds after TCOMMIT.'
echo

$gtm_tst/com/dbcreate.csh mumps 2 >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif
cp $gtm_tst/$tst/inref/ydb1383.m .

echo '# Stage 1 : LOCK +(^x,^a) after the restart'
echo "# Command : "'$gtm_dist/mumps -run lockcmd^ydb1383 '"'lock +(^x,^a)|^a=1,^x=1|'"
echo '# Before the fix : BADLOCKNEST from LOCK +(^x,^a)'
echo '# With the fix   : expect no error, and the process to hold ^a and ^x at level 1'
$gtm_dist/mumps -run lockcmd^ydb1383 'lock +(^x,^a)|^a=1,^x=1|'
echo

echo '# Stage 2 : LOCK +^x before TSTART, then LOCK +^x after the restart. The interrupted LOCK named ^x,'
echo '#           so it set the trans flag of ^x, which was already locked.'
echo "# Command : "'$gtm_dist/mumps -run lockcmd^ydb1383 '"'lock +^x|^x=2|lock +^x'"
echo '# Before the fix : BADLOCKNEST from LOCK +^x'
echo '# With the fix   : expect no error, and the process to hold ^x at level 2. If the restart reset'
echo '#                  lks_this_cmd but left the trans flag of ^x set, LOCK +^x would not count ^x, and'
echo '#                  ^x would stay at level 1.'
$gtm_dist/mumps -run lockcmd^ydb1383 'lock +^x|^x=2|lock +^x'
echo

echo '# Stage 3 : LOCK -^x after the restart, with no lock held'
echo "# Command : "'$gtm_dist/mumps -run lockcmd^ydb1383 '"'lock -^x||'"
echo '# Before the fix : BADLOCKNEST from LOCK -^x'
echo '# With the fix   : expect no error, and the process to hold no locks'
$gtm_dist/mumps -run lockcmd^ydb1383 'lock -^x||'
echo

echo '# Stage 4 : ZALLOCATE ^x after the restart'
echo "# Command : "'$gtm_dist/mumps -run lockcmd^ydb1383 '"'zallocate ^x|^x=ZAL|'"
echo '# Before the fix : BADLOCKNEST from ZALLOCATE ^x'
echo '# With the fix   : expect no error, and the process to hold ^x with ZALLOCATE'
$gtm_dist/mumps -run lockcmd^ydb1383 'zallocate ^x|^x=ZAL|'
echo

echo '# Stage 5 : ZDEALLOCATE ^x after the restart, with no lock held'
echo "# Command : "'$gtm_dist/mumps -run lockcmd^ydb1383 '"'zdeallocate ^x||'"
echo '# Before the fix : BADLOCKNEST from ZDEALLOCATE ^x'
echo '# With the fix   : expect no error, and the process to hold no locks'
$gtm_dist/mumps -run lockcmd^ydb1383 'zdeallocate ^x||'
echo

echo '# Stage 6 : LOCK (^x,^a) after the restart (this stage is a control). A LOCK without + or -'
echo '#           first releases all locks, which resets lks_this_cmd, so it is not affected.'
echo "# Command : "'$gtm_dist/mumps -run lockcmd^ydb1383 '"'lock (^x,^a)|^a=1,^x=1|'"
echo '# Before the fix : no error, and the process held ^a and ^x at level 1'
echo '# With the fix   : expect no error, and the process to hold ^a and ^x at level 1'
$gtm_dist/mumps -run lockcmd^ydb1383 'lock (^x,^a)|^a=1,^x=1|'
echo

echo '# Stages 7 and 8 use the simpleAPI. The final retry of ydb_tp_s() calls ydb_lock_s(^x, ^a), which'
echo '# restarts the transaction the same way.'
set file = ydb1383_sapi
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map
echo

echo '# Stage 7 : ydb_lock_incr_s(^a) after the restart'
echo '# Command : ./ydb1383_sapi incr'
echo '# Before the fix : ydb_lock_incr_s(^a) returned YDB_ERR_BADLOCKNEST, and ^a was free'
echo '# With the fix   : expect YDB_OK, and another process to find ^a held'
./$file incr
echo

echo '# Stage 8 : ydb_lock_decr_s(^a) after the restart, with no lock held'
echo '# Command : ./ydb1383_sapi decr'
echo '# Before the fix : ydb_lock_decr_s(^a) returned YDB_ERR_BADLOCKNEST'
echo '# With the fix   : expect YDB_OK, and another process to find ^a free'
./$file decr
echo

echo '# Stages 9 to 17 : a LOCK whose lock name calls an extrinsic. The LOCK is in progress while the extrinsic'
echo '# runs, and resumes when the extrinsic returns, unless execution goes on in the frame of the LOCK or an'
echo '# older frame (after a ZGOTO, a TP restart or an error), which abandons the LOCK.'
echo

echo '# Stage 9 : ZGOTO out of the extrinsic of LOCK +(a,b($$zgf)), to the frame of the caller, then LOCK +a'
echo '# Command : $gtm_dist/mumps -run zg^ydb1383'
echo '# Before the fix : BADLOCKNEST from LOCK +a'
echo '# With the fix   : expect no error, and the process to hold a at level 1'
$gtm_dist/mumps -run zg^ydb1383
echo

echo '# Stage 10 : the same from Direct Mode, after a BREAK in the extrinsic, with ZGOTO 1 and LOCK +c'
echo '# Before the fix : BADLOCKNEST from LOCK +c'
echo '# With the fix   : expect no error, and the process to hold c at level 1'
$tst_tcsh $gtm_tst/$tst/u_inref/ydbfuzzdm.csh ydb1383dm dmzg
echo

foreach stage (11 12 13 14 15 16 17)
	switch ($stage)
	case 11:
		set case = tpc
		echo '# Stage 11 : TSTART and TCOMMIT in the extrinsic of LOCK +(a,b($$tpcf)), which returns 1'
		echo '# Before the fix : the LOCK resumed and terminated the process with a SIG-11, as the TCOMMIT had deleted'
		echo '#                  the list entry of a, which the LOCK had not yet acquired'
		echo '# With the fix   : expect the LOCK to resume, and the process to hold a and b(1)'
		breaksw
	case 12:
		set case = tpr
		echo '# Stage 12 : TSTART and TRESTART in the extrinsic of LOCK +(a,b($$tprf)). The restart resumes at the'
		echo '#            TSTART in the extrinsic, so the LOCK resumes.'
		echo '# Before the fix : the LOCK resumed and terminated the process with a SIG-11'
		echo '# With the fix   : expect the LOCK to resume, and the process to hold a and b(1)'
		breaksw
	case 13:
		set case = tpb
		echo '# Stage 13 : TSTART and TROLLBACK in the extrinsic of LOCK +(a,b($$tpbf))'
		echo '# Before the fix : the LOCK resumed and terminated the process with a SIG-11'
		echo '# With the fix   : expect the LOCK to resume, and the process to hold a and b(1)'
		breaksw
	case 14:
		set case = eh
		echo '# Stage 14 : an error in the extrinsic of LOCK +(a,b($$ehf)), handled by the $ETRAP of the extrinsic,'
		echo '#            which returns 2. The LOCK resumes.'
		echo '# Before the fix : the LOCK completed holding only b(2), and another process got a'
		echo '# With the fix   : expect the process to hold a and b(2)'
		breaksw
	case 15:
		set case = zgin
		echo '# Stage 15 : a ZGOTO that stays in the frames of the extrinsic of LOCK +(a,b($$zginf)), which returns 3'
		echo '#            (this stage is a control)'
		echo '# Before the fix : the LOCK resumed, and the process held a and b(3)'
		echo '# With the fix   : expect the same'
		breaksw
	case 16:
		set case = eu
		echo '# Stage 16 : an error in the extrinsic of LOCK +(a,b($$euf)) that reaches the frame of the LOCK, whose'
		echo '#            $ETRAP goes on after the LOCK, then LOCK +a (this stage is a control)'
		echo '# Before the fix : no error from LOCK +a, and the process held a at level 1'
		echo '# With the fix   : expect the same'
		breaksw
	case 17:
		set case = nest
		echo '# Stage 17 : a LOCK +c in the extrinsic of LOCK +(a,b($$nestf)), then LOCK +a (this stage is a control)'
		echo '# Before the fix : BADLOCKNEST from LOCK +c, no error from LOCK +a, and the process held a at level 1'
		echo '# With the fix   : expect the same'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run '"$case"'^ydb1383'
	$gtm_dist/mumps -run ${case}^ydb1383 >& $case.out
	$grep -q -- "-F-KILLBYSIG" $case.out
	if (! $status) then
		echo "FAIL : ${case}^ydb1383 terminated with a signal"
		$gtm_tst/com/check_error_exist.csh $case.out KILLBYSIG >& $case.errors.logx
		rm -f core*
	else
		cat $case.out
	endif
	echo
end

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif

echo "# Done"
