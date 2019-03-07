#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test for -noresync qualifier
#

source $gtm_tst/com/gtm_test_setbeforeimage.csh

$MULTISITE_REPLIC_PREPARE 2 2
$gtm_tst/com/dbcreate.csh mumps -rec=1000

# 6) Test -noresync & -updateresync interaction.
#    That is as part of a -noresync startup, if ever the receiver has to go PAST an updateresync in the instance file, it works fine.

# 42) Test of -noresync
#    A,B are in one LMS group. P is in a different supplementary LMS group.
#    A->B and A->P replication is in effect.
#    A does 10 transactions. Only 8 of those go to B. But all 10 reach P before A gets shut down.
#    So A,P have 10 updates while B has only 8 of those.
#    Now B comes up as primary. Now bring up A as secondary to B. One needs to do a fetchresync rollback on A.
#    It will produce a lost transaction file containing 2 updates (updates 9 and 10).
#    Now start source server on B to replicate to P.
#    The receiver server on P, which has been running all this while, should connect fine with B.
#    But it should detect that P is ahead of B and error out.
#    The source server on B should continue to be up and running. Only the receiver should have errored out.
#    Restart the receiver server on P with the -noresync qualifier.
#    This time around it should work just fine. A new history record with strm_index of 1 and strm_seqno of 9 should be written in P
#       indicating this is a -noresync type of history record.
#    Also verify that an EPOCH record gets written in the journal file by the update process with a strm_seqno of 9 for strm_num=1.
#

setenv needupdatersync 1
$MSR START INST1 INST2 RP
$MSR START INST3 INST4 RP
$MSR START INST1 INST3 RP
unsetenv needupdatersync
setenv port13 `$MSR RUN INST3 'set msr_dont_trace ; cat portno'`
$gtm_tst/com/simplegblupd.csh -instance INST1 -count 8        # seqnos: (1-8)
$MSR SYNC ALL_LINKS
$MSR STOPRCV INST1 INST2
$gtm_tst/com/simplegblupd.csh -instance INST1 -count 2        # seqnos: (9-10)
$MSR SYNC ALL_LINKS
$gtm_tst/com/view_instancefiles.csh -instance INST3 -printhistory

echo "# Now bring up B(INST2) as primary and connect P (INST3) to it"
$MSR STOP INST1 INST3
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST2 INST3 RP
echo "# The receiver should error out and exit with REPL_ROLLBACK_FIRST"
setenv gtm_test_repl_skiprcvrchkhlth 1
$MSR STARTRCV INST2 INST3
unsetenv gtm_test_repl_skiprcvrchkhlth
get_msrtime
$MSR RUN INST3 '$gtm_tst/com/wait_for_log.csh -log 'RCVR_${time_msr}.log' -message "Received REPL_ROLLBACK_FIRST"'
$MSR RUN INST3 'set msr_dont_trace ; $gtm_tst/com/wait_until_srvr_exit.csh rcvr'
echo "# Now start the receiver with -noresync. The Source shouldnt have exited and the connection should happen"
$MSR STARTRCV INST2 INST3 noresync
get_msrtime
$MSR RUN INST3 "$gtm_tst/com/wait_for_log.csh -log RCVR_${time_msr}.log.updproc -message 'New History Content'"
echo "# A new history record with strm_index of 1 and strm_seqno of 9 should be written in P indicating this is a -noresync type of history record"
$gtm_tst/com/view_instancefiles.csh -instance INST3 -printhistory
$MSR SYNC ALL_LINKS
echo "# EPOCH record gets written in the journal file by the update process with a strm_seqno of 9 for strm_num=1"
$MSR RUN INST3 "$gtm_exe/mumps -run jnlflush"
# If instance3 is frozen due to $gtm_test_fake_enospc, journal -extract below would fail with,
# %YDB-E-SETEXTRENV, Database files are missing or Instance is frozen; supply the database files, wait for the freeze to lift or
# define gtm_extract_nocol to extract possibly incorrect collation
# To avoid that set gtm_extract_nocol before doing extract
$MSR RUN INST3 'setenv gtm_extract_nocol 1 ; set files = `ls mumps.mjl*`;set mjls = `echo $files | sed "s/ /,/g"` ;$MUPIP journal -extract=mumps.mjf -detail -forward $mjls >&! jnl_extr.out'
$MSR RUN SRC=INST1 RCV=INST3 '$gtm_tst/com/cp_remote_file.csh _REMOTEINFO___RCV_DIR__/mumps.mjf  __SRC_DIR__/mumps.mjf' >&! transfer_mumps.mjf.out
$tst_awk -F '\\' '/EPOCH/ {  if ((1==seen11) && (9==$13)) {print $12,$13 ; quit} ; if (11 == $13) {seen11=1} }' mumps.mjf
$gtm_tst/com/simplegblupd.csh -instance INST2 -count 5

$MSR SYNC ALL_LINKS
$MSR RUN INST1 '$gtm_exe/mumps -run printglobals'
$MSR RUN INST2 '$gtm_exe/mumps -run printglobals'
$MSR RUN INST3 '$gtm_exe/mumps -run printglobals'
$MSR STOP ALL_LINKS

# 7) Test -noresync does nullification of only a PART of the history
#    Start with -noresync and see that it truncates a portion of the history.
#    Do some updates.
#    Later shut this receiver down.
#    Start a fetchresync rollback with the same receiver instance but a DIFFERENT source instance (maybe a backup of the above primary
#    taken at a prior instant in time) such that the common sync point is BEFORE the point where -noresync stopped. We expect
#    rollback to error out with NOPREVLINK error because -noresync would have nullified the prevlink.
#
# This is no longer a concern, as noresync doesn't nullify history, it is possible to rollback prior to a -noresync.  So we check here
# that it works correctly.
echo "# Check if it is possible to rollback prior to a -noresync point"
$MSR STARTSRC INST1 INST3 RP
$MSR RUN RCV=INST3 SRC=INST1 '$gtm_tst/com/mupip_rollback.csh noresync -verbose -fetchresync=__RCV_PORTNO__ -losttrans=lost_INST3.glo "*"' >& rollback_INST3.log

$grep -E "RLBKJNSEQ|RLBKSTRMSE|JNLSUCCESS" rollback_INST3.log

$MSR RUN INST3 '$gtm_exe/mumps -run printglobals'

# Instances will not be in sync. So no -extract
$gtm_tst/com/dbcheck.csh
