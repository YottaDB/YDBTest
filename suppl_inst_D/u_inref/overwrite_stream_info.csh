#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
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

# 10) -updateresync should NOT error out if the stream info is already present in the instance file. Instead it should OVERWRITE
#	the stream info (including the stream seqno) with the input. Need a test for this.
#
#	Let A->P connection exist and A replicate 100 seqnos to P. Later, stop A->P connection and do 100 more updates to A.
#	Now take a backup of A and load it to P and then start P with updateresync. It should work without errors.
#	You should see 200 as the stream seqno of the A stream when you do a mupip replic -edit -show mumps.repl P.
#	Now connect A->P and replication should work fine and resume from 201 instead of 101.

# 11) Complex tests of LOADINST.
# 	Do 100 updates A and then take a backup of the db/instfile. Load the db contents onto Q and do a loadinst
#	of the backed up instance file Q. Now Q will have seqno of A as 100.
#	Do 100 MORE updates A and then take a backup of the db/instfile. Load the db contents onto R and do a loadinst
#	of the backed up instance file R. Now R will have seqno of A as 200.
#	Now start Q->R replication where Q is root primary and R is propagating primary and both instances are supplementary.
#	How will they synchronize? I would think that Q should error out that secondary is ahead of primary.
#
# In the test implementation, below are the conventions
# INST1 - A
# INST2 - P
# INST3 - Q
# INST4 - R
# INST5 - Dummy
#
# INST5 dummy receiver is used by STARTSRC of multiple source servers
# The framework does not handle this (since an instance cannot receive from multiple sources) and so reuses
# the same port number while starting different source servers. So while shutting down source servers use
# RESERVEPORT until the last source connecting to INST5 is shutdown

# mumps.dat is moved from INST1 to INST2. a) encryption will cause issues b) set jnl on -reg "*" will issue FILEEXISTS
setenv test_encryption "NON_ENCRYPT"
setenv gtm_test_mupip_set_version "disable"
setenv test_jnl_on_file 1

# INST5 receiver server is never started in the test. So, there isn't any mumps.repl file available in INST5.
# If $gtm_custom_errors is set, then the INTEG on INST5 will error out with FTOKERR/ENO2. To avoid this, unsetenv gtm_custom_errors.
# In case of multi-host tests the env.txt at the beginning of the test is used till the end, so unset it at the top instead of just before dbcheck
unsetenv gtm_custom_errors
$MULTISITE_REPLIC_PREPARE 1 4
$gtm_tst/com/dbcreate.csh mumps -rec=1000

setenv needupdatersync 1
$MSR STARTSRC INST2 INST5 RP
$MSR START INST1 INST2 RP
unsetenv needupdatersync

if ( "MULTISITE" == $test_replic ) then
	$MSR RUN INST2 'set msr_dont_trace ; source $gtm_tst/com/set_gtm_machtype.csh ; echo $gtm_endian' >&! inst2_endian.out
	set inst1endianness = $gtm_endian
	set inst2endianness = `cat inst2_endian.out`
	# if the machines are of different endianness, will need to endian convert database before using.
	if ( "$inst1endianness" != "$inst2endianness" ) then
		set INST12_opp_endian = 1
	endif
endif
# 100 updates on A, backup, load db onto Q
$gtm_tst/com/simplegblupd.csh -instance INST1 -count 100 >>& updates.log
$MSR RUN INST1 'mkdir bak100 ; $MUPIP backup -replinstance=bak100 "*" bak100 >&! backup100.out'
# In the current setup, INST1 and INST3 (i.e HOST1 and HOST3) will be of same endian. No need to check until the assumption is violated by framework
$MSR RUN SRC=INST1 RCV=INST3 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/bak100/mumps.dat _REMOTEINFO___RCV_DIR__/'
setenv needupdatersync 1
$MSR STARTSRC INST3 INST5 RP
$MSR START INST1 INST3 RP
unsetenv needupdatersync

# stop A->P, do 100 more updates on A
$MSR STOPRCV INST1 INST2
$MSR STOPRCV INST1 INST3
$MSR STOPSRC INST2 INST5 RESERVEPORT
$MSR STOPSRC INST3 INST5
$gtm_tst/com/simplegblupd.csh -instance INST1 -count 100 >>& updates.log
$MSR STOPSRC INST1 INST2
$MSR STOPSRC INST1 INST3

# backup A (with 200 updates), load into P
$MSR RUN INST1 'mkdir bak200 ; $MUPIP backup -replinstance=bak200 "*" bak200 >&! backup200.out'
if ($?INST12_opp_endian) then
	cd bak200 ;
	cp mumps.dat mumps.dat.orig ; cp ../mumps.gld .
	$MUPIP reorg -upgrade -reg "*" 		>>&! mupip_upgrade_endiancvt.txt
	echo "y" | $MUPIP endiancvt mumps.dat	>>&! mupip_upgrade_endiancvt.txt
	cd ..
endif
$MSR RUN SRC=INST1 RCV=INST2 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/bak200/mumps.dat _REMOTEINFO___RCV_DIR__/'
$MSR RUN INST2 'mv mumps.repl mumps.repl_bak ; mv mumps.mjl mumps.mjl_bak  '

# INST2 and INST4 would reside on the same machine and hence the same endian. No need to check again before sending (already endian converted if required)
# Load the 200 updates on A on R
$MSR RUN SRC=INST1 RCV=INST4 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/bak200/mumps.dat _REMOTEINFO___RCV_DIR__/'

# Start A->P with updateresync (after loading 200 updates from A). Should work
setenv needupdatersync 1
$MSR STARTSRC INST2 INST5 RP
$MSR STARTSRC INST4 INST5 RP
$MSR START INST1 INST2 RP
$MSR START INST1 INST4 RP
unsetenv needupdatersync
$MSR STOP INST1 INST4
# should see 200 as the stream seqno of the A stream when you do a mupip replic -edit -show mumps.repl P.
$MSR RUN INST2 '$MUPIP replic -edit -show mumps.repl' >&! INST2_repl_show.out
$grep -E "Root Primary Instance Name|Stream Sequence Number" INST2_repl_show.out

$gtm_tst/com/simplegblupd.csh -instance INST1 -count 1 >>& updates.log
$MSR STOP INST1 INST2
$MSR STOPSRC INST2 INST5 RESERVEPORT
$MSR STOPSRC INST4 INST5

# Q has 100 and R has 200. Starting Q->R should error with secondary ahead of primary
setenv needupdatersync 1
$MSR RUN INST4 'mv mumps.repl mumps.repl_bak'
$MSR STARTSRC INST3 INST4 RP
get_msrtime
set src_time_msr="$time_msr"
# We expect RCVR to shutdown with "Receiver was not started with -AUTOROLLBACK. Manual ROLLBACK required. Shutting down" because RCVR is ahead of SRC
# so skip checkhealth
setenv gtm_test_repl_skiprcvrchkhlth 1
$MSR STARTRCV INST3 INST4
unsetenv gtm_test_repl_skiprcvrchkhlth
unsetenv needupdatersync
get_msrtime
set rcvr_time_msr="$time_msr"
$MSR RUN INST3 '$gtm_tst/com/wait_for_log.csh -log 'SRC_$src_time_msr.log' -message "REPLAHEAD" -duration 120 -waitcreation'
$MSR RUN INST4 '$gtm_tst/com/wait_for_log.csh -log 'RCVR_$rcvr_time_msr.log' -message "REPLAHEAD" -duration 120 -waitcreation'
$MSR RUN INST4 'set msr_dont_trace ; $gtm_tst/com/wait_until_srvr_exit.csh rcvr'
$MSR RUN RCV=INST4 SRC=INST3 '$MUPIP replic -source -shutdown -timeout=0 -instsecondary=__SRC_INSTNAME__  >&! passivesrc_shut_INST3INST4.out'
$MSR REFRESHLINK INST3 INST4

# The instances are not in sync. Do not use -extract
$gtm_tst/com/dbcheck.csh
