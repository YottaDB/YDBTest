#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test basic supplementary replication errors
#
# Disable settings that do not work with MSR and prior versions
source $gtm_tst/com/disable_settings_msr_priorver.csh spanning_regions triggers

$MULTISITE_REPLIC_PREPARE 3 3

setenv prior_ver `$gtm_tst/com/random_ver.csh -gte V51000 -lt V54003`
if ("$prior_ver" =~ "*-E-*") then
	echo "No prior versions available: $prior_ver"
	exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
echo "$prior_ver" > priorver.txt
cp msr_instance_config.txt msr_instance_config.bak
$tst_awk '{if (("INST2" == $1) && ("VERSION:" == $2)) {sub("'$tst_ver'","'$prior_ver'")} ; if (("INST2" == $1) && ("IMAGE:" == $2)) sub("dbg","pro") ; print }' msr_instance_config.txt >&! msr_instance_config.txt1
mv msr_instance_config.txt1 msr_instance_config.txt
$MULTISITE_REPLIC_ENV

# Disable gtm_test_spanreg for INST2 since it uses an older version that does not support spanning regions
$MSR RUN INST2 "set msr_dont_trace ; echo setenv gtm_test_spanreg 0 >> env_supplementary.csh"

$gtm_tst/com/dbcreate.csh mumps  5 125 1000 1024 4096 1024 4096 >&! dbcreate.out

# 26) Test scenario where receiver is pre-V54003 and uses -UPDATERESYNC and source is post-V54003.
#        Ensure source can handle the START_FLAGS_UPDATERESYNC bit even if it normally does not expect it.
echo "# If a pre V5.5-000 receiver uses -UPDATERESYNC and connects to post V5.5-000 source no error is thrown"
$MSR STARTSRC INST1 INST2
$MSR STARTRCV INST1 INST2 'updateresync'
$MSR SYNC INST1 INST2
$MSR STOP INST1 INST2
# Since the instances are reused below, move the traces out of main directory
$MSR RUN INST1 'set msr_dont_trace ; mkdir test26 ; mv *.repl test26'
$MSR RUN INST2 'set msr_dont_trace ; mkdir test26 ; mv *.repl test26'

# 40) If a passive source server is started up first in a supplementary instance without the -updok qualifier. And then let us
#        say a receiver server and update process is started in that instance but is waiting for a connection with some primary.
#        If the source server is later ACTIVATEd on-the-fly, the activation should NOT be allowed in case processes (receiver
#        and/or update process corresponding to originating primaries etc.) are still accessing the instance.
echo "# If a supplementary instance passive source is started without -updok, activation should NOT be allowed if other processes are accessing the instance"
$MSR RUN INST4 '$MUPIP replic -instance_create -name=$gtm_test_msr_INSTNAME4 -supplementary ; $gtm_tst/com/jnl_on.csh $test_jnldir -replic=on'
$MSR RUN INST4 '$MUPIP replic -source -start -passive -log=passive_INST4.log -instsecondary=$gtm_test_msr_INSTNAME1'
setenv port_41 `$MSR RUN INST4 'set msr_dont_trace ; $gtm_tst/com/portno_acquire.csh'`
$MSR RUN RCV=INST4 SRC=INST1 "set msr_dont_trace ; $MUPIP replic -receiv -start -listen=$port_41 -log=RCVR_INST4INST1.log -updateresync"
echo "# Now activate the passive source server"
$MSR RUN RCV=INST4 SRC=INST1 'set msr_dont_chk_stat ; $MUPIP replic -source -activate -secondary=__RCV_HOST__:12345 -instsecondary=$gtm_test_msr_INSTNAME1'
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-ACTIVATEFAIL
$MSR RUN INST4 '$MUPIP replic -receiver -shutdown -timeout=0 >&! rcvr_shut.out'
$MSR RUN INST4 '$MUPIP replic -source -shutdown -timeout=0 >&! passive_shut.out'
$MSR RUN INST4 'set msr_dont_trace ; mkdir test40 ; mv *.repl test40'
$MSR RUN INST4 "set msr_dont_trace ; $gtm_tst/com/portno_release.csh $port_41"

# NOTE : When receiver server exits with an error in a lot of cases below, the updateprocess would still be running.
#        If MSR framework is used to shutdown the rcvr side, due to the abnormal exit of receiver, there would be a bunch of errors reported (both by the script and by MSR framework)
#	 To avoid the error messages, we manually shut the receiver server and instruct MSR framework to not check for status
#
# UPDSYNCINSTFILE
# %YDB-E-UPDSYNCINSTFILE, Error with instance file name specified in UPDATERESYNC qualifier
# %YDB-I-TEXT, Source side is >= V5.5-000 implies -UPDATERESYNC needs a value specified

echo "# Expect rcvr to exit with YDB-E-UPDSYNCINSTFILE when no value is specified to -updateresync"
$MSR STARTSRC INST4 INST5 RP
setenv gtm_test_repl_skiprcvrchkhlth 1 ; $MSR STARTRCV INST4 INST5 'updateresync' >&! STARTRCV_INST4_INST5_updateresync.outx ; unsetenv gtm_test_repl_skiprcvrchkhlth
get_msrtime
$MSR RUN INST5 '$gtm_tst/com/wait_for_log.csh -log 'RCVR_$time_msr.log' -message UPDSYNCINSTFILE -duration 120 -waitcreation'
$MSR RUN INST5 "$msr_err_chk RCVR_$time_msr.log UPDSYNCINSTFILE"
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-UPDSYNCINSTFILE
echo "# The receiver would have exited with the above error. Manually shutdown the update process and passive server"
$MSR RUN INST5 'set msr_dont_chk_stat ;$MUPIP replic -receiver -shutdown -timeout=0 >&! updateproc_shut_IST4INST5.out'
$MSR RUN RCV=INST5 SRC=INST4 '$MUPIP replic -source -shutdown -timeout=0 -instsecondary=__SRC_INSTNAME__ >&! passivesrc_shut_INST4INST5.out'
$MSR REFRESHLINK INST4 INST5
$MSR STOPSRC INST4 INST5

# REPL2OLD
# %YDB-E-REPL2OLD, Instance INSTANCE2 uses a GT.M version that does not support connection with the current version on instance INSTANCE4
echo "# Expect the rcvr to exit with YDB-E-REPL2OLD if it attempts to connect to pre V5.5-000 source"
$MSR STARTSRC INST2 INST4 RP
setenv gtm_test_repl_skiprcvrchkhlth 1 ; $MSR STARTRCV INST2 INST4 >&! STARTRCV_INST2_INST4.outx ; unsetenv gtm_test_repl_skiprcvrchkhlth
get_msrtime
$MSR RUN INST4 '$gtm_tst/com/wait_for_log.csh -log 'RCVR_$time_msr.log' -message REPL2OLD -duration 120 -waitcreation'
$MSR RUN INST4 "$msr_err_chk RCVR_$time_msr.log REPL2OLD"
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-REPL2OLD
echo "# The receiver would have exited with the above error. Manually shutdown the update process and passive server"
$MSR RUN INST4 'set msr_dont_chk_stat ; $MUPIP replic -receiver -shutdown -timeout=0 >&! updateproc_shut_IST2INST4.out'
$MSR RUN RCV=INST4 SRC=INST2 '$MUPIP replic -source -shutdown -timeout=0 -instsecondary=__SRC_INSTNAME__ >&! passivesrc_shut_INST2INST4.out'
$MSR REFRESHLINK INST2 INST4
$MSR STOPSRC INST2 INST4

echo "# Expect the src to exit with YDB-E-REPL2OLD if it attempts to connect to pre V5.5-000 receiver"
$MSR STARTRCV INST4 INST2
setenv gtm_test_repl_skipsrcchkhlth 1 ; $MSR STARTSRC INST4 INST2 RP >&! STARTSRC_INST4_INST2_RP.outx ; unsetenv gtm_test_repl_skipsrcchkhlth
get_msrtime
$MSR RUN INST4 '$gtm_tst/com/wait_for_log.csh -log 'SRC_$time_msr.log' -message REPL2OLD -duration 120 -waitcreation'
$MSR RUN INST4 "$msr_err_chk SRC_$time_msr.log REPL2OLD"
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-REPL2OLD
$MSR RUN SRC=INST4 RCV=INST2 'set msr_dont_trace ; set msr_dont_chk_stat ; $MUPIP replic -source -checkhealth -instsecondary=__RCV_INSTNAME__ >& checkhealth42.outx ; $grep "Source server is alive" checkhealth42.outx' >&! INST4_INST2_SRC.out
set pid42 = `$tst_awk '/Source server is alive/ { print $2}' INST4_INST2_SRC.out`
if ("" != "$pid42") then
	$MSR RUN INST4 "set msr_dont_trace ; $gtm_tst/com/wait_for_proc_to_die.csh $pid42"
endif
$MSR REFRESHLINK INST4 INST2
$MSR STOPRCV INST4 INST2

# Run argumentless MUPIP RUNDOWN after the source server on INST4 errored out with REPL2OLD error (to test GTM-8156)
# Without GTM-8156, the next source server startup on INST4 would issue REPLREQROLLBACK error if gtm_custom_errors env var was set
$MUPIP RUNDOWN >& mupip_rundown.outx

# SECNOTSUPPLEMENTARY
# %YDB-E-SECNOTSUPPLEMENTARY, INSTANCE4 is a Supplementary Instance and so cannot act as a source to non-Supplementary Instance INSTANCE1
echo "# Expect src of INST4 which is supplementary to exit with YDB-E-SECNOTSUPPLEMENTARY when it tries to connect to rcvr of INST1, which is non-supplementary"
$MSR STARTRCV INST4 INST1
setenv gtm_test_repl_skipsrcchkhlth 1 ; $MSR STARTSRC INST4 INST1 RP >&! STARTSRC_INST4_INST1_RP.outx ; unsetenv gtm_test_repl_skipsrcchkhlth
get_msrtime
$MSR RUN INST4 '$gtm_tst/com/wait_for_log.csh -log 'SRC_$time_msr.log' -message SECNOTSUPPLEMENTARY -duration 120 -waitcreation'
$MSR RUN INST4 "$msr_err_chk SRC_$time_msr.log SECNOTSUPPLEMENTARY"
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-SECNOTSUPPLEMENTARY
$MSR RUN SRC=INST4 RCV=INST1 'set msr_dont_trace ; set msr_dont_chk_stat ; $MUPIP replic -source -checkhealth -instsecondary=__RCV_INSTNAME__ >& checkhealth41.outx ; $grep "Source server is alive" checkhealth41.outx' >&! INST4_INST1_SRC.out
set pid41 = `$tst_awk '/Source server is alive/ { print $2}' INST4_INST1_SRC.out`
if ("" != "$pid41") then
	$MSR RUN INST4 "set msr_dont_trace ; $gtm_tst/com/wait_for_proc_to_die.csh $pid41"
endif
$MSR REFRESHLINK INST4 INST1
$MSR STOPRCV INST4 INST1

# SUPRCVRNEEDSSUPSRC
# %YDB-E-SUPRCVRNEEDSSUPSRC, Instance INSTANCE5 is not configured to perform local updates so it cannot act as a receiver for non-Supplementary Instance INSTANCE1
echo "# Expect rcvr of INST5 which is supplementary, but no -updok server to exit with YDB-E-SUPRCVRNEEDSSUPSRC when it tries to connect to src of INST1"
$MSR STARTSRC INST1 INST5
setenv gtm_test_repl_skiprcvrchkhlth 1 ; $MSR STARTRCV INST1 INST5 >&! STARTRCV_INST1_INST5.outx ; unsetenv gtm_test_repl_skiprcvrchkhlth
get_msrtime
$MSR RUN INST5 '$gtm_tst/com/wait_for_log.csh -log 'RCVR_$time_msr.log' -message SUPRCVRNEEDSSUPSRC -duration 120 -waitcreation'
$MSR RUN INST5 "$msr_err_chk RCVR_$time_msr.log SUPRCVRNEEDSSUPSRC"
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-SUPRCVRNEEDSSUPSRC
echo "# The receiver would have exited with the above error. Manually shutdown the update process and passive server"
$MSR RUN INST5 'set msr_dont_chk_stat ; $MUPIP replic -receiver -shutdown -timeout=0 >&! updateproc_shut_IST1INST5.out'
$MSR RUN RCV=INST5 SRC=INST1 '$MUPIP replic -source -shutdown -timeout=0 -instsecondary=__SRC_INSTNAME__ >&! passivesrc_shut_INST1INST5.out'
$MSR REFRESHLINK INST1 INST5
$MSR STOPSRC INST1 INST5

# NOSUPPLSUPPL
# %YDB-E-NOSUPPLSUPPL, Instance INSTANCE4 is configured to perform local updates so it cannot receive from Supplementary Instance INSTANCE6
echo "# Expect RCVR of INST4 which is a supplementary instance to error out with YDB-E-NOSUPPLSUPP, when it connects to INST6 which is also a supplementary instance"
$MSR STARTSRC INST6 INST5 RP
$MSR STARTSRC INST4 INST6 RP
setenv gtm_test_repl_skiprcvrchkhlth 1 ; $MSR STARTRCV INST4 INST6 >&! STARTRCV_INST4_INST6.outx; unsetenv gtm_test_repl_skiprcvrchkhlth
get_msrtime
$MSR RUN INST6 '$gtm_tst/com/wait_for_log.csh -log 'RCVR_$time_msr.log' -message NOSUPPLSUPP -duration 120 -waitcreation'
$MSR RUN INST6 "$msr_err_chk RCVR_$time_msr.log NOSUPPLSUPP"
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-NOSUPPLSUPP
$MSR RUN INST6 'set msr_dont_chk_stat ; $MUPIP replic -receiver -shutdown -timeout=0 >&! updateproc_shut_INST6INST4.out'
$MSR STOPSRC INST6 INST5
$MSR REFRESHLINK INST4 INST6
$MSR STOPSRC INST4 INST6


# REPLINSTSECLEN
# 14) Test with 16-byte, 15-byte and < 15-byte nodenames. This will test MAX_NODENAME_LEN sized arrays.
# Here we test 16 byte. < 15 byte and 15-byte are randomly choosen for the MSR framework and supplementary subtest respectively.
echo "# Expect YDB-E-REPLINSTSECLEN if the length of -instsecondary is >15 bytes"
cp msr_instance_config.txt msr_instance_config.bak1
$tst_awk '{ sub("INSTANCE","MYNAMEISROLANDE") ; print }' msr_instance_config.txt >&! msr_instance_config.txt1
\mv msr_instance_config.txt1 msr_instance_config.txt
$MULTISITE_REPLIC_ENV
setenv gtm_test_repl_skipsrcchkhlth 1
$MSR STARTSRC INST1 INST2 RP >&! STARTSRC_INST1_INST2_RP.outx
get_msrtime
$MSR RUN INST1 "$msr_err_chk START_$time_msr.out REPLINSTSECLEN MUPCLIERR"
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-REPLINSTSECLEN
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-MUPCLIERR
# The above STARTSRC would have reserved a port in INST2 and wouldn't have removed it.
$MSR RUN INST2 'set msr_dont_trace ; source $gtm_tst/com/portno_release.csh'
$MSR STARTSRC INST4 INST5 RP >&! STARTSRC_INST4_INT5_RP.outx
get_msrtime
$MSR RUN INST4 "$msr_err_chk START_$time_msr.out REPLINSTSECLEN MUPCLIERR"
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-REPLINSTSECLEN
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-MUPCLIERR
unsetenv gtm_test_repl_skipsrcchkhlth
# The above STARTSRC would have reserved a port in INST5 and wouldn't have removed it.
$MSR RUN INST5 'set msr_dont_trace ; source $gtm_tst/com/portno_release.csh'
cp msr_instance_config.bak1 msr_instance_config.txt
$MSR REFRESHLINK INST1 INST2
$MSR REFRESHLINK INST4 INST5
$MULTISITE_REPLIC_ENV

# INSROLECHANGE
echo "# Expect YDB-E-INSROLECHANGE below"
$MSR START INST1 INST3 RP
$gtm_tst/com/simplegblupd.csh -instance INST1 -count 5
$MSR STOP INST1 INST3
$MSR RUN INST3 '$MUPIP replic -edit -change -offset=0x000000AC -size=4 -value=0x1 mumps.repl'
$MSR STARTSRC INST3 INST4 RP
$MSR STARTSRC INST1 INST3 RP
setenv gtm_test_repl_skiprcvrchkhlth 1 ; $MSR STARTRCV INST1 INST3 >&! STARTRCV_INST1_INST3.outx ; unsetenv gtm_test_repl_skiprcvrchkhlth
get_msrtime
$MSR RUN INST3 '$gtm_tst/com/wait_for_log.csh -log 'RCVR_$time_msr.log' -message INSROLECHANGE -duration 120 -waitcreation'
$MSR RUN INST3 "$msr_err_chk RCVR_$time_msr.log INSROLECHANGE"
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-INSROLECHANGE
echo "# The receiver would have exited with the above error. Manually shutdown the update process"
$MSR RUN INST3 'set msr_dont_chk_stat ; $MUPIP replic -receiver -shutdown -timeout=0 >&! updateproc_shut_IST1INST5.out'
$MSR REFRESHLINK INST1 INST3
$MSR STOPSRC INST1 INST3
$MSR STOPSRC INST3 INST4

# None of the instances are expected to be in sync. No -extract
$gtm_tst/com/dbcheck.csh >&! dbcheck.out
