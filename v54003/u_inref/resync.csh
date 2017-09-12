#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test case exercises resync qualifier behavior
# prepare local and remote directories

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"
alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

BEGIN "Start source server and receiver server with journaling enabled"
$MULTISITE_REPLIC_PREPARE 2
setenv tst_jnl_str "$tst_jnl_str,epoch_interval=5"
setenv gtm_test_jnl "SETJNL"				# Force journaling
source $gtm_tst/com/gtm_test_setbeforeimage.csh		# Force before images for backward recovery
$gtm_tst/com/dbcreate.csh mumps 5

# start source and reciever server
$MSR START INST1 INST2 RP
END

BEGIN "Make updates on database for around 40 seconds"
$gtm_exe/mumps -run dbupdate^dbupdate
END

BEGIN "Crash secondary and take the backup of crashed database"
$MSR CRASH INST2
$sec_shell "cd $SEC_SIDE; $gtm_tst/com/backup_dbjnl.csh bak1 '*.dat *.mjl*' cp nozip"
END

BEGIN "run -fetchresync ROLLBACK on secondary and collect memory usage statistics"
# Below backward rollback invocation runs with gtmdbglvl set to 4 for memory statistic collection.
# Therefore pass "-backward" explicitly to mupip_rollback.csh (and avoid implicit "-forward" rollback
# invocation that would otherwise happen by default).
$MSR RUN RCV=INST2 SRC=INST1 'setenv gtmdbglvl 4; $gtm_tst/com/mupip_rollback.csh -backward -verbose -fetchresync=__RCV_PORTNO__ -losttrans=lost1_INST1_1.glo "*"; unsetenv gtmdbglvl' >&! fetchresync_rb.log
END

BEGIN "Take the backup of recovered database"
$sec_shell "cd $SEC_SIDE; $gtm_tst/com/backup_dbjnl.csh bak2 '*.dat *.mjl*' mv nozip"
END

BEGIN "Get the sequence number to be used in -resync ROLLBACK"
set resyncno=`$grep "RESYNC SEQNO" fetchresync_rb.log | $tst_awk '{print $11}'`
echo "fetchresync seq no is=GTM_TEST_DEBUGINFO "$resyncno
$sec_shell "cd $SEC_SIDE; echo $resyncno >& resyncno.txt"
END

BEGIN "Calculate the memory usage for -fetcyresync ROLLBACK"
$grep Malloc fetchresync_rb.log | $tst_awk '{print $5}' >&! memuse1.txt
$gtm_exe/mumps -run memstat^memstat memuse1.txt >&! count1.txt
END

BEGIN "Restore the crashed database on secondary"
$sec_shell "cd $SEC_SIDE; cp ./bak1/*.dat ./bak1/*.mjl* ."
END

BEGIN "run -resync ROLLBACK on restored crashed database"
# Below backward rollback invocation runs with gtmdbglvl set to 4 for memory statistic collection.
# Therefore pass "-backward" explicitly to mupip_rollback.csh (and avoid implicit "-forward" rollback
# invocation that would otherwise happen by default).
$MSR RUN RCV=INST2 SRC=INST1 'setenv gtmdbglvl 4; $gtm_tst/com/mupip_rollback.csh -backward -verbose -resync=`cat resyncno.txt` -losttrans=lost1_INST1_2.glo "*"; unsetenv gtmdbglvl' >& resync_rb.log
END

BEGIN "Calculate the memory usage for -fetcyresync ROLLBACK"
$grep Malloc resync_rb.log | $tst_awk '{print $5}' >&! memuse2.txt
$gtm_exe/mumps -run memstat memuse2.txt >&! count2.txt
END

BEGIN "Stop source server"
$MSR STOPSRC INST1 INST2
END

# The value of the tracebuffsize is defined in repl_comm.c by constants REPL_SEND_TRACE_BUFF_SIZE and REPL_RECV_TRACE_BUFF_SIZE.
# If the value of these constants are chagned in repl_comm.c; following constants should also be changed.
BEGIN "Set the size of tracebuffsize depending upon the platform"
set tracebuffsize=4194304
END

BEGIN "Compare the memory usage for fetchresync ROLLBACK and resync ROLLBACK"
# The repl_send() function allocates a trace buffers (4Mb in size) for debugging purposes.
# In response to the REPL_FETCH_RESYNC message, the fetchresync rollback will invoke repl_recv() which again
# allocates trace buffer of 4Mb in size. So we need to subtract these 8MB from FETCHRESYNC ROLLBACK memory usage.
@ tmp=`cat count1.txt` - $tracebuffsize
@ fresync_musage=$tmp - $tracebuffsize
@ resync_musage=`cat count2.txt`
@ musediff=$fresync_musage - $resync_musage

# The expected difference between FETCHRESYNC ROLLBACK and RESYNC ROLLBACK is less than 1%.
$GTM <<EOF
write "fetchresync ROLLBACK memory usage=GTM_TEST_DEBUGINFO"_$fresync_musage
write "resync ROLLBACK memory usage=GTM_TEST_DEBUGINFO"_$resync_musage
write "memory usage difference for fetchresync and resync rollback=GTM_TEST_DEBUGINFO"_$musediff
write "Constant trace buffer size is=GTM_TEST_DEBUGINFO"_$tracebuffsize
if ((($musediff/$fresync_musage)*100)>5) WRITE "There is noticeable difference memory usage of fetchresync and resync ROLLBACK"
else  WRITE "Memory usage for fetchresync ROLLBACK and resync ROLLBACK are as expected"
EOF
END

# Since INST2 is crashed, explicitly remove the ports (including suppl_port)
$MSR RUN INST2 'set msr_dont_trace ; $gtm_tst/com/portno_release.csh'
$gtm_tst/com/dbcheck.csh
