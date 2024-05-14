#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# CAUSE PRIMARY TO CRASH
#
#=== Start Crash ===
if ($?test_replic) then
	if ( "MULTISITE" == $test_replic ) then
		set instance="Instance "$gtm_test_cur_pri_name
		set instance1="Instance "$gtm_test_cur_pri_name
	endif
else
	set test_replic = ""	# dummy value in case this script is called without replication
endif
if (! $?instance) then
	set instance="primary"
	set instance1="Primary"
endif
cd $PRI_SIDE
echo "Simulating crash on $instance in `pwd`"
setenv kill_time `date +%H_%M_%S`
setenv KILL_LOG pkill_${kill_time}.logx

set os_machtype = "$gtm_test_osname"_"$gtm_test_machtype"
setenv gtm_test_platform_dir $gtm_tst/com/$os_machtype

echo "Before $instance1 crash >>>>" >>& $KILL_LOG
date >>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER >>  $KILL_LOG
$psuser | $grep -E "mupip|mumps|simpleapi" >>& $KILL_LOG

# PID for source server
set pidsrc=`$MUPIP replicate -source -checkhealth |& $tst_awk '($1 == "PID") && ($2 ~ /[0-9]*/) { print $2 }'`
if ("$pidsrc" == "") then
	echo "TEST-E-NOCRASH Cannot kill $instance server. Unable to determine pid" # BYPASSOK kill
	exit 1
endif
# PID for mumps
if ($gtm_test_jobid != 0) then
	$tst_awk '$1 ~ /PID/' *${gtm_test_jobid}.mjo* >&! mpid.txt
else
	$tst_awk '$1 ~ /PID/' *.mjo*  >&! mpid.txt
endif
# this check is introduced to avoid "grep: No match errors" in case of multisite actions which is
# common for both receiver instance and source instance.In case of receiver there will be no *.mjo* files
set mpid=`$tst_awk '$2 ~ /^[0-9]+$/ {printf("%s ",$2);}' mpid.txt`
echo "Contents of mpid.txt (just in case it matters in test failures)" >>& $KILL_LOG
cat mpid.txt >>& $KILL_LOG
rm -f mpid.txt >& /dev/null
setenv pidall "$mpid"
# in case of MULTISITE - RCVR instance we will have to account for rcvr ipcs as well.
setenv rcvipc_private
if ( "MULTISITE" == $test_replic ) then
	# For MULTISITE we use this same script to crash the receiver servers as well
	set pidUpdate=() pidReceiver=() pidHelper=()
	set rcvhealthfile = ${KILL_LOG:r}_rcvhealth.outx
	$MUPIP replicate -receiv -checkhealth -helpers >&! ${rcvhealthfile}
	# Evaluates "set pidUpdate=($pidUpdate 12345) ; set pidReceiver=($pidReceiver 54321) ; set pidHelper=($pidHelper 90125) ; [...]"
	eval `$tst_awk '($1 == "PID") { print "set pid" $3 "=($pid" $3, $2 ") ; " }' ${rcvhealthfile}`
	setenv pidall "$pidall $pidReceiver $pidUpdate $pidHelper"
#	in case of MULTISITE - RCVR instance we will have to account for rcvr ipcs as well.
	if ( ("" != $pidReceiver) || ("" != $pidUpdate) ) set rcvipc_private=`$gtm_tst/com/recvpool_ftok.csh`
endif

# IPCS
set db_ftok_key = `$MUPIP ftok -id=43 *.dat |& egrep "dat" | $tst_awk '{printf("%s ", substr($10, 2, 10))}'`
set repl_ftok_key = `$MUPIP ftok -id=44 $gtm_repl_instance |& egrep "$gtm_repl_instance" | $tst_awk '{printf("%s ", substr($10, 2, 10))}'`
setenv ftok_key "$db_ftok_key $repl_ftok_key"
set dbipc_private = `$gtm_tst/com/db_ftok.csh`
set jnlipc_private = `$gtm_tst/com/jnlpool_ftok.csh`
set ipc_private = "$dbipc_private $jnlipc_private $rcvipc_private"

set stat = 0
set pidcheck = ""
date >>& $KILL_LOG
#################################
# For $1 == MU_STOP and $1 == SIGQUIT we first make sure source server is dead before we stop M processes
# Otherwise, test output could be non-deterministic
#
if ($1 == "MU_STOP") then 		# This is SIG TERM
	echo "$MUPIP stop $pidsrc"  >>& $KILL_LOG
	$MUPIP stop $pidsrc  >>& $KILL_LOG
	if ($status) then
		echo "$MUPIP stop $pidsrc failed"
		set stat = 1
	else
		$gtm_tst/com/wait_for_proc_to_die.csh $pidsrc 300
	endif
	foreach pid ($pidall)
        	echo "$MUPIP stop $pid" >>& $KILL_LOG
        	$MUPIP stop $pid >>& $KILL_LOG
        	if ($status) then
			echo "TEST-E-$MUPIP stop $pid failed"
			set stat = 1
		else
			$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
			set pidcheck = "$pidcheck|$pid"
		endif
	end
else if ($1 == "SIGQUIT") then
	# First kill the source server. See <dual_fail_extend_missing_MUJPOOLRNDWNSUC> ###
	set killit3 = "/bin/kill -3"	# BYPASSOK kill -3
	echo "$killit3 $pidsrc"  >>& $KILL_LOG
	$killit3 $pidsrc  >>& $KILL_LOG
	if ($status) then
		echo "TEST-E-$killit3 $pidsrc failed"
		set stat = 1
	else
		$gtm_tst/com/wait_for_proc_to_die.csh $pidsrc 300
		set pidcheck = "$pidcheck|$pidsrc"
	endif
	echo "$killit3 $pidall" >>& $KILL_LOG
        $killit3 $pidall >>& $KILL_LOG
        if ($status) then
		echo "TEST-E-$killit3 $pidall failed"
		set stat = 1
	else
		foreach pid ($pidall)
			$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
			set pidcheck = "$pidcheck|$pid"
		end
	endif
	#
else
	set killit = "/bin/kill -9"	# BYPASSOK kill -9
        echo "$killit $pidsrc $pidall" >>& $KILL_LOG
        $killit $pidsrc $pidall
        if ($status) then
		echo "TEST-E-$killit $pidsrc $pidall failed"
		set stat = 1
	else
		foreach pid ($pidsrc $pidall)
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
		# Now that any ipcs that were recorded in the db file header have been cleaned, check semaphores of MM
		# gtmhelp.dat files that were potentially open (these are not recorded in any db file header and have to be
		# examined using "ipcs -s") and clean them up as otherwise they would be orphaned and accumulate in the system.
		$gtm_tst/com/imptp_crash_helpdb_semclean.csh $KILL_LOG "$pidall"
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

echo "After $instance1 crash >>>>" >>& $KILL_LOG
date >>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER >>  $KILL_LOG
$psuser | $grep -E "mupip|mumps|simpleapi$pidcheck" >>& $KILL_LOG
############
date >>& $KILL_LOG
echo "$instance1 crashed!"
exit $stat
#=== End Crash ===
