#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
if (("ENCRYPT" == $test_encryption) && ("MULTISITE" == "$test_replic")) then
	# The test ships database from instance1 to instance2. Hence disable encryption if necessary.
	source $gtm_tst/com/encryption_disable_multihost.csh $tst_remote_host_ms_1 $tst_ver
endif

# Since this test creates a database on primary host, ships it across to secondary hosts, and performs MUPIP INTEG on it there, we
# need to ensure that the same symmetric key used on all machines.
if ("ENCRYPT" == $test_encryption) then
	source $gtm_tst/com/create_sym_key_for_multihost_use.csh
endif

setenv echoline 'echo ###################################################################'
## ## multisite_replic/errors -- REPLINSTDBMATCH, REPLINSTNOHIST, REPLINSTSTNDALN, PRIMARYNOTROOT, PRIMARYNOTROOT, REPLINSTSECMTCH, JNLPOOLACTIVATE, PRIMARYISROOT			###4###Kishore
## - Prepare replication for 5 servers:
cat << EOF
## Tests various error conditions
##   \$MULTISITE_REPLIC_PREPARE 5 (INST5 is not connected)
##          |--> INST2 --> INST3:
##   INST1 -|
##          |--> INST4
##

EOF
##
## - START INST2 INST3 PP
## - attempt some updates on INST2
##   RUN INST2 '$gtm_exe/mumps -run ...'
## 	--> We expect a SCNDDBNOUPD error since this is a propagating primary even though there isn't a root primary.

set supplarg = "$gtm_test_qdbrundown_parms"
if (2 == "$test_replic_suppl_type") set supplarg = "$supplarg -supplementary"

# This test does a lot of explicit receiver and source server restarts. Each such explicit restarts should be passed a valid tlsid
# and plaintextfallback qualifier if SSL/TLS should be supported for this test. Since this test verifies errors in the replication
# logs, it is not important with respect to SSL/TLS. So, disable SSL/TLS for this test.
setenv gtm_test_tls "FALSE"
$echoline
$MULTISITE_REPLIC_PREPARE 5
$gtm_tst/com/dbcreate.csh mumps
if ("ENCRYPT" == $test_encryption) then
	# The test does endiancvt on databases in save3 directory below. Retain just the dbname in $gtmcrypt_config file for this to work
	mv ${gtmcrypt_config} ${gtmcrypt_config}.orig
	sed 's|dat: "'$cwd'/|dat: "|' ${gtmcrypt_config}.orig >& $gtmcrypt_config
endif
# New test case introduced (not in the original test plan) to check if replication instace file format changes are caught.
# Source the test scrpit and print error message only if it fails.
source $gtm_tst/$tst/u_inref/replinstfmt_check.csh >&! replinstfmt_check.out
set error_status = $status
mv replinstfmt_check.out replinstfmt_check.outx
# The below four errors are expected. Anything other than these should be caught by the error catching mechanism.
$grep -vE "TEST-E-MULTISITE|YDB-E-REPLINSTFMT|JNL_ON-E-MUPIP|YDB-E-MUNOFINISH|TEST-E-REPLINSTNAME" replinstfmt_check.outx >&! replinstfmt_check.out
if ($error_status) then
	echo "TEST-F-REPLINSTFMT check failed. Check replinstfmt_check.outx"
endif
$MSR START INST2 INST3 PP
$MSR RUN INST2 "$gtm_tst/com/simpleinstanceupdate.csh 1 "
$msr_err_chk $msr_execute_last_out SCNDDBNOUPD

## - START INST1 INST2 RP
## - some updates on INST1
## - Try to activate the active source server
##   RUN INST2 '$MUPIP replic -source -activate -propagateprimary -instsecondary='$gtm_test_msr_INSTNAME[3]
## 	--> We expect a "Source Server already ACTIVE, not changing mode" error since the specified source server is
## 	    already an active source server.
## - Try to deactivate the passive source server
##   RUN INST2 '$MUPIP replic -source -deactivate -instsecondary='$gtm_test_msr_INSTNAME[1]
## 	--> We expect a "Source Server already PASSIVE, not changing mode" error since the specified source server is
## 	    already a passive source server.
## - Attempt to activate the passive source server on INST2
##   RUN SRC=INST2 RCV=INST1 '$MUPIP replic -source -activate -instsecondary=__RCV_INSTNAME__ -propagateprimary'
## 	--> We expect a ACTIVATEFAIL error since there is a receiver server attached to the jnlpool.
##TODO## The above 2 commands should be tested somewhere else
## - Start a passive source server from INST1 to INST4, then attempt to activate it as a propagateprimary.
##   RUN SRC=INST1 RCV=INST4 '$MUPIP replic -source -passive -instsecondary=__RCV_INSTNAME__'
##   RUN SRC=INST1 RCV=INST4 '$MUPIP replic -source -activate -instsecondary=__RCV_INSTNAME__ -propagateprimary -secondary=__RCV_HOST__:1234'
##   	--> We expect a PRIMARYISROOT error since INST1 is the rootprimary.
## 	Implementation note: the portno for INST4 will not be initialized at this stage, so we will use some dummy
## 	portno since the command will not actually connect.

$MSR START INST1 INST2 RP
$MSR RUN INST1 "$gtm_tst/com/simpleinstanceupdate.csh 10"
$MSR RUN SRC=INST2 RCV=INST3 "set msr_dont_chk_stat ; $MUPIP replic -source -activate -propagateprimary -instsecondary=__RCV_INSTNAME__ -secondary=__RCV_HOST__:__RCV_PORTNO__ >& err_src.tmp ; cat err_src.tmp"
#$MSR RUN INST2 "set msr_dont_chk_stat ; $MUPIP replic -source -deactivate -instsecondary=$gtm_test_msr_INSTNAME1"
#$MSR RUN SRC=INST2 RCV=INST1 "$MUPIP replic -source -activate -instsecondary=__RCV_INSTNAME__ -propagateprimary -secondary=__RCV_HOST__:__RCV_PORTNO__"
$MSR RUN SRC=INST1 RCV=INST4 '$MUPIP replic -source -start -passive -rootprimary -log=$gtm_test_msr_DBDIR1/pass.log -instsecondary=__RCV_INSTNAME__'
$MSR RUN SRC=INST1 RCV=INST4 'set msr_dont_chk_stat ; $MUPIP replic -source -activate -instsecondary=__RCV_INSTNAME__ -propagateprimary -secondary=__RCV_HOST__:1234'
$msr_err_chk $msr_execute_last_out PRIMARYISROOT

## - Do activate INST1 --> INST4 properly:
##   First initialize INST4's portno:
##   STARTRCV INST1 INST4
##   ACTIVATERP INST1 INST4
##   	--> This should succeed. Check by issuing a checkhealth command:
## 	    CHECKHEALTH INST1 INST4
## - attempt some updates on INST4
##   RUN INST4 '$gtm_exe/mumps -run ...'
## 	--> We expect a PRIMARYNOTROOT error since this is a propagating primary.
## - attempt to deactivate the source server on INST1, but as -propagateprimary
##   RUN SRC=INST1 RCV=INST2 '$MUPIP replic -source -deactivate -instsecondary=__RCV_INSTNAME__ -propagateprimary'
##   	--> We expect a PRIMARYISROOT error since INST1 is the root primary
## - attempt to deactivate the active source server on INST2, but as -rootprimary
##   RUN SRC=INST2 RCV=INST3 '$MUPIP replic -source -deactivate -instsecondary=__RCV_INSTNAME__ -rootprimary'
##   	--> We expect a PRIMARYNOTROOT error since INST2 is a propagating primary

$echoline
$MSR STARTRCV INST1 INST4
$MSR ACTIVATE INST1 INST4 RP
$MSR REFRESHLINK INST1 INST4
$MSR CHECKHEALTH INST1 INST4
$MSR RUN INST4 "set msr_dont_chk_stat; $gtm_tst/com/simpleinstanceupdate.csh 10"
$msr_err_chk $msr_execute_last_out SCNDDBNOUPD
$MSR RUN SRC=INST1 RCV=INST2 "set msr_dont_chk_stat; $MUPIP replic -source -deactivate -instsecondary=__RCV_INSTNAME__ -propagateprimary"
$msr_err_chk $msr_execute_last_out PRIMARYISROOT
$MSR RUN SRC=INST2 RCV=INST3 "set msr_dont_chk_stat; $MUPIP replic -source -deactivate -instsecondary=__RCV_INSTNAME__ -rootprimary >& err_src_shut.tmp; cat err_src_shut.tmp"
$msr_err_chk $msr_execute_last_out PRIMARYNOTROOT

## - save db, jnl, and instance file on INST1, INST2, and INST3 at time1
## - some more updates
## - try to re-create the instance file on INST1 and INST2
##   MULTISITE_REPLIC RUN INST1 '$MUPIP repl -instance_create -name=CANIRECREATE'
##   MULTISITE_REPLIC RUN INST2 '$MUPIP repl -instance_create -name=CANIRECREATE'
## 	--> We expect REPLINSTSTNDALN errors for both cases since the source and receiver servers would be
## 	    accessing the file instance files
## - stop replication on INST2:
##   STOP INST2
##   STOPSRC INST1 INST2
## - some more updates on INST1

# At this stage the replication configuration is
# INST1 --- INST2 --- INST3
#  |
#  |--- INST4
# The replication servers should be stopped before copying the databases and then restarted

# Note: REPLINSTSTNDALN error assert fails in dbg starting V63002 so disable that using white-box settings.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 134
$echoline
echo "Stop the servers - backup the files - restart the servers"
$MSR STOP INST1 INST2 ON
$MSR STOP INST1 INST4 ON
$MSR STOP INST2 INST3 ON

foreach inst (INST1 INST2 INST3)
	$MSR RUN $inst 'set msr_dont_trace ; $gtm_tst/com/backup_dbjnl.csh save1 "*.dat *.mjl* *.repl*" cp nozip'
end

$MSR START INST2 INST3 PP
$MSR START INST1 INST2 RP
$MSR START INST1 INST4 RP
$echoline

$MSR RUN INST1 "$gtm_tst/com/simpleinstanceupdate.csh 10"
$MSR RUN INST1 'set msr_dont_chk_stat ; $MUPIP replic -instance_create -name=CANIRECREATE'
$msr_err_chk $msr_execute_last_out REPLINSTSTNDALN
$MSR RUN INST2 'set msr_dont_chk_stat ; setenv gtm_white_box_test_case_enable 1 ; setenv gtm_white_box_test_case_number 134 ; $MUPIP replic -instance_create -name=CANIRECREATE'
$msr_err_chk $msr_execute_last_out REPLINSTSTNDALN
# Make sure the receiver gets all the updates before shutting the server down.
$MSR SYNC ALL_LINKS
$MSR STOP INST2
$MSR STOPSRC INST1 INST2 RESERVEPORT
$MSR RUN INST1 "$gtm_tst/com/simpleinstanceupdate.csh 10"

unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number

# At this stage the replication configuration is
# INST1 --- --- INST3 		#(INST1 has the source for INST2 running, INST2 is not running, INST3 has the reciever for INST2 running)
#  |
#  |--- INST4
# The replication servers should be stopped before copying the databases and then restarted

$echoline
echo "Stop the servers - backup the files - restart the servers"
$MSR STOP INST1 INST4 ON
$MSR STOPRCV INST2 INST3 ON
foreach inst (INST1 INST2 INST3)
	# leftover_ipc_cleanup_if_needed.csh needs to be called before copying databases in a quiescent state.
	$MSR RUN $inst 'set msr_dont_trace ; source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 ; $gtm_tst/com/backup_dbjnl.csh save2 "*.dat *.mjl* *.repl*" cp nozip'
end
$MSR START INST1 INST4
$MSR STARTRCV INST2 INST3
$echoline

cat << EOF
## - replace the instance file on INST2 with instance(time1)
## - attempt to restart replication on INST2
##   STARTRCV INST1 INST2
## 	--> We expect a REPLINSTDBMATCH error
## - attempt a rollback on INST2:
##   MULTISITE_REPLIC RUN RCV=INST2 '\$gtm_tst/com/mupip_rollback.csh -backward -fetchresync=__RCV_PORTNO__ -losttrans=fetch.glo "*"'
##  	--> We expect a REPLINSTDBMATCH error

EOF

$MSR RUN INST2 "set msr_dont_trace ; source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0" # do rundown if needed since a backed up mumps.repl file is copied over
$MSR RUN INST2 'cp save1/mumps.repl .'
$MSR STARTRCV INST1 INST2
get_msrtime
$MSR RUN INST2 "$msr_err_chk passive_$time_msr.log REPLINSTDBMATCH"
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-REPLINSTDBMATCH
$MSR RUN INST2 "$msr_err_chk START_$time_msr.out NOJNLPOOL"
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-NOJNLPOOL

# When the passive source server fails to start, the subsequent checkhealth statement will error with YDB-E-NOJNLPOOL
# Below backward rollback invocation is expected to fail. Therefore pass "-backward" explicitly to mupip_rollback.csh
# (and avoid implicit "-forward" rollback invocation that would otherwise happen by default.
$MSR RUN RCV=INST2 'set msr_dont_chk_stat ; $gtm_tst/com/mupip_rollback.csh -backward -fetchresync=__RCV_PORTNO__ -losttrans=fetch.glo "*" >&! rollback_REPLINSTDBMATCH.out'
$MSR RUN INST2 "$msr_err_chk rollback_REPLINSTDBMATCH.out REPLINSTDBMATCH MUNOACTION"
$gtm_tst/com/knownerror.csh $msr_execute_last_out "YDB-E-REPLINSTDBMATCH"
$gtm_tst/com/knownerror.csh $msr_execute_last_out "YDB-E-MUNOACTION"

$echoline

cat << EOF
## - Restore db from backup (time2) on INST2, cut new journal files
## - re-create the instance file on INST2
## - attempt to start receiver on INST2:
##   STARTRCV INST1 INST2
## 	--> We expect a REPLINSTNOHIST error, check that the source server detects the connection is closed, but is
## 	    still up and running itself.

EOF

# leftover_ipc_cleanup_if_needed.csh needs to be called before copying databases in a quiescent state.
$MSR RUN INST2 "set msr_dont_trace ; source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0"
$MSR RUN INST2 'cp save2/*.dat .; $MUPIP set $tst_jnl_str -region "*" >& set_jnl_on.out'
$MSR RUN INST2 "set msr_dont_trace ; $MUPIP replic -instance_create $supplarg -name=$gtm_test_msr_INSTNAME2 >& inst_create.out"
$MSR STARTSRC INST1 INST2
# We expect the receiver server to exit with a REPINSTNOHIST error.
# The $MSR STARTRCV done below will actually invoke a framework script RCVR.csh which in turn starts the receiver server
# and then does a checkhealth to ensure it is up and running. It is possible in rare cases that the receiver server
# exits (thereby cleaning up the receive pool) even before the checkhealth is attempted in RCVR.csh. In this case,
# the checkhealth will error out with YDB-E-NORECVPOOL message. Another possibility is that the receiver server is up
# and running but in the process of shutting down so we will see a "Update process crashed during shutdown" message.
# We do not want either of this to happen so we specifically ask RCVR.csh to skip the checkhealth by setting the
# environment variable gtm_test_repl_skiprcvrchkhlth. It is unset right afterwards.
setenv gtm_test_repl_skiprcvrchkhlth 1
$MSR STARTRCV INST1 INST2
unsetenv gtm_test_repl_skiprcvrchkhlth
get_msrtime
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log 'RCVR_$time_msr.log' -message REPLINSTNOHIST -duration 120 -waitcreation'
$MSR RUN INST2 "$msr_err_chk RCVR_$time_msr.log REPLINSTNOHIST"
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-REPLINSTNOHIST

$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP replic -source -shutdown -timeout=0 -instsecondary=__SRC_INSTNAME__  >&! passivesrc_shut_INST1INST2.out'
 #The above is done because, the receiver will be shut down but the passive server will be alive still. The next STARTRCV will complain.
$MSR REFRESHLINK INST1 INST2
$echoline

cat <<EOF
## - Test REPLINSTNOHIST on the receiver when there is no history on the receiver:
##   Change the resync and region seqno's on the receiver, and attempt to start a receiver (without the -updateresync
##   qualifier):
##   	--> We expect a REPLINSTNOHIST error, check that the source server detects the connection is closed, but is
## 	    still up and running itself.

EOF

$MSR RUN INST5 'set msr_dont_trace ; $MUPIP replic -instance_create '$supplarg' -name=$gtm_test_msr_INSTNAME5 >& err_create2.tmp; cat err_create2.tmp'
$MSR RUN RCV=INST5 SRC=INST1 '$gtm_tst/com/set_resync_and_reg_seqno.csh DEFAULT 10 setseqno.out'
$MSR STARTSRC INST1 INST5
setenv msr_dont_chk_stat
# We expect the receiver server to exit with a REPINSTNOHIST error.
# So do not do a checkhealth. See explaination above
setenv gtm_test_repl_skiprcvrchkhlth 1
$MSR STARTRCV INST1 INST5
setenv gtm_test_repl_skiprcvrchkhlth 0
get_msrtime
$MSR RUN INST5 '$gtm_tst/com/wait_for_log.csh -log 'RCVR_$time_msr.log' -message REPLINSTNOHIST -duration 120 -waitcreation'

$MSR RUN INST5 "$msr_err_chk RCVR_$time_msr.log REPLINSTNOHIST"
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-REPLINSTNOHIST

$MSR RUN RCV=INST5 SRC=INST1 'set msr_dont_trace ; $MUPIP replic -source -shutdown -timeout=0 -instsecondary=__SRC_INSTNAME__  >&! passivesrc_shut_INST1INST5.out'
 #The above is done because, the receiver will be shut down but the passive server will be alive still.
$MSR REFRESHLINK INST1 INST5
$MSR STOPSRC INST1 INST5


cat <<EOF
## - start receiver on INST2:
##   start source on INST1:
## - attempt to start replication between INST2 and INST3
## 	--> We expect a REPLINSTNOHIST error on the source server logs, but it should not die. Check that it is still
## 	    alive. since the history on INST3 is more detailed than that of INST2. The only
## 	    way to start replication on INST3 is by shipping the db from INST2 (or INST1), then re-create the instance
## 	    file. (done in the steps below)

EOF

$MSR STARTRCV INST1 INST2 "updateresync=save2/mumps.repl -initialize"
$MSR STOPRCV INST2 INST3
$MSR STARTRCV INST2 INST3
get_msrtime
set time_msr_rcv = $time_msr
$MSR STARTSRC INST2 INST3 PP
get_msrtime
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log 'SRC_$time_msr.log' -message REPLINSTNOHIST -duration 120 -waitcreation'

$MSR RUN INST2 "$msr_err_chk SRC_$time_msr.log REPLINSTNOHIST"
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-REPLINSTNOHIST

$MSR CHECKHEALTH INST2 INST3 SRC

$MSR RUN INST3 "$msr_err_chk RCVR_$time_msr_rcv.log REPLINSTNOHIST"

$MSR RUN RCV=INST3 SRC=INST2 'set msr_dont_trace ; $MUPIP replic -source -shutdown -timeout=0 -instsecondary=__SRC_INSTNAME__  >&! passivesrc_shut_INST2INST3.out'
 #The above is done because, the receiver will be shut down but the passive server will be alive still. The next STARTRCV will complain.
$MSR REFRESHLINK INST2 INST3
$MSR STOPSRC INST2 INST3
$echoline

## - Restore db from backup (time2) on INST3, cut new journal files
## - re-create the instance file on INST3
## - start receiver on INST3:
##   STARTRCV INST2 INST3 updateresync
##   start source on INST2:
##   STARTSRC INST2 INST3
## - perform one update on INST1 and see if it reaches INST3
##   $GTM << EOFGTM
##   set ^gbl="abcd"
##   halt
##   EOFGTM
##   SYNC ALL_LINKS
## - Stop replication on INST3
##   STOP INST2 INST3
## - stop replication on INST1:
##   STOP INST1
##   STOPRCV INST1 INST2
## - stop replication on INST2:
##   STOP INST2
##   STOPRCV INST2 INST3

$MSR RUN INST3 'cp save2/*.dat . ; $MUPIP set $tst_jnl_str -region "*" >&! set_jnl_on.out'
$MSR RUN INST3 "set msr_dont_trace ; $MUPIP replic -instance_create $supplarg -name=$gtm_test_msr_INSTNAME3 >&! inst_create.out"
$MSR STARTRCV INST2 INST3 "updateresync=save2/mumps.repl -initialize"
$MSR STARTSRC INST2 INST3 PP
$GTM << EOFGTM
set ^gbl="abcd"
halt
EOFGTM
$MSR SYNC ALL_LINKS
$MSR STOP INST2 INST3
$MSR STOP INST1
$MSR STOPRCV INST1 INST2
$echoline

cat << EOF
## - replace the instance file on INST1 with instance(time1)
## - attempt to restart INST1 --> INST2:
##   STARTRCV INST1 INST2
##   STARTSRC INST1 INST2
## 	--> We expect a REPLINSTDBMATCH error

EOF

# Before destroying the instance file, take a backup of the instance file.
$MSR RUN INST1 'mkdir save3 ; cp *.repl save3/'
$MSR RUN INST1 'cp save1/*.repl .'
$MSR STARTRCV INST1 INST2
$MSR STARTSRC INST1 INST2
get_msrtime
$gtm_tst/com/wait_for_log.csh -log $gtm_test_msr_DBDIR1/SRC_$time_msr.log -message REPLINSTDBMATCH -duration 120 -waitcreation
$msr_err_chk $gtm_test_msr_DBDIR1/SRC_$time_msr.log REPLINSTDBMATCH
$msr_err_chk $gtm_test_msr_DBDIR1/START_$time_msr.out NOJNLPOOL
# When the source server fails to start, the subsequent checkhealth statement will error with YDB-E-NOJNLPOOL
$MSR STOPRCV INST1 INST2

## - save db, jnl, and instance file on INST1 at time3 (note instance file save into "save3" is already done a few steps ago)
## - re-create the instance file on INST1
## - attempt a rollback on INST2:
##   STARTSRC INST1 INST2
##   MULTISITE_REPLIC RUN RCV=INST2 '$gtm_tst/com/mupip_rollback.csh -backward -fetchresync=__RCV_PORTNO__ -losttrans=fetch.glo "*"'
## 	--> We expect a REPLINSTNOHIST error.  check that the source server detects the connection is closed, but is
## 	    still up and running itself.

$MSR RUN INST1 'set msr_dont_trace ; $MUPIP replic -instance_create '$supplarg' -name=$gtm_test_msr_INSTNAME1'

if ( "MULTISITE" == $test_replic ) then
	set myendianness = $gtm_endian
	$MSR RUN INST2 'set msr_dont_trace ; source $gtm_tst/com/set_gtm_machtype.csh ; echo $gtm_endian' >&! remote_endian.out
	set theirendianness=`cat remote_endian.out`
	# if the machines are of different endianness, will need to convert database before sending.
	# just to make sure convert will work, first bring database up to latest level.
	if ( "$myendianness" != "$theirendianness" ) then
		$MUPIP reorg -upgrade -reg "*" >&! mupip_upgrade.out
	endif
endif

# leftover_ipc_cleanup_if_needed.csh needs to be called before copying databases in a quiescent state.
$MSR RUN INST1 'set msr_dont_trace ; source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 ; $gtm_tst/com/backup_dbjnl.csh save3 "*.dat *.mjl* *key* *.cfg" cp nozip'

if ( "MULTISITE" == $test_replic ) then
	# if the machines are of different endianness, convert database before sending.
	if ( "$myendianness" != "$theirendianness" ) then
		cd save3
		echo y | $MUPIP endiancvt *.dat >&! mupip_endiancvt.out
		cd -
	endif
endif

$MSR RUN INST2 "set msr_dont_trace ; source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0"
$MSR RUN SRC=INST1 RCV=INST2 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/save3/*.{dat,repl} _REMOTEINFO___RCV_DIR__/'
$MSR RUN INST2 'mv mumps.repl inst1_save3_mumps.repl ; mv mumps.mjl mumps.mjl.bak'
$MSR RUN INST2 'set msr_dont_trace ; $MUPIP replic -instance_create '$supplarg' -name=$gtm_test_msr_INSTNAME2 ; setenv test_jnl_on_file 1 ; $gtm_tst/com/jnl_on.csh $test_remote_jnldir -replic=on'
$MSR STARTRCV INST1 INST2 "updateresync=inst1_save3_mumps.repl -initialize"
$MSR STARTSRC INST1 INST2
$MSR STOP INST1 INST2
setenv gtm_test_instsecondary "-instsecondary=SOMEWRONGNAME"
$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_msr_src = $time_msr
$MUPIP replic -editinstance -show mumps.repl |& tee instancefile_3.out | $grep "Secondary Instance Name"
$MSR STARTRCV INST1 INST2
$gtm_tst/com/wait_for_log.csh -log $gtm_test_msr_DBDIR1/SRC_$time_msr_src.log -message REPLINSTSECMTCH -duration 120 -waitcreation
$msr_err_chk $gtm_test_msr_DBDIR1/SRC_$time_msr_src.log REPLINSTSECMTCH
if ($status) then
	# REPLINSTSECMTCH error was not seen in the source server log. Shut down the server just in case it didn't exit
	# If the server exited without REPLINSTSECMTCH, the below command will fail. Since this is anyway a failure case block
	# no need to check the health of the server before shutting it down.
	setenv gtm_test_instsecondary "-instsecondary=SOMEWRONGNAME"
	echo "# Trying to shut down the source server in INST1. Just in case it hasn't died by itself"
	$MSR STOPSRC INST1 INST2
endif
$MSR REFRESHLINK INST1 INST2
$MSR STOP ALL_LINKS
$gtm_tst/com/dbcheck.csh -extract INST1 INST2
