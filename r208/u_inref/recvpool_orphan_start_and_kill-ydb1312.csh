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

# Sourced by recvpool_orphan-ydb1312.csh with the stage name as $1. Starts the passive source server and the receiver
# server, then kills the receiver server and the update process with SIGKILL, which leaves the receive pool behind.
# Sets rcvshm and rcvsem to the ids of that receive pool.
set stage = $1
echo '# Command : $MUPIP replicate -source -start -passive -instsecondary=INSTA -log=src_'$stage'.log'
$MUPIP replicate -source -start -passive -instsecondary=INSTA -log=src_$stage.log >&! srcstart_$stage.out
echo '# Command : $MUPIP replicate -receiver -start -listenport=<port> -log=rcv_'$stage'.log -buffsize=1048576'
$MUPIP replicate -receiver -start -listenport=$portno -log=rcv_$stage.log -buffsize=1048576 >&! rcvstart_$stage.out
# Wait (at most 60 seconds) for the update process to start
set i = 0
set updpid = ""
while ($i < 60)
	set updpid = `$gtm_tst/com/get_pid.csh updproc`
	if ("" != "$updpid") break
	sleep 1
	@ i = $i + 1
end
set rcvpid = `$gtm_tst/com/get_pid.csh rcvr`
set rcvshm = `$MUPIP replicate -editinstance -show mumps.repl |& $tst_awk '/HDR Receive Pool Shm Id/ {print $6}'`
set rcvsem = `$MUPIP replicate -editinstance -show mumps.repl |& $tst_awk '/HDR Receive Pool Sem Id/ {print $6}'`
if (("" != "$rcvpid") && ("" != "$updpid") && ("INVALID" != "$rcvshm") && ("INVALID" != "$rcvsem")) then
	echo "PASS : the receiver server and update process are running and the receive pool exists"
else
	echo "WRONG : receiver server [$rcvpid] update process [$updpid] receive pool shm [$rcvshm] sem [$rcvsem]"
endif
echo '# Command : $gtm_tst/com/kill9.csh <receiver server pid> ; $gtm_tst/com/kill9.csh <update process pid>'
$gtm_tst/com/kill9.csh $rcvpid >&! kill9_rcv_$stage.out
$gtm_tst/com/kill9.csh $updpid >&! kill9_upd_$stage.out
