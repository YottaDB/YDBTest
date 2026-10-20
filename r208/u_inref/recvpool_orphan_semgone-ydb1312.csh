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

# Sourced by recvpool_orphan-ydb1312.csh at the start of stages 5a and 5b, with the stage name as its argument. Leaves
# a receive pool whose semaphore is gone but whose shared memory remains, checks that the source server shutdown keeps
# both of its ids in the instance file header, and that a receiver server then does not start, with REPLREQROLLBACK.
# The passive source server is shut down at the end. Sets rcvshm and rcvsem to the ids of that receive pool.

set stage = $1
source $gtm_tst/$tst/u_inref/recvpool_orphan_start_and_kill-ydb1312.csh $stage
echo '# Command : $gtm_tst/com/ipcrm -s <receive pool sem id>'
$gtm_tst/com/ipcrm -s $rcvsem >&! ipcrm_$stage.out
echo '# Command : $MUPIP replicate -source -shutdown -timeout=0'
$MUPIP replicate -source -shutdown -timeout=0 >&! srcstop_$stage.out
set ids = (`$MUPIP replicate -editinstance -show mumps.repl |& $tst_awk '/HDR Receive Pool (Sem|Shm) Id/ {print $6}'`)
if (("$ids[1]" == "$rcvsem") && ("$ids[2]" == "$rcvshm")) then
	echo "PASS : the instance file header still has both receive pool ids"
else
	echo "WRONG : the instance file header has receive pool ids [$ids], expected [$rcvsem $rcvshm]"
endif
echo '# Command : $MUPIP replicate -source -start -passive -instsecondary=INSTA -log=src_'$stage'b.log'
$MUPIP replicate -source -start -passive -instsecondary=INSTA -log=src_${stage}b.log >&! srcstart_${stage}b.out
echo '# Command : $MUPIP replicate -receiver -start -listenport=<port> -log=rcv_'$stage'b.log -buffsize=1048576'
$MUPIP replicate -receiver -start -listenport=$portno -log=rcv_${stage}b.log -buffsize=1048576 >&! rcvstart_${stage}b.out
set rcvstat = $status
# REPLREQROLLBACK comes with ENO22 from the semctl() on the removed semaphore. The messages hold the instance file
# path and ids, so keep the check's output out of the reference file.
$gtm_tst/com/check_error_exist.csh rcvstart_${stage}b.out REPLREQROLLBACK ENO22 >&! check_error_${stage}b.logx
if ((0 != $rcvstat) && (0 == $status)) then
	echo "PASS : the receiver server did not start, with REPLREQROLLBACK"
else
	echo "WRONG : the receiver server start returned status $rcvstat, expected it to fail with REPLREQROLLBACK - see rcvstart_${stage}b.out"
	if (0 == $rcvstat) then
		echo '# Command : $MUPIP replicate -receiver -shutdown -timeout=0'
		$MUPIP replicate -receiver -shutdown -timeout=0 >&! rcvstop_${stage}b.out
	endif
endif
echo '# Command : $MUPIP replicate -source -shutdown -timeout=0'
$MUPIP replicate -source -shutdown -timeout=0 >&! srcstop_${stage}b.out
