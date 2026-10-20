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
echo "# [#1312] MUPIP REPLICATE -SOURCE -SHUTDOWN keeps the ids of a receive pool it does not remove  #"
echo "#-----------------------------------------------------------------------------------------------#"
echo

# When the receiver server and update process die without removing the receive pool, and MUPIP REPLICATE -SOURCE
# -SHUTDOWN then removes the journal pool, it leaves the receive pool in place (it logs "Receive pool shared memory
# not removed"). It used to reset the receive pool ids in the instance file header anyway, which left nothing able
# to find that receive pool: MUPIP RUNDOWN -REGION "*" did not remove it, and a later receiver server created a new
# one beside it. Each stage below kills the receiver server and update process with SIGKILL to leave such a pool.
#
# The receive pool ids are read with MUPIP REPLICATE -EDITINSTANCE -SHOW, which lists the semaphore id first.
#
# Stage 2 checks that the ids are kept and that MUPIP RUNDOWN -REGION "*" removes the pool. Stage 3 checks that a
# restarted receiver server attaches to the pool instead. Stage 4 checks that ids which no longer name an existing
# receive pool (here because it was removed with ipcrm) are still reset, since a receiver server cannot start with
# them. Stages 5a and 5b check that when only the semaphore of such a pool was removed (with ipcrm), so that its shared
# memory still exists, both ids are kept, a receiver server does not start (REPLREQROLLBACK), and MUPIP JOURNAL
# -ROLLBACK (5a), as that message asks, or MUPIP RUNDOWN -REGION "*" (5b) removes the shared memory, after which the
# servers start again.
# Stage 6 checks the reverse: when only the shared memory was removed (with ipcrm), the semaphore id is kept and the
# shared memory id cleared, and a receiver server then starts with that semaphore and a new shared memory. Any pool a
# stage leaves behind is removed with ipcrm at the end of that stage, so that a run on a build without the fix does
# not leave it on the system.

setenv gtm_test_spanreg 0
setenv gtm_test_jnl NON_SETJNL
unsetenv gtm_db_counter_sem_incr	# the instance file is created without -qdbrundown
setenv gtm_repl_instance mumps.repl

# Stage 5a runs MUPIP JOURNAL -ROLLBACK, which needs before-image journaling and so the BG access method
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out
source $gtm_tst/com/portno_acquire.csh >>& portno.out

echo '# Stage 1 : make this instance a secondary with a passive source server'
echo '# Command : $MUPIP replicate -instance_create -name=INSTB'
$MUPIP replicate -instance_create -name=INSTB >&! instcreate.out
set stat1 = $status
# Before-image journaling, for the MUPIP JOURNAL -ROLLBACK in stage 5a
echo '# Command : $MUPIP set -journal=enable,on,before -replication=on -region DEFAULT'
$MUPIP set -journal=enable,on,before -replication=on -region DEFAULT >&! setrepl.out
set stat2 = $status
if ((0 == $stat1) && (0 == $stat2)) then
	echo "PASS : the instance file was created and replication is on"
else
	echo "WRONG : the replication setup failed - see instcreate.out and setrepl.out"
	cat instcreate.out setrepl.out
endif
echo

echo '# Stage 2 : MUPIP RUNDOWN -REGION "*" removes the receive pool that the source server shutdown left behind'
source $gtm_tst/$tst/u_inref/recvpool_orphan_start_and_kill-ydb1312.csh stage2
echo '# Command : $MUPIP replicate -source -shutdown -timeout=0'
$MUPIP replicate -source -shutdown -timeout=0 >&! srcstop_stage2.out
set ids = (`$MUPIP replicate -editinstance -show mumps.repl |& $tst_awk '/HDR Receive Pool (Sem|Shm) Id/ {print $6}'`)
if (("$ids[1]" == "$rcvsem") && ("$ids[2]" == "$rcvshm")) then
	echo "PASS : the instance file header still has the receive pool ids"
else
	echo "WRONG : the instance file header has receive pool ids [$ids], expected the ids of the pool left behind"
endif
echo '# Command : $MUPIP rundown -region "*"'
$MUPIP rundown -region "*" >&! rundown_stage2.out
$grep -q "MURPOOLRNDWNSUC, Recvpool section (id = $rcvshm)" rundown_stage2.out
if (0 == $status) then
	echo "PASS : MUPIP RUNDOWN reported MURPOOLRNDWNSUC for the receive pool shared memory"
else
	echo "WRONG : no MURPOOLRNDWNSUC for receive pool shared memory $rcvshm - see rundown_stage2.out"
endif
source $gtm_tst/$tst/u_inref/recvpool_orphan_check_gone-ydb1312.csh
echo

echo '# Stage 3 : a restarted receiver server attaches to the receive pool that the source server shutdown left behind'
source $gtm_tst/$tst/u_inref/recvpool_orphan_start_and_kill-ydb1312.csh stage3
echo '# Command : $MUPIP replicate -source -shutdown -timeout=0'
$MUPIP replicate -source -shutdown -timeout=0 >&! srcstop_stage3.out
echo '# Command : $MUPIP replicate -source -start -passive -instsecondary=INSTA -log=src_stage3b.log'
$MUPIP replicate -source -start -passive -instsecondary=INSTA -log=src_stage3b.log >&! srcstart_stage3b.out
echo '# Command : $MUPIP replicate -receiver -start -listenport=<port> -log=rcv_stage3b.log -buffsize=1048576'
$MUPIP replicate -receiver -start -listenport=$portno -log=rcv_stage3b.log -buffsize=1048576 >&! rcvstart_stage3b.out
$grep -q "Attached to existing recvpool with shmid = \[$rcvshm\]" rcv_stage3b.log
if (0 == $status) then
	echo "PASS : the receiver server attached to the existing receive pool"
else
	echo "WRONG : the receiver server did not attach to receive pool $rcvshm - its recvpool line follows"
	$grep 'recvpool with shmid' rcv_stage3b.log | sed 's/^.* : //'
endif
echo '# Command : $MUPIP replicate -receiver -shutdown -timeout=0'
$MUPIP replicate -receiver -shutdown -timeout=0 >&! rcvstop_stage3b.out
echo '# Command : $MUPIP replicate -source -shutdown -timeout=0'
$MUPIP replicate -source -shutdown -timeout=0 >&! srcstop_stage3b.out
source $gtm_tst/$tst/u_inref/recvpool_orphan_check_gone-ydb1312.csh
echo

echo '# Stage 4 : receive pool ids that no longer name an existing pool are still reset'
source $gtm_tst/$tst/u_inref/recvpool_orphan_start_and_kill-ydb1312.csh stage4
echo '# Command : $gtm_tst/com/ipcrm -m <receive pool shm id> -s <receive pool sem id>'
$gtm_tst/com/ipcrm -m $rcvshm -s $rcvsem >&! ipcrm_stage4.out
echo '# Command : $MUPIP replicate -source -shutdown -timeout=0'
$MUPIP replicate -source -shutdown -timeout=0 >&! srcstop_stage4.out
set ids = (`$MUPIP replicate -editinstance -show mumps.repl |& $tst_awk '/HDR Receive Pool (Sem|Shm) Id/ {print $6}'`)
if ("$ids" == "INVALID INVALID") then
	echo "PASS : the instance file header receive pool ids were reset"
else
	echo "WRONG : the instance file header has receive pool ids [$ids], expected INVALID INVALID"
endif
echo '# Command : $MUPIP replicate -source -start -passive -instsecondary=INSTA -log=src_stage4b.log'
$MUPIP replicate -source -start -passive -instsecondary=INSTA -log=src_stage4b.log >&! srcstart_stage4b.out
echo '# Command : $MUPIP replicate -receiver -start -listenport=<port> -log=rcv_stage4b.log -buffsize=1048576'
$MUPIP replicate -receiver -start -listenport=$portno -log=rcv_stage4b.log -buffsize=1048576 >&! rcvstart_stage4b.out
if (0 == $status) then
	echo "PASS : a receiver server started"
else
	echo "WRONG : the receiver server did not start - see rcvstart_stage4b.out"
	cat rcvstart_stage4b.out
endif
echo '# Command : $MUPIP replicate -receiver -shutdown -timeout=0'
$MUPIP replicate -receiver -shutdown -timeout=0 >&! rcvstop_stage4b.out
echo '# Command : $MUPIP replicate -source -shutdown -timeout=0'
$MUPIP replicate -source -shutdown -timeout=0 >&! srcstop_stage4b.out
echo

echo '# Stage 5a : a receive pool whose semaphore is gone but whose shared memory remains keeps both ids, and MUPIP'
echo '#   JOURNAL -ROLLBACK, as the REPLREQROLLBACK message asks, removes the shared memory'
echo '#   previously both ids were cleared, so a receiver server started with a new receive pool, and nothing removed the'
echo '#   old shared memory'
source $gtm_tst/$tst/u_inref/recvpool_orphan_semgone-ydb1312.csh stage5a
echo '# Command : $MUPIP journal -rollback -backward "*"'
$MUPIP journal -rollback -backward "*" >&! rollback_stage5a.out
set rbstat = $status
$grep -q "JNLSUCCESS, Rollback successful" rollback_stage5a.out
if ((0 == $rbstat) && (0 == $status)) then
	echo "PASS : MUPIP JOURNAL -ROLLBACK succeeded"
else
	echo "WRONG : MUPIP JOURNAL -ROLLBACK returned status $rbstat - see rollback_stage5a.out"
endif
$grep -q "MURPOOLRNDWNSUC, Recvpool section (id = $rcvshm)" rollback_stage5a.out
if (0 == $status) then
	echo "PASS : MUPIP JOURNAL -ROLLBACK reported MURPOOLRNDWNSUC for the receive pool shared memory"
else
	echo "WRONG : no MURPOOLRNDWNSUC for receive pool shared memory $rcvshm - see rollback_stage5a.out"
endif
source $gtm_tst/$tst/u_inref/recvpool_orphan_restart-ydb1312.csh stage5a
echo

echo '# Stage 5b : a receive pool left as in stage 5a, cleaned up with MUPIP RUNDOWN -REGION "*" instead'
echo '#   previously both ids were cleared, so a receiver server started with a new receive pool, and MUPIP RUNDOWN'
echo '#   -REGION "*" did not remove the old shared memory'
source $gtm_tst/$tst/u_inref/recvpool_orphan_semgone-ydb1312.csh stage5b
echo '# Command : $MUPIP rundown -region "*"'
$MUPIP rundown -region "*" >&! rundown_stage5b.out
$grep -q "MURPOOLRNDWNSUC, Recvpool section (id = $rcvshm)" rundown_stage5b.out
if (0 == $status) then
	echo "PASS : MUPIP RUNDOWN reported MURPOOLRNDWNSUC for the receive pool shared memory"
else
	echo "WRONG : no MURPOOLRNDWNSUC for receive pool shared memory $rcvshm - see rundown_stage5b.out"
endif
source $gtm_tst/$tst/u_inref/recvpool_orphan_restart-ydb1312.csh stage5b
echo

echo '# Stage 6 : a receive pool whose shared memory is gone but whose semaphore remains keeps the semaphore id'
echo '#   previously both ids were cleared, so the receiver server created a new semaphore beside the one left behind,'
echo '#   which then stayed on the system'
source $gtm_tst/$tst/u_inref/recvpool_orphan_start_and_kill-ydb1312.csh stage6
echo '# Command : $gtm_tst/com/ipcrm -m <receive pool shm id>'
$gtm_tst/com/ipcrm -m $rcvshm >&! ipcrm_stage6.out
echo '# Command : $MUPIP replicate -source -shutdown -timeout=0'
$MUPIP replicate -source -shutdown -timeout=0 >&! srcstop_stage6.out
set ids = (`$MUPIP replicate -editinstance -show mumps.repl |& $tst_awk '/HDR Receive Pool (Sem|Shm) Id/ {print $6}'`)
if (("$ids[1]" == "$rcvsem") && ("$ids[2]" == "INVALID")) then
	echo "PASS : the instance file header has the receive pool semaphore id and an INVALID shared memory id"
else
	echo "WRONG : the instance file header has receive pool ids [$ids], expected [$rcvsem INVALID]"
endif
echo '# Command : $MUPIP replicate -source -start -passive -instsecondary=INSTA -log=src_stage6b.log'
$MUPIP replicate -source -start -passive -instsecondary=INSTA -log=src_stage6b.log >&! srcstart_stage6b.out
echo '# Command : $MUPIP replicate -receiver -start -listenport=<port> -log=rcv_stage6b.log -buffsize=1048576'
$MUPIP replicate -receiver -start -listenport=$portno -log=rcv_stage6b.log -buffsize=1048576 >&! rcvstart_stage6b.out
if (0 == $status) then
	echo "PASS : a receiver server started"
else
	echo "WRONG : the receiver server did not start - see rcvstart_stage6b.out"
	cat rcvstart_stage6b.out
endif
set ids = (`$MUPIP replicate -editinstance -show mumps.repl |& $tst_awk '/HDR Receive Pool (Sem|Shm) Id/ {print $6}'`)
if (("$ids[1]" == "$rcvsem") && ("$ids[2]" != "INVALID") && ("$ids[2]" != "$rcvshm")) then
	echo "PASS : the receive pool uses the semaphore that was left and a new shared memory"
else
	echo "WRONG : the receive pool ids are [$ids], expected semaphore $rcvsem and a new shared memory"
endif
# The new shared memory, and the semaphore that was left, are what the check below expects to be gone
if ("$ids[2]" != "INVALID") set rcvshm = $ids[2]
echo '# Command : $MUPIP replicate -receiver -shutdown -timeout=0'
$MUPIP replicate -receiver -shutdown -timeout=0 >&! rcvstop_stage6b.out
echo '# Command : $MUPIP replicate -source -shutdown -timeout=0'
$MUPIP replicate -source -shutdown -timeout=0 >&! srcstop_stage6b.out
source $gtm_tst/$tst/u_inref/recvpool_orphan_check_gone-ydb1312.csh
echo

$gtm_tst/com/portno_release.csh
$gtm_tst/com/dbcheck.csh >&! dbcheck.out
if (0 == $status) then
	echo "PASS : dbcheck.csh found no integrity errors"
else
	echo "WRONG : dbcheck.csh failed - see dbcheck.out"
	cat dbcheck.out
endif
