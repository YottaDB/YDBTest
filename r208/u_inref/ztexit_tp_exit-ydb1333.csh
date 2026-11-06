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
echo '# [YDB#1333] A process exits cleanly when $ZTEXIT is true and a transaction is active               #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# The exit handling rolls back an active transaction. With $ZTEXIT true, that TROLLBACK issued an'
echo '# error so that a deferred $ZINTERRUPT could run, which aborted the rest of the exit handling.'
echo

cp $gtm_tst/$tst/inref/ydb1333.m .
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

echo '# Stage 1 : SET $ZTEXIT=1, TSTART (), HALT'
echo '# Before the fix : LKRUNDOWN and exit status 242'
echo '# With the fix   : expect the process to exit with status 0 and no output'
echo '# Command : $gtm_dist/mumps -run ztexithalt^ydb1333'
$gtm_dist/mumps -run ztexithalt^ydb1333 >& ztexithalt.out
set stat = $status
if ((0 == $stat) && (-z ztexithalt.out)) then
	echo "PASS : exit status 0 and no output"
else
	echo "FAIL : exit status $stat, output follows"
	cat ztexithalt.out
endif
echo

echo '# Stage 2 : LOCK ^ydb1333, SET $ZTEXIT=1, TSTART (), HALT, while another process has the database'
echo '#           open'
echo '# Before the fix : LKRUNDOWN and exit status 242, and the LOCK stayed in the lock space, owned by the'
echo '#                  exited process'
echo '# With the fix   : expect the process to exit with status 0 and no output, and no LOCK left in the'
echo '#                  lock space'
# Without another process attached, the database rundown of the exiting process removes the lock space, which
# would hide a LOCK left behind
($gtm_dist/mumps -run attach^ydb1333 >& attach.out &)
set attachpid = `$gtm_dist/mumps -run waitattach^ydb1333`
echo '# Command : $gtm_dist/mumps -run ztexitlock^ydb1333'
$gtm_dist/mumps -run ztexitlock^ydb1333 >& ztexitlock.out
set stat = $status
if ((0 == $stat) && (-z ztexitlock.out)) then
	echo "PASS : exit status 0 and no output"
else
	echo "FAIL : exit status $stat, output follows"
	cat ztexitlock.out
endif
echo '# Command : $gtm_dist/lke show -all, which reports a LOCK of an exited process without removing it'
$gtm_dist/lke show -all >& lke_show.outx
if ({ $grep -q "Owned by" lke_show.outx }) then
	echo "FAIL : a LOCK is left in the lock space. See lke_show.outx"
else
	echo "PASS : no LOCK is left in the lock space"
endif
$gtm_dist/mumps -run %XCMD 'set ^ydb1333done=1'
$gtm_tst/com/wait_for_proc_to_die.csh $attachpid 300
echo

echo '# Stage 3 : SET $ZTEXIT=1, TSTART (), TROLLBACK, without exiting'
echo '# Before the fix : $ZINTERRUPT ran after the TROLLBACK (this stage is a control)'
echo '# With the fix   : expect $ZINTERRUPT to run after the TROLLBACK, and $TLEVEL 0'
echo '# Command : $gtm_dist/mumps -run ztexitrollback^ydb1333'
$gtm_dist/mumps -run ztexitrollback^ydb1333
echo

echo '# Stage 4 : SET $ZTEXIT=1, TSTART (), SET, TCOMMIT, without exiting'
echo '# Before the fix : $ZINTERRUPT ran after the TCOMMIT (this stage is a control)'
echo '# With the fix   : expect $ZINTERRUPT to run after the TCOMMIT, $TLEVEL 0, and the SET committed'
echo '# Command : $gtm_dist/mumps -run ztexitcommit^ydb1333'
$gtm_dist/mumps -run ztexitcommit^ydb1333
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
