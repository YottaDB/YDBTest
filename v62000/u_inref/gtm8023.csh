#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# The test needs a passive source server in INST2 with INST1 as secondary.
# test_replic_suppl_type=1 starts dummy supplementary source server and not a passive source server
if (1 == $test_replic_suppl_type) then
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif
setenv acc_meth			"BG"	# The test plays with "Dirty Global Buffers"
setenv gtm_test_jnlfileonly	0	# With a huge flush_time, nothing would be replicated from journal files.
unsetenv gtm_test_jnlpool_sync		# ditto
setenv gtm_test_updhelpers	0	# As described below, we don't want extra flushing.

alias knownerror 'mv \!:1 {\!:1}x ; $grep -vE "\!:2" {\!:1}x >&! \!:1 '

$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/com/dbcreate.csh mumps 1 125 256 512 -g=256

$MSR START INST1 INST2 RP
$MSR START INST2 INST3 PP
# Increase the flush-timer to reduce the rate at which dirty buffers are flushed to disk.
# This is to ensure at least one dirty buffer exists. Else dse change -cache adjustment would be meaningless.
$MSR RUN INST2 '$MUPIP set -flush_time=01:00:00:00 -region DEFAULT'

$gtm_exe/mumps -run %XCMD 'for i=1:1:10000 set ^global(i)=$j(i,200) set ^noreorg(i)=$j(i,220)'
$MSR SYNC ALL_LINKS
$MSR RUN INST2 '$gtm_tst/$tst/u_inref/gtm8023_bgprocess.csh >&! bgprocess.out &' >&! inst2_bgprocess.out
set bgprocesspid = `$tst_awk '{pid=$NF} END {print pid}' inst2_bgprocess.out`
$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/com/wait_for_log.csh -log bgprocess.started -waitcreation"

# Now that all the background processes have started, activate the passive server.
$MSR STOPSRC INST1 INST2

# Case 1 : With both receiver server and update process running, activate should fail
echo "# Expect ACTIVATEFAIL error, as receiver and update process is still running in INST2"
setenv msr_dont_chk_stat
$MSR ACTIVATE INST2 INST1
get_msrtime
knownerror $msr_execute_last_out "ACTIVATEFAIL"
$MSR RUN INST2 "$msr_err_chk ACTIVATE_${time_msr}.out ACTIVATEFAIL"
knownerror $msr_execute_last_out "ACTIVATEFAIL"
unsetenv msr_dont_chk_stat
# ACTIVATE would have reserved a port, but not used. Clean it up manually
$gtm_tst/com/portno_release.csh `cat portno`

# Case 2 : Even with just the update process running, activate should fail
echo "# Kill only the receiver server and let the update process run"
$MSR RUN INST2 'set msr_dont_trace ; $MUPIP replicate -receiv -checkhealth >&! rcvcheckhealth.out ; $grep "Receiver server" rcvcheckhealth.out' >&! inst2_rcvr_pid.out
setenv pidrcvr `$tst_awk '/Receiver server is alive/ {print $2}' inst2_rcvr_pid.out`
$MSR RUN INST2 "set msr_dont_trace ; $kill9 $pidrcvr"
setenv msr_dont_chk_stat
echo "# Expect ACTIVATEFAIL error, as update process is still running in INST2"
$MSR ACTIVATE INST2 INST1
get_msrtime
knownerror $msr_execute_last_out "ACTIVATEFAIL"
$MSR RUN INST2 "$msr_err_chk ACTIVATE_${time_msr}.out ACTIVATEFAIL"
knownerror $msr_execute_last_out "ACTIVATEFAIL"
unsetenv msr_dont_chk_stat
# ACTIVATE would have reserved a port, but not used. Clean it up manually
$gtm_tst/com/portno_release.csh `cat portno`

# Case 3 : With both reciever server and update process shut down, activate should succeed
echo "# Restart the receiver server to have a clean shutdown"
$MSR RUN INST2 '$MUPIP replic -receiver -start -listen=__SRC_PORTNO__ -log=receiver_restart.log'
echo "# Shutdown receiver and activate - Should work"
$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP replic -receiv -shutdown -timeout=0 >& INST1INST2_rcv_shut.out'
$MSR REFRESHLINK INST1 INST2
$MSR ACTIVATE INST2 INST1
$MSR STARTRCV INST2 INST1

echo "# INST2 is now primary - Do an update and it should succeed"
$MSR RUN INST2 '$gtm_exe/mumps -run %XCMD "set ^nowprimary=1"'

echo "# Signal all the background jobs to exit and wait for them to die"
$MSR RUN INST2 "set msr_dont_trace ; touch bkgrndjobs.stop ; $gtm_tst/com/wait_for_proc_to_die.csh $bgprocesspid"

# Check for expected errors in the background job (gtm8023__bgprocess.csh)
echo "# The below two errors should have happened. Make sure they did"
# gtm8023.m should have encountered GTM-E-SCNDDBNOUPD attempting to do an update when the instance is secondary
$MSR RUN INST2 "$msr_err_chk bgmumps1.out SCNDDBNOUPD"
knownerror $msr_execute_last_out "SCNDDBNOUPD"

# gtm8023_bgprocess.csh makes sure zwrite ^noreorg does NOT happen. i.e wait for ^noreorg(1) should have failed
# Searching for TEST-E-NOTFOUND would result in the framework error catching mechanism find that in multisite_replic.log.
# So search only for E-NOTFOUND
$MSR RUN INST2 "$msr_err_chk bgprocess.out E-NOTFOUND"
knownerror $msr_execute_last_out "E-NOTFOUND"

$gtm_tst/com/dbcheck.csh -extract
