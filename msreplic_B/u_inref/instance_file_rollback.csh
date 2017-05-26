#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
#
# Helpers cause the rollback below to throw MURPOOLRNDWNFL errors, so disable them.
setenv gtm_test_updhelpers 0
#=====================================================================
$echoline
echo "#  To test rollback will rollback the contents of the instance file if they had not made it to the database."
#  INST1 --> INST2
$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh . 1
echo "#- Create a history in the instancefiles (INST1 and INST2 will share some history)"
$MSR START INST1 INST2
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 5'
$MSR SYNC INST1 INST2
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 5'
$MSR SYNC INST1 INST2
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2
# wait for connection to replication server to occur prior to doing primary updates for accurate Connect Sequence Number"
get_msrtime
$gtm_tst/com/wait_for_log.csh -log SRC_$time_msr.log -message "Sending REPL_HISTREC message" -duration 100 -waitcreation  # wait up to 100 seconds
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 5'
$MSR SYNC ALL_LINKS sync_to_disk
$gtm_tst/com/view_instancefiles.csh 		#no.1
$MSR RUN INST2 '$MUPIP replic -editinstance -show $gtm_repl_instance ' > hist2_orig.out
set origlasthist2 = `$grep HST hist2_orig.out | $tail -n 1 | $tst_awk '{print $3}'`

$echoline
echo "#- Now let's take a copy of the database on the secondary"

$MSR RUN INST2 'mkdir -p backup; cp -p *.dat *.repl *.gld *.mjl* backup'

$echoline
echo "#- Create a history in the instancefile"
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 5'
$MSR SYNC INST1 INST2
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 5'
$MSR SYNC INST1 INST2
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 5'
$MSR SYNC INST1 INST2
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 5'
$MSR SYNC INST1 INST2
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 5'
$MSR SYNC INST1 INST2
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2

$echoline
echo "#- Wait until the instancefile contents are updated."
$MUPIP replic -editinstance -show $gtm_repl_instance >& hist1.out
set lasthistrec1 = `$grep HST hist1.out | $tail -n 1 | $tst_awk '{print $3}'`
set timeout = 300
set incre = 5
while ($timeout)
	set ts = `date +%H%M%S`
	$MSR RUN INST2 '$MUPIP replic -editinstance -show $gtm_repl_instance >& hist2.tmp ; cat hist2.tmp' > hist2_$ts.out
	set lasthistrec2 = `$grep HST hist2_$ts.out | $tail -n 1 | $tst_awk '{print $3}'`
	if ($lasthistrec2 == $lasthistrec1) break
	sleep $incre
	@ timeout = $timeout - $incre
end
if (! $timeout) then
	echo "TEST-E-TIMEOUT, timed out waiting for history records to sync."
endif
echo "lasthistrec1: $lasthistrec1, lasthistrec2: $lasthistrec2"
if ($lasthistrec1 == $origlasthist2) then
	echo "TEST-E-ERROR, no new history records seen, something wrong."
endif

$echoline
$gtm_tst/com/view_instancefiles.csh -diff 	#no.2
echo "#  	--> We expect the history records from the primary to be in the instance file on INST2."
echo "#- Crash the receiver server."
$MSR CRASH INST2

echo "#- Now copy over the saved database (that is at an older state than the replication instance file)"
$MSR RUN INST2 'cp backup/{*.dat,*.mjl*} .'

$echoline
echo "#- Now rollback:"
$MSR RUN RCV=INST2 '$gtm_tst/com/mupip_rollback.csh -verbose "*" >& rollback.tmp ; cat rollback.tmp' >& rollback.log
$grep JNLSUCCESS rollback.log
$gtm_tst/com/view_instancefiles.csh -diff 	#no.3
echo "#  	--> We expect all of the new history to be removed."
$MSR RUN INST2 '$MUPIP replic -editinstance -show $gtm_repl_instance ' > hist2_final.out
set finallasthist2 = `$grep HST hist2_final.out | $tail -n 1 | $tst_awk '{print $3}'`
if ($finallasthist2 != $origlasthist2) then
	echo "TEST-E-ERROR, rollback did not rollback the history records!"
	echo "finallasthist2: $finallasthist2, origlasthist2: $origlasthist2"
endif
$MSR STARTRCV INST1 INST2
$MSR SYNC INST1 INST2
echo "#  	--> All updates should make it successfully."
$gtm_tst/com/dbcheck.csh -extract INST1 INST2
#=====================================================================
