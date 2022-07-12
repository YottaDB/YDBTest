#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# RF_START: Starts source  and receiver server
#

if ($?test_jnlseqno == 1) then
	# Depending on the test_replic_suppl_type (A->B or A->P or P->Q ) "-supplementary" has to be passed for replication instace creation command
	set srcsuppl = ""
	set rcvrsuppl = ""
	if (2 == $test_replic_suppl_type) then
		set srcsuppl = "-supplementary"
	endif
	if ((1 == $test_replic_suppl_type) || (2 == $test_replic_suppl_type)) then
		set rcvrsuppl = "-supplementary"
	endif
	if ($test_jnlseqno == "4G") $gtm_tst/com/set4Gjnlseqno.csh "$srcsuppl" "$rcvrsuppl" >&! set4Gjnlseqno.out
endif

if ($?gtm_test_replic_timestamp) then
	setenv start_time $gtm_test_replic_timestamp
else
	setenv start_time `date +%H_%M_%S`
endif
#====================
# Find an unsused port
#====================
# Save the portnumber info and start time info in files in secondary and primary respectively.
# Do this "before" starting src and rcvr, as we need these information even if the starting of servers fails.
setenv portno `$sec_shell "$sec_getenv; cd $SEC_SIDE; source $gtm_tst/com/portno_acquire.csh >&! portno ; cat portno"`
if ("" != `echo "$portno" | tr -d '0-9'`) then
	echo "TEST-E-PORTNO : Invalid port number : $portno"
	exit 1
endif
$pri_shell "cd $PRI_SIDE ; echo $portno >&! START_${start_time}.out ; echo $start_time >&! start_time"

#====================
# check if the user has passed on any replication option
#====================
# This section is meant for multisite_replic actions to decide about replication state of the database
if ( "decide" == $1 ) then
	setenv main_repl_state $1
else
	setenv main_repl_state "on"
endif
if ("" != "$argv") shift
set other_qualifiers = "$argv"
#==========================
# Start source server
#==========================
echo "Starting Primary Source Server in $PRI_SIDE"
$pri_shell "$pri_getenv;cd $PRI_SIDE;$gtm_tst/com/SRC.csh $main_repl_state $portno $start_time $other_qualifiers  >&! START_${start_time}.out ; grep -E '^SRC_START_SUCCESSFUL' START_${start_time}.out" >&! START_${start_time}_SRC_status.out # BYPASSOK grep
set src_start = `cat START_${start_time}_SRC_status.out`
if ( "SRC_START_SUCCESSFUL" != "$src_start" ) then
	echo "################################################################"
	echo "TEST-E-ERROR_SRC, Error from SRC.csh, test cannot continue! Check $PRI_SIDE/START_${start_time}.out"
	$pri_shell "cat $PRI_SIDE/START_${start_time}.out"
	echo "Check capture_ps_ipcs_ss_lsof_${start_time}.out for ps/ipcs/ss/lsof -i/env output." # BYPASSOK ps
	$pri_shell "cd $PRI_SIDE; ($gtm_tst/com/capture_ps_ipcs_ss_lsof.csh; env ; set) >>& capture_ps_ipcs_ss_lsof_${start_time}.out"
	echo "################################################################"
	exit 1
endif
#==========================
# Start receiver server
#==========================
echo "Starting Passive Source Server and Receiver Server in $SEC_SIDE"
$sec_shell "$sec_getenv;cd $SEC_SIDE;$gtm_tst/com/RCVR.csh $main_repl_state $portno $start_time $other_qualifiers  >&! START_${start_time}.out ; grep -E '^RCVR_START_SUCCESSFUL' START_${start_time}.out" >&! START_${start_time}_RCVR_status.out # BYPASSOK grep
set rcvr_start = `cat START_${start_time}_RCVR_status.out`
if ( "RCVR_START_SUCCESSFUL" != "$rcvr_start" ) then
	echo "################################################################"
	echo "TEST-E-ERROR_RCVR, Error from RCVR.csh, test cannot continue! Check $SEC_SIDE/START_${start_time}.out"
	$sec_shell "cat $SEC_SIDE/START_${start_time}.out"
	echo "Check capture_ps_ipcs_ss_lsof_${start_time}.out for ps/ipcs/ss/lsof -i/env output." # BYPASSOK ps
	$sec_shell "cd $SEC_SIDE; ($gtm_tst/com/capture_ps_ipcs_ss_lsof.csh; env ; set) >>& capture_ps_ipcs_ss_lsof_${start_time}.out"
	echo "################################################################"
	exit 1
endif

$sec_shell "$sec_getenv ; date ; "'$ss' >& ss_remote.out_${start_time}
if ($status != 0) then
	echo "<$ss> command failed!"
	echo "Continuing without checking the connection using $ss!"
else
	set fail=1
	set wait_time = 300			# Wait for a maximum of 300 seconds
	set sleeptime = 1			# Start with 1 sec sleep between attempts
	set now_time = `date +%s`
	@ max_wait = $now_time + $wait_time
	while ($now_time <= $max_wait)
		# Checks whether connection is established using the port or, not
		# Check both ss and lsof output <good_connection_shutdown_by_RF_START>
		set fn = "rfstart.out_${start_time}_$now_time"
		# ss uses "ESTAB" to indicate established state, grep has been updated to look for it
		set establish_status = `$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/is_port_in_use.csh $portno $fn ; grep -qE 'ESTABLISHED|Establsh|ESTAB' {ss,lsof}_$fn || echo 1"` # BYPASSOK grep
		if ("" == "$establish_status") then
			set fail = 0
			break
		endif
		sleep $sleeptime
		set now_time = `date +%s`
		@ sleeptime = $sleeptime + 1	# Increase the sleep duration between attempts
	end

	if ($fail == 1) then
		echo "==============================================="
		echo "Failed to establish connection (using $ss)!"
		echo "Check *.out and *.log files in source/receiver!"
		echo "and *rfstart.out_* files for ss/lsof info"
		echo "Test cannot continue!"
		echo "==============================================="
		echo "$gtm_tst/com/RF_SHUT.csh"
		$gtm_tst/com/RF_SHUT.csh
		exit 2
	endif
endif

