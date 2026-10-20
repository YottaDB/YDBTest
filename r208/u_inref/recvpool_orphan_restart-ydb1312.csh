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

# Sourced by recvpool_orphan-ydb1312.csh at the end of stages 5a and 5b, with the stage name as its argument, after
# the receive pool left behind was cleaned up. Checks that the shared memory left behind (rcvshm) no longer exists,
# that a passive source server and a receiver server start, and that their normal shutdown leaves nothing behind.

set stage = $1
# Keep the instance file header as the cleanup left it, for diagnosis
$MUPIP replicate -editinstance -show mumps.repl >&! inst_after_cleanup_$stage.logx
$gtm_tst/com/ipcs -m | $tst_awk '{print $2}' | $grep -qw "$rcvshm"
if (0 != $status) then
	echo "PASS : the receive pool shared memory left behind no longer exists"
else
	echo "WRONG : receive pool shared memory $rcvshm still exists"
endif
echo '# Command : $MUPIP replicate -source -start -passive -instsecondary=INSTA -log=src_'$stage'c.log'
$MUPIP replicate -source -start -passive -instsecondary=INSTA -log=src_${stage}c.log >&! srcstart_${stage}c.out
set srcstat = $status
echo '# Command : $MUPIP replicate -receiver -start -listenport=<port> -log=rcv_'$stage'c.log -buffsize=1048576'
$MUPIP replicate -receiver -start -listenport=$portno -log=rcv_${stage}c.log -buffsize=1048576 >&! rcvstart_${stage}c.out
set rcvstat = $status
if ((0 == $srcstat) && (0 == $rcvstat)) then
	echo "PASS : the passive source server and a receiver server started"
else
	echo "WRONG : the passive source server start returned $srcstat and the receiver server start $rcvstat, expected 0 and 0 - see srcstart_${stage}c.out and rcvstart_${stage}c.out"
endif
# Remove the shared memory left behind if it still exists (reported above), and check below that the normal shutdown
# removes the receive pool that the receiver server uses now
$gtm_tst/com/ipcrm -m $rcvshm >& /dev/null
set ids = (`$MUPIP replicate -editinstance -show mumps.repl |& $tst_awk '/HDR Receive Pool (Sem|Shm) Id/ {print $6}'`)
set rcvsem = $ids[1]
set rcvshm = $ids[2]
echo '# Command : $MUPIP replicate -receiver -shutdown -timeout=0'
$MUPIP replicate -receiver -shutdown -timeout=0 >&! rcvstop_${stage}c.out
echo '# Command : $MUPIP replicate -source -shutdown -timeout=0'
$MUPIP replicate -source -shutdown -timeout=0 >&! srcstop_${stage}c.out
source $gtm_tst/$tst/u_inref/recvpool_orphan_check_gone-ydb1312.csh
