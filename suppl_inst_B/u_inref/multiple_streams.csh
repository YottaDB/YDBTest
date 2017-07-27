#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# INST4 receiver server was never "officially" started in the test. So, there isn't any mumps.repl file available in INST4.
# If $gtm_custom_errors is set, then the INTEG on INST4 will error out with FTOKERR/ENO2. To avoid this, unsetenv gtm_custom_errors.
# It is done here instead of just before dbcheck.csh because, the env.txt at the beginning of the test is used to set the environment till the end
unsetenv gtm_custom_errors
$MULTISITE_REPLIC_PREPARE 2 2

$gtm_tst/com/dbcreate.csh mumps  5 125 1000 1024 4096 1024 4096 >&! dbcreate.out

# 30) Test that a receiver server on P (supplementary root primary) that connects to different unique non-supplementary streams
#        issues an error the moment it connects to the second stream. This way we prevent mixing of multiple streams in the same receive pool.
# Since it requires abnormal MSR activities, most of the commands are run manually
setenv needupdatersync 1
$MSR STARTSRC INST3 INST4 RP
set portno45 = `$MSR RUN INST4 'set msr_dont_trace ; cat portno'`
$MSR START INST1 INST3 RP
get_msrtime
set portno14 = `$MSR RUN INST3 'set msr_dont_trace ; cat portno'`
$gtm_tst/com/simplegblupd.csh -instance INST1 -count 5 >&! INST1_simplegblupd.out
$MSR SYNC INST1 INST3
# At this point INST1-INST3 is running. Now Stop only INST1 and try connecting INST2-INST3
$MSR STOPSRC INST1 INST3
$MSR RUN INST2 'set msr_dont_trace ; $MUPIP replic -instance_create -name=$gtm_test_cur_pri_name '$gtm_test_qdbrundown_parms' ; $gtm_tst/com/jnl_on.csh $test_jnldir -replic=on'
$MSR RUN SRC=INST2 RCV=INST3 '$MUPIP replic -source -start -log=SRC_INST2INST3.log -secondary=__RCV_HOST__:__RCV_PORTNO__ -instsecondary=__RCV_INSTNAME__'
# As soon as INST2 comes up and talks to INST3, expect rcvr of INST3 to error out with the below
# %GTM-E-INSUNKNOWN, Supplementary Instance INSTANCE3 has no instance definition for non-Supplementary Instance INSTANCE2
$MSR RUN INST3 '$gtm_tst/com/wait_for_log.csh -log RCVR_'$time_msr'.log -message INSUNKNOWN'
$MSR RUN INST3 "$msr_err_chk RCVR_$time_msr.log INSUNKNOWN"
$gtm_tst/com/knownerror.csh $msr_execute_last_out INSUNKNOWN
$MSR REFRESHLINK INST1 INST3
$MSR RUN INST2 '$MUPIP backup -replinstance=INST2bak.repl >&! INST2_repl_backup.out'
$MSR RUN SRC=INST2 RCV=INST3 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/INST2bak.repl  _REMOTEINFO___RCV_DIR__/INST2bak.repl'
# Now Restart INST3 and try connecting it to INST2. It should be successful
$MSR RUN RCV=INST3 SRC=INST1 'set msr_dont_chk_stat ; $MUPIP replic -receiv -shutdown -timeout=0 >&! SHUT_receiver.log'
$MSR RUN SRC=INST3 RCV=INST4 '$MUPIP replic -source -shutdown -instsecondary=__RCV_INSTNAME__ -timeout=0 >&! SHUTSRC_INST3INST4_1.out'
$MSR RUN SRC=INST3 RCV=INST4 'set msr_dont_trace ; $MUPIP replic -source -start -log=SRC_INST3INST4.log -secondary=__RCV_HOST__:'$portno45' -instsecondary=__RCV_INSTNAME__ >&! STARTSRC_INST3INT5.out'
$MSR RUN INST3 'set msr_dont_trace ; $MUPIP replic -receiv -start -listen='$portno14' -log=RCVR_INST2INT4.log -buf=$tst_buffsize -updateresync=INST2bak.repl -initialize'
$MSR REFRESHLINK INST2 INST3
$gtm_tst/com/simplegblupd.csh -instance INST2 -count 5 >&! INST2_simplegblupd.out
$MSR SYNC INST2 INST3
# Shutdown everything.
$MSR RUN RCV=INST3 SRC=INST2 '$MUPIP replic -receiv -shutdown -timeout=0 >&! SHUTRCV_INST2INT4.out '
$MSR RUN SRC=INST3 RCV=INST4 '$MUPIP replic -source -shutdown -instsecondary=__RCV_INSTNAME__ -timeout=0 >&! SHUTSRC_INST3INST4_2.out'
$MSR RUN SRC=INST2 RCV=INST3 '$MUPIP replic -source -shutdown -instsecondary=__RCV_INSTNAME__ -timeout=0 >&! SHUTSRC_INST2INT4.out'
$MSR REFRESHLINK INST2 INST3
$MSR REFRESHLINK INST3 INST4

# The instances don't syncup so -extract shouldn't be given
$gtm_tst/com/dbcheck.csh
