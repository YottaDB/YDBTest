#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#=====================================================================
$echoline
cat << EOF
cleanslots -- design tests -- Source Server Shutdown
        --------------------------------------------------------
               INST1/P         INST2/S1          INST3/S2
        --------------------------------------------------------
This is to test that MUPIP REPLIC -SOURCE -SHUTDOWN cleans up one or more slots used up by formerly active or passive
source servers that were not cleanly shutdown (Kill -15).
1.	Create a primary instance P and two secondary instances S1 and S2.
2.	Start an active source server from P to secondary S1.  Do not start S1 yet.
3.	Start a passive source server from P to secondary S2.  Do not start S2 yet.
4.	Two gtmsource_local slots in the journal pool should now be used up for S1 and S2.
5.	Start GTM process and do updates for 10 seconds. Do not shut the GTM process.
6.	Start S1 and S2.
7.	Wait for 2 seconds.
8.	Kill -15 the source server for S1.
9.	Run MUPIP REPLIC -SOURCE -SHUTDOWN -INSTSECONDARY=S1. This should print a message saying the source server is already dead.
10.	Restart active source server for S1. Should start without any problems and reuse the existing slot for S1.
11.	Kill -15 the source server for S2.
12.	Run MUPIP REPLIC -SOURCE -SHUTDOWN -INSTSECONDARY=S1 followed by the same command with S2 instead of S1. Both
	should work fine, and the second one should print a message saying the source server is already dead.
13.	You should see the journal pool still existing and GTM processes working fine.
14.	Shut the GTM process.
15.	The GTM process should be gone but the journal pool should still exist.
16.  	Run SRC=INST1 RCV=INST2 'MUPIP replic -source -shutdown -instsecondary=__RCV_INSTNAME__'
	Run SRC=INST1 RCV=INST3 'MUPIP replic -source -shutdown -instsecondary=__RCV_INSTNAME__'
	Both the above should error out with SRCSRVNOTEXIST message. And journal pool should still exist.
17.  	Randomly run one of the commands below
	50% -- RUN SRC=INST1    'MUPIP replic -source -shutdown'
	50% -- RUN INST2 	'MUPIP RUNDOWN -REG *'
	Either of them should work without errors and the journal pool should be removed.
18.	Run MUPIP REPLIC -EDITINSTANCE -SHOW to display the contents of the instance file. Check that CRASH etc. fields
	are reset by the shutdown command.

EOF

$echoline
echo "#- Step 1:"
$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/com/dbcreate.csh . 1 125 1000 4096 2000 4096 2000

$echoline
echo "#- Step 2:"
$MSR STARTSRC INST1 INST2
#note the filename of the source server log
get_msrtime  # sets $time_msr
setenv srclogfile12 SRC_$time_msr.log
echo srclogfile12 is $srclogfile12
#note the process id of the source server
$MSR RUN SRC=INST1 RCV=INST2 '$MUPIP replic -source -checkhealth -instsecondary=__RCV_INSTNAME__' > checkhealth12.log
set pidsrc12 = `$grep PID checkhealth12.log |  sed 's/PID //g;s/ Source server.*//g'`
echo "pidsrc12 is $pidsrc12" >>&! pid_dbg.log

$echoline
echo '#- Step 3:'
$MSR STARTSRC INST1 INST3
#note the filename of the source server log
get_msrtime  # sets $time_msr
setenv srclogfile13 SRC_$time_msr.log
echo srclogfile13 is $srclogfile13
#note the process id of the source server
$MSR RUN SRC=INST1 RCV=INST3 '$MUPIP replic -source -checkhealth -instsecondary=__RCV_INSTNAME__' > checkhealth13.log
set pidsrc13 = `$grep PID checkhealth13.log |  sed 's/PID //g;s/ Source server.*//g'`
echo "pidsrc13 is $pidsrc13" >> pid_dbg.log

$echoline
echo '#- Step 4:'
$gtm_tst/com/view_instancefiles.csh -print -instance INST1
echo '#  	--> We should see the gtmsource_local slots for S1 and S2'
$echoline
echo '#- Step 5:'
$MSR RUN INST1 '$gtm_tst/com/simplebgupdate.csh 10000 >>&! bg.out'
sleep 10

$echoline
echo '#- Step 6:'
$MSR STARTRCV INST1 INST2
$MSR STARTRCV INST1 INST3

$echoline
echo '#- Step 7:'
# Wait till the Resync Sequence Number is updated in the replication instance file.
# This is to avoid reference file mismatch of the number due to timing issues
$MSR RUN SRC=INST1 RCV=INST2 '$gtm_tst/com/wait_for_src_slot.csh -instance INSTANCE2 -searchstring "Resync Sequence Number" -eq 10001'
$MSR RUN SRC=INST1 RCV=INST3 '$gtm_tst/com/wait_for_src_slot.csh -instance INSTANCE3 -searchstring "Resync Sequence Number" -eq 10001'
$echoline
echo '#- Step 8:'
echo "#  kill -15 source server for INST2."
$MUPIP replic -editinstance -show $gtm_repl_instance >&! before_kill1.out
$kill -15 $pidsrc12
$gtm_tst/com/wait_for_proc_to_die.csh $pidsrc12 100
if ($status) then
	echo "TEST-E-ERROR process $pidsrc12 did not die."
endif
$gtm_tst/com/wait_for_log.csh -log $srclogfile12 -message "FORCEDHALT"
$gtm_tst/com/check_error_exist.csh $srclogfile12 FORCEDHALT
$MUPIP replic -editinstance -show $gtm_repl_instance >&! after_kill1.out

$echoline
echo '#- Step 9:'
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -shutdown -timeout=0 -instsecondary=__RCV_INSTNAME__' >& shutdown12_1.log
echo "#  	--> We expect a SRCSRVNOTEXIST error."
$gtm_tst/com/check_error_exist.csh shutdown12_1.log SRCSRVNOTEXIST
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out SRCSRVNOTEXIST

$echoline
echo '#- Step 10:'
$MUPIP replic -editinstance -show $gtm_repl_instance >&! before_start1.out
$MSR STARTSRC INST1 INST2
$MUPIP replic -editinstance -show $gtm_repl_instance >&! after_start1.out

$echoline
echo '#- Step 11:'
#kill -15 source server for INST3.
$MUPIP replic -editinstance -show $gtm_repl_instance >&! before_kill2.out
$kill -15 $pidsrc13
$gtm_tst/com/wait_for_proc_to_die.csh $pidsrc13 100
if ($status) then
	echo "TEST-E-ERROR process $pidsrc13 did not die."
endif
$gtm_tst/com/wait_for_log.csh -log $srclogfile13 -message "FORCEDHALT"
$gtm_tst/com/check_error_exist.csh $srclogfile13 FORCEDHALT
$MUPIP replic -editinstance -show $gtm_repl_instance >&! after_kill2.out

$echoline
echo '#- Step 12:'
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -shutdown -timeout=0 -instsecondary=__RCV_INSTNAME__' >& shutdown12_2.log
echo '#  	--> This should succeed. (but jnlpool will not be removed due to the GTM processes'
$grep "processes still attached to jnlpool" shutdown12_2.log
$MSR RUN SRC=INST1 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -shutdown -timeout=0 -instsecondary=__RCV_INSTNAME__' >& shutdown13.log
echo "#  	--> We expect a SRCSRVNOTEXIST error."
$gtm_tst/com/check_error_exist.csh shutdown13.log SRCSRVNOTEXIST
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out SRCSRVNOTEXIST
$MUPIP replic -editinstance -show $gtm_repl_instance >&! after_shutdownattempt.out

echo '#- Step 13:'
echo '#  Check the journal pool exists:'
$gtm_tst/com/check_jnlpool.csh 1
echo '#  Check gtm processes are fine:'
echo '#  grep for errors in the imptp.out and other files related to the updates' #BYPASSOK
echo '#- Step 14:'
echo '# signal simplebgupdate to stop'
touch endbgupdate.txt
$gtm_tst/com/wait_for_proc_to_die.csh `sed 's/^\[.*\] //' bg.out`

$echoline
echo '#- Step 15:'
echo '#  Check the journal pool still exists:'
$gtm_tst/com/check_jnlpool.csh 1
$gtm_tst/com/view_instancefiles.csh -instance INST1 -ignore "0: Journal Sequence Number"
echo '#- Step 16:'
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -shutdown -instsecondary=__RCV_INSTNAME__ -timeout=0'  >& shutdown12_last.log
echo "#	--> We expect a SRCSRVNOTEXIST, and jnlpool should exist."
$gtm_tst/com/check_error_exist.csh shutdown12_last.log SRCSRVNOTEXIST
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out SRCSRVNOTEXIST
$gtm_tst/com/check_jnlpool.csh 1
$MSR RUN SRC=INST1 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -shutdown -instsecondary=__RCV_INSTNAME__ -timeout=0'  >& shutdown13_last.log
echo "#	--> We expect a SRCSRVNOTEXIST, and jnlpool should exist."
$gtm_tst/com/check_error_exist.csh shutdown13_last.log SRCSRVNOTEXIST
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out SRCSRVNOTEXIST
$gtm_tst/com/check_jnlpool.csh 1

$echoline
echo "#- Step 17:"
echo '#  Randomly run one of the commands below'
echo "#  50% -- RUN SRC=INST1 '$MUPIP replic -source -shutdown'"
echo "#  50% -- RUN INST1 '$MUPIP RUNDOWN -REG *'"
cat << EOF
  	  --> Both of them should work without errors and the journal pool should be removed.
EOF
$gtm_tst/$tst/u_inref/cleanslots_helper.csh >& cleanslots_helper.log
echo '# Check the output at cleanslots_helper.log and helper.log'
echo '#  The journal pool should be gone:'
$gtm_tst/com/check_jnlpool.csh 0
$MSR REFRESHLINK INST1 INST2
$MSR REFRESHLINK INST1 INST3

$echoline
echo '#- Step 18:'
$gtm_tst/com/view_instancefiles.csh -print -instance INST1 -diff -ignore '0: Journal Sequence Number'
echo '#  	--> Check the CRASH etc. fields are reset by the shutdown command. (depending on the command run in step 16).'
echo "#- Wrap up:"
$gtm_tst/com/dbcheck.csh
#=====================================================================
