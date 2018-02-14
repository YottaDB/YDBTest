#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# CAUSE SECONDARY TO CRASH
#
# check if MULTISITE is involved
if ( "MULTISITE" == $test_replic ) then
	echo "TEST-E-MULTISITE. Pls. use proper crash scripts for MULTISITE action"
	echo "Instance not crashed"
	exit 1
endif
#=== Start Crash ===
cd $SEC_SIDE
echo "Simulating crash on receiver in `pwd`"
setenv kill_time `date +%H_%M_%S`
setenv KILL_LOG rkill_${kill_time}.logx

set os_machtype = "$gtm_test_osname"_"$gtm_test_machtype"
setenv gtm_test_platform_dir $gtm_tst/com/$os_machtype

echo "Before receiver crash >>>>" >>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER >>& $KILL_LOG
$psuser | $grep -E "mupip|mumps|simpleapi" >>& $KILL_LOG

# Get PIDS for all process on Secondary side
set pidsrc=`$MUPIP replicate -source -checkhealth |& $tst_awk '($1 == "PID") && ($2 ~ /[0-9]*/) { print $2 }'`
if ("$pidsrc" == "") then
        echo "Cannot kill passive source server. Unable to determine pid"
        exit 1
endif

set pidUpdate=() pidReceiver=() pidHelper=()
set rcvhealthfile = ${KILL_LOG:r}_rcvhealth.outx
$MUPIP replicate -receiv -checkhealth -helpers >&! ${rcvhealthfile}
# Evaluates "set pidUpdate=($pidUpdate 12345) ; set pidReceiver=($pidReceiver 54321) ; set pidHelper=($pidHelper 90125) ; [...]"
eval `$tst_awk '($1 == "PID") { print "set pid" $3 "=($pid" $3, $2 ") ;" }' ${rcvhealthfile}`
if ("$pidUpdate" == "") then
        echo "Cannot kill Update Process. Unable to determine pid"
        exit 2
endif
if ("$pidReceiver" == "") then
        echo "Cannot kill Receiver Server. Unable to determine pid"
        exit 2
endif
setenv pidall "$pidsrc $pidReceiver $pidUpdate $pidHelper"

# IPCS
set db_ftok_key = `$gtm_exe/ftok -id=43 *.dat| egrep "dat" | $tst_awk '{printf("%s ",$5);}'`
set repl_ftok_key = `$gtm_exe/ftok -id=44 $gtm_repl_instance | egrep "$gtm_repl_instance" | $tst_awk '{printf("%s ",$5);}'`
# setenv is used below to pass it to a child script
setenv ftok_key "$db_ftok_key $repl_ftok_key"
set dbipc_private = `$gtm_tst/com/db_ftok.csh`
set jnlipc_private = `$gtm_tst/com/jnlpool_ftok.csh`
set rcvipc_private = `$gtm_tst/com/recvpool_ftok.csh`
set ipc_private = "$dbipc_private $jnlipc_private $rcvipc_private"

set stat = 0
set pidcheck = ""
date >>& $KILL_LOG
#################################
# For $1 == MU_STOP and $1 == SIGQUIT we first make sure source server is dead before we stop reciver server or update process
# Otherwise, test output could be non-deterministic
if ($1 == "MU_STOP") then
	## This is SIG TERM
        echo "$MUPIP stop $pidsrc" >>& $KILL_LOG
        $MUPIP stop $pidsrc >>& $KILL_LOG
        if ($status) then
		echo "TEST-E-$MUPIP stop $pidsrc failed"
		set stat = 1
	else
		$gtm_tst/com/wait_for_proc_to_die.csh $pidsrc 300
	endif
	#
	# Followings automatically stops $pidUpdate
        echo "$MUPIP stop $pidReceiver" >>& $KILL_LOG
        $MUPIP stop $pidReceiver >>& $KILL_LOG
        if ($status) then
		echo "TEST-E-$MUPIP stop $pidReceiver failed"
		set stat = 1
	else
		$gtm_tst/com/wait_for_proc_to_die.csh $pidReceiver 300
		$gtm_tst/com/wait_for_proc_to_die.csh $pidUpdate  300
	endif
	set pidcheck = "$pidsrc|$pidReceiver|$pidUpdate"
	#
else if ($1 == "SIGQUIT") then
	# the order is deliberately pidsrc, pidReceiver and NO pidUpdate, to see for sure that the update process does
	# die after the receiver process has exited. DO NOT include kill -3 (BYPASSOK) of pidUpdate
	#
	date >>& $KILL_LOG
	echo "$kill -3 $pidsrc pidsrc" >>& $KILL_LOG
	$kill -3 $pidsrc >>& $KILL_LOG
	if ($status) then
		echo "TEST-E-$kill -3 $pidsrc pidsrc failed" | tee -a $KILL_LOG
		set stat = 1
	else
		$gtm_tst/com/wait_for_proc_to_die.csh $pidsrc 300
	endif
	#
	date >>& $KILL_LOG
	echo "$kill -3 $pidReceiver pidReceiver" >>& $KILL_LOG
	$kill -3 $pidReceiver >>& $KILL_LOG
	if ($status) then
		echo "TEST-E-$kill -3 $pidReceiver pidReceiver failed" | tee -a $KILL_LOG
		set stat = 1
	else
		$gtm_tst/com/wait_for_proc_to_die.csh $pidReceiver 300
		$gtm_tst/com/wait_for_proc_to_die.csh $pidUpdate  300
	endif
	date >>& $KILL_LOG
	set pidcheck = "$pidsrc|$pidReceiver|$pidUpdate"
else
	set killit = "/bin/kill -9"	# BYPASSOK kill -9
        echo "$killit $pidall" >>& $KILL_LOG
        $killit $pidall
        if ($status) then
		echo "TEST-E-$killit $pidall failed"
		set stat = 1
	else
		foreach pid ($pidall)
			$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
			set pidcheck = "$pidcheck|$pid"
		end
	endif
	if ($1 != "NO_IPCRM") then
		echo "ipcrm <ipc_private> $ipc_private" >>& $KILL_LOG
		echo "ipcrm <ftok_key> $ftok_key" >>& $KILL_LOG
		echo "MUPIP rundown -relinkctl" >>& $KILL_LOG
		$gtm_tst/com/ipcrm $ipc_private >>& $KILL_LOG
		$gtm_tst/com/rem_ftok_sem.csh # arguments $ftok_key
		# Collecting the IDs of relinkctl shared memory segments from the RCTLDUMP is prohibitive, so clean directly.
		$MUPIP rundown -relinkctl >>& $KILL_LOG
	endif
endif
# Automatic unfreeze does not take place in two cases: 1) The passive source server is killed after setting fake ENOSPC flag.
# 2) mumps process is killed after setting the freeze (the process which set the freeze is responsible for unsetting it as well).
if ($?test_replic && $?gtm_test_fake_enospc) then
	if (1 == $gtm_test_fake_enospc) then
		echo "# Unfreezing. REPLREQROLLBACK error may occur." >>& $KILL_LOG
		$MUPIP replicate -source -freeze=off >>& $KILL_LOG
	endif
endif
#################################
#
echo "After Receiver crash >>>>" >>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER >>  $KILL_LOG
$psuser | $grep -E "mupip|mumps|simpleapi$pidcheck" >>& $KILL_LOG
set stat = 0
###############
date >>& $KILL_LOG
echo "Receiver crashed!"
exit $stat
#=== End Crash ===
