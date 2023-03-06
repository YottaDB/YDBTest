#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# called as: try_rolrec.csh [RECOVER|ROLLBACK] [CRASH|STOP|IDEMP] [ZTP|.] logfile <mupip arguments>
echo "-------------------------- try_rolrec --------------------------"
echo "args: $argv"
set rol_or_rec = $1
setenv crash_stop  $2
setenv ztptp  "$3"
set logfile = $4
shift
shift
shift
echo "args: $argv"
echo "The time is (try_rolrec1):" `date`
setenv no `echo ${1:r} | sed 's/[a-zA-Z]*//g'`
set bakdir = "bak_${1:r}"
echo "The time is (try_rolrec before cp):" `date`
$gtm_tst/com/backup_dbjnl.csh $bakdir '*.dat *.gld *.mjl* *.repl*'
echo "The time is (try_rolrec1 after cp):" `date`
if (-e mupip.pid) mv mupip.pid mupip.pid_`date +%H_%M_%S`
#set sleepmax:
set grab = $rol_or_rec
if ("ZTP" == $ztptp) set grab = ${ztptp}_$rol_or_rec
set log_rand = `$gtm_exe/mumps -run rand $rand_value`
set sleepmax = `$gtm_exe/mumps -run exp $log_rand`
if (("ROLLBACK" == $rol_or_rec) && $?gtm_test_freeze_on_error) then
	if ($gtm_test_freeze_on_error) then
		# We may have hit DBDANGER or some other custom error, so unfreeze before the rollback.
		$MUPIP replic -source -freeze=off >>& unfreeze_`date +%H_%M_%S`.outx
	endif
endif
if (("CRASH" == $crash_stop) || ("STOP" == $crash_stop)) then
	echo "The time is (try_rolrec2):" `date`
	$gtm_tst/$tst/u_inref/rolrec_bg_fg.csh $rol_or_rec "BG" $argv
	set format="%Y %m %d %H %M %S %Z"
	set starttime=`date +"$format"`	# Start time
	if (! -e mupip.pid) echo "TEST-E-NOTSTART, Mupip did not start"
	set mupip_pid = `cat mupip.pid`
	if ("" == "$mupip_pid") then
		echo "TEST-E-MUPIPPID, Could not determine mupip_pid from mupip.pid"
		exit 4
	endif
	if ($?third_sleeptime == 0) then
		@ maxsleep = $sleepmax + $sleepmax
		@ rand = $sleepmax + `$gtm_exe/mumps -run rand $sleepmax`
		if ($LFE == "L") set rand = `$gtm_exe/mumps -run rand 6` # for debugging, do not sleep too much
		# With ZTP, we end up spending most of the time in jnl_wait right after the ZTCOMMIT
		# ensuring the journal records are hardened before returning to the application
		# Therefore even though GT.M did updates for 5 minutes or so, recovery will be completed in few seconds.
		# This is because recovery skips the jnl_wait explicitly.
		# In case the test chose to wait longer, we will end up missing all attempts at crashing recovery in the middle
		# since it finishes much sooner than we think it would take.
		# So we will sleep for a random 2 5 and 8 seconds for each try
		# The values are easily obtained by taking $rand_value and the $R is already in $log_rand. So just use it
		if ("ZTP" == "$ztptp") set rand = "$log_rand"
	else
		echo "Passed sleep time for third attempt is: "$third_sleeptime
		set maxsleep = $third_sleeptime
		set rand = $third_sleeptime
	endif
	echo "`date` Will give the mupip command a max of $maxsleep (sleepmax) seconds..."
	echo "`date` will give MUPIP $rand seconds by sleeping..."
	# do this sleep in 1-second increments that keep checking if the process is alive
	set alive = 1
	@ sleeptime = $rand
	set nowtime=`date +"$format"`	# Time now
	@ difftime = `echo $starttime " " $nowtime | $tst_awk -f $gtm_tst/com/diff_time.awk`
	while ($sleeptime > $difftime)
		$gtm_tst/com/is_proc_alive.csh $mupip_pid
		if (1 == $status) then
			echo "`date` TEST-I-STOPPED, Mupip process stopped before the max sleep time."
			set alive = 0
			@ difftime = $sleeptime
		else
			sleep 1
			date
			set nowtime=`date +"$format"`	# Time now
			@ difftime = `echo $starttime " " $nowtime | $tst_awk -f $gtm_tst/com/diff_time.awk`
		endif
	end
	if ("STOP" == $crash_stop) then
		setenv KILL_LOG mstop_`date +%H_%M_%S`.logx
		# On zOS, tee creates UNTAGGED files so need to tag it just in case GT.M or MUPIP writes to it later
		touch $KILL_LOG
		$convert_to_gtm_chset $KILL_LOG
		echo "------------------" |& tee -a $KILL_LOG
                echo "Before MUPIP STOP:" |& tee -a $KILL_LOG
                echo "------------------" |& tee -a $KILL_LOG
                echo "The time is (try_rolrec3):" `date`
                $psuser | $grep -E "mupip|mumps" |& tee -a $KILL_LOG
                $gtm_tst/com/ipcs -a | $grep $USER >>& $KILL_LOG
                echo "Will MUPIP STOP $mupip_pid" |& tee -a $KILL_LOG
                echo "The time is (try_rolrec4):" `date`
                echo $MUPIP stop $mupip_pid
                $MUPIP stop $mupip_pid |& tee -a $KILL_LOG >& mstop_$KILL_LOG
                set mstop_status = $status
                echo Status of MUPIP STOP is: $mstop_status
                if (0 != $mstop_status) echo "TEST-E-KILL error from MUPIP STOP"
                # We assume that "kill -9" on all Unix platforms prints either "No such process" or "The process does not exist" in case $mupip_pid does not exist
                $grep -E "No such process|The process does not exist" mstop_$KILL_LOG
                if (0 == $status) then
                        # process died before we attempted MUPIP STOP. do not consider this as an error.
                        cat mstop_$KILL_LOG >> $KILL_LOG
                        echo "`date` TEST-X-NOTALIVE, the process is not alive, cannot issue STOP"
                        echo "cannot continue with this step."
                        $gtm_tst/$tst/u_inref/check_status.csh $logfile
                        set stat =  $status
                        if (! $stat) exit 0 # NOTALIVE is not an error now
                        exit $stat
                endif
                echo "-----------------" |& tee -a $KILL_LOG
                echo "After MUPIP STOP:" |& tee -a $KILL_LOG
                echo "-----------------" |& tee -a $KILL_LOG
		# wait for the process to die
                $gtm_tst/com/wait_for_proc_to_die.csh $mupip_pid 120 # MUPIP STOP should not take 2 minutes to kill process
		set mstop_status = $status
                echo "The time is (try_rolrec5):" `date`
                $gtm_tst/com/ipcs -a | $grep $USER >>& $KILL_LOG
                $psuser | $grep -E "mupip|mumps" |& tee -a $KILL_LOG
                if (0 != $mstop_status) then
                        echo "TEST-E-MUPIPSTOPERROR process $mupip_pid did not stop"
                        uptime
			echo "Check file ${mupip_pid}_stack_trace.outx for trace of the process"
			$gtm_tst/com/get_dbx_c_stack_trace.csh $mupip_pid $MUPIP >>&! ${mupip_pid}_stack_trace.outx
			$gtm_tst/com/check_PC_INVAL_err.csh $mupip_pid ${mupip_pid}_stack_trace.outx
                        exit 4
                endif
		$gtm_tst/com/ipcs -a | $grep $USER >>& $KILL_LOG
		set ipcs_count = `$gtm_tst/com/ipcs -a | $grep $USER | wc -l`
		if (0 < $ipcs_count) then
			echo "TEST-I-IPCS, there are some ipc's after the stop, are they for a different test? Check $KILL_LOG"
			# There might be ftok collitions and semaphores left over. This is not abnormal. So do not issue an error.
			# For now commenting out this check. If there is a strong reason to have the check, enable it
			#$gtm_tst/$tst/u_inref/list_db_ftok.csh
			#if (0 != $status) then
			#	echo "TEST-I-IPCS, there are some ipc's after the stop, and seem to belong to this database. Check $KILL_LOG (and ftok.list)"
			#endif
			####
		endif
		$grep "FORCEDHALT" $logfile > /dev/null
		if ($status) then
			#it means mupip actually finished, which it should not have.
			echo "`date` TEST-X-MUPIPDIDNOTSTOP, the mupip process actually completed. Was not able to test MUPIP STOP"
			$gtm_tst/$tst/u_inref/check_status.csh $logfile
			set stat =  $status
			if (! $stat) exit 0 # NOTALIVE is not an error now
			exit $stat
		endif
	else
		setenv KILL_LOG mkill_`date +%H_%M_%S`.logx
		# On zOS, tee creates UNTAGGED files so need to tag it just in case GT.M or MUPIP writes to it later
		touch $KILL_LOG
		$convert_to_gtm_chset $KILL_LOG
		#i.e. CRASH
		echo "CRASHING MUPIP..." |& tee -a $KILL_LOG
		echo "-----------------" |& tee -a $KILL_LOG
                echo "Before the kill:" |& tee -a $KILL_LOG
                echo "-----------------" |& tee -a $KILL_LOG
                echo "The time is (try_rolrec6):" `date`
                $gtm_tst/com/ipcs -a | $grep $USER >>& $KILL_LOG
                $psuser | $grep -E "mupip|mumps" |& tee -a $KILL_LOG
                echo "Will kill $mupip_pid" |& tee -a $KILL_LOG
                echo "The time is (try_rolrec7):" `date`
                echo "kill -9 $mupip_pid"					# BYPASSOK kill
                kill -9 $mupip_pid |& tee -a $KILL_LOG >& kill9_$KILL_LOG	# BYPASSOK kill
                set kill_status = $status
                # We assume that "kill -9" on all Unix platforms prints either "No such process" or "The process does not exist" in case $mupip_pid does not exist
                $grep -E "No such process|The process does not exist" kill9_$KILL_LOG
		if (0 == $status) then
                        # process died before we attempted kill -9. do not consider this as an error.
                        cat kill9_$KILL_LOG >> $KILL_LOG
                        echo "`date` TEST-X-NOTALIVE, the process is not alive, cannot CRASH"
                        echo "cannot continue with this step."
                        $gtm_tst/$tst/u_inref/check_status.csh $logfile
                        set stat =  $status
                        if (! $stat) exit 0 # NOTALIVE is not an error now
                        exit $stat
                endif
                echo Status of kill is: $kill_status
                if (0 != $kill_status) echo "TEST-E-KILL error from kill"
		# If gtm_mupjnl_parallel is 0 or > 1, it is possible multiple child mupip processes are running.
		# If so, they need to be killed as well. "fuser -k *.dat" comes in handy for this. That will send a
		# kill9 to all processes which have some *.dat file (in the current directory) open.
		if ($?gtm_mupjnl_parallel) then
			if (1 != $gtm_mupjnl_parallel) then
				echo "-------gtm_mupjnl_parallel = $gtm_mupjnl_parallel---- " >> $KILL_LOG
				echo "-------KILLing child mupip processes if any----" >> $KILL_LOG
				echo "fuser *.dat" >> $KILL_LOG
				fuser *.dat >> $KILL_LOG
				echo "fuser -k *.dat" >> $KILL_LOG
				fuser -k *.dat >> $KILL_LOG
			endif
		endif
		set db_ftok_key = `$MUPIP ftok -id=43 *.dat |& $grep "dat" | $tst_awk '{printf("%s ", substr($10,2,10));}'`
		setenv ftok_key "$db_ftok_key"
		set dbipc_private = `$gtm_tst/com/db_ftok.csh`
		set ipc_private = "$dbipc_private"
		if ("ROLLBACK" == $rol_or_rec) then
			echo "-------------" >> $KILL_LOG
			echo "$MUPIP ftok -jnlpool $gtm_repl_instance" >> $KILL_LOG
			$MUPIP ftok -jnlpool $gtm_repl_instance >>& $KILL_LOG
			echo "$MUPIP ftok -recv $gtm_repl_instance" >> $KILL_LOG
			$MUPIP ftok -recv $gtm_repl_instance >>& $KILL_LOG
			set jnlipc_private = `$gtm_tst/com/jnlpool_ftok.csh`
			set rcvipc_private = `$gtm_tst/com/recvpool_ftok.csh`
			set ipc_private = "$dbipc_private $jnlipc_private $rcvipc_private"
			echo "-------------" >> $KILL_LOG
		endif
		setenv ipc_privatex `echo $ipc_private | sed 's/-m -1//g'`
		echo $ipc_privatex
		echo ftok_key $ftok_key  >> $KILL_LOG
		echo ipc_privatex $ipc_privatex  >> $KILL_LOG
		set rand = `$gtm_exe/mumps -run rand  2`
		# randomize IPCS removal, execept for Online Rollback
		if (($rand) && ("TRUE" != "$gtm_test_onlinerollback")) then
			echo "TEST-I-IPC REMOVED, Will remove ipcs"
			echo "Removing ipcs, check $KILL_LOG for details..."
			echo "$gtm_tst/com/ipcrm $ipc_privatex" >> $KILL_LOG
			$gtm_tst/com/ipcrm $ipc_privatex >>& $KILL_LOG
			$gtm_tst/com/rem_ftok_sem.csh # arguments $ftok_key
		else
			echo "TEST-I-IPC NOT REMOVED, Will not remove ipcs"
		endif
		echo "-----------------" |& tee -a $KILL_LOG
		echo "After the kill:" |& tee -a $KILL_LOG
		echo "-----------------" |& tee -a $KILL_LOG
		$gtm_tst/com/wait_for_proc_to_die.csh $mupip_pid 120
		set mkill_status = $status
		echo "The time is (try_rolrec8):" `date`
		$gtm_tst/com/ipcs -a | $grep $USER >>& $KILL_LOG
		$psuser | $grep -E "mupip|mumps" |& tee -a $KILL_LOG
                if (0 != $mkill_status) then
                        echo "`date` TEST-E-ALIVE, the process is still alive, could not KILL -9"
                        echo "cannot continue with the test."
                        $gtm_tst/com/get_dbx_c_stack_trace.csh $mupip_pid $MUPIP
                        exit 4
                endif
		$grep "End processing at" $logfile > /dev/null
		if (! $status) then
			#it means mupip actually finished, which it should not have.
			echo "`date` TEST-X-MUPIPDIDNOTSTOP, the mupip process actually completed. Was not able to test crashing mupip."
			$gtm_tst/$tst/u_inref/check_status.csh $logfile
			set stat =  $status
			if (! $stat) exit 0 # NOTALIVE is not an error now
			exit $stat
		endif
		# In case the killed process had frozen the instance, do an unfreeze.
		$MUPIP replicate -source -freeze=off >& ${KILL_LOG:s/_/_unfreeze_/}
	endif
else
	#i.e. let it run to completion
	set before = `date +%s`
	echo "The time is (try_rolrec9):" `date`
	$gtm_tst/$tst/u_inref/rolrec_bg_fg.csh $rol_or_rec "FG" $argv
	set after = `date +%s`
	echo "The time is (try_rolrec10):" `date`
	@ difftime = $after - $before
	source $gtm_tst/$tst/u_inref/find_span.csh $crash_stop
	echo "The span of this command was: $span"
	set rol_or_rec_log="$gtm_test_log_dir/${HOST:r:r:r}_${rol_or_rec}.log"
	echo "MUPIP ${rol_or_rec} $crash_stop $ztptp ${no}:  $difftime $span ($tst_general_dir)" |tee -a ${HOST:r:r:r}_${rol_or_rec}.log >>&! $rol_or_rec_log
	#Change permissions to group writable
	chmod 664 $rol_or_rec_log >& /dev/null
endif

$gtm_tst/$tst/u_inref/check_status.csh $logfile
exit $status
echo "---------------------- end try_rolrec --------------------------"
