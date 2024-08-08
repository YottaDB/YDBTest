#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2020-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test basic supplementary replication
#
# Set gtm_test_spanreg to 0 so we avoid random mappings that can cause this test to fail.
setenv gtm_test_spanreg 0

if ($gtm_test_trigger) then
	# This tests A->P with imptp.csh (with SLOWFILL) invoked on both sides. If -trigupdate is enabled,
	# it would cause updates made inside the trigger on A to be played on P and in turn cause more updates
	# on P due to local trigger definitions for the same update (possible because test framework has enabled
	# trigger definitions due to $gtm_test_trigger being non-zero) and because SLOWFILL invocation causes
	# "slowfill.trg" triggers to be loaded in A and P in that case. This can cause nodes like
	# ^%slowfill("trigger") to have different values on A and P (1 and 2 respectively) because the SET trigger
	# for such nodes does a "set $ztvalue=$ztvalue+1" causing the final value to be 1 more than the original value.
	# This would result in a test failure with a "TEST-E-FAILED: RF_EXTR failed" symptom. Hence disable -trigupdate.
	source $gtm_tst/com/gtm_test_trigupdate_disabled.csh
endif

source $gtm_tst/com/gtm_test_setbeforeimage.csh
# 50% chances of using custom instance node name
set rand = `$gtm_exe/mumps -run rand 2`
if (1 == $rand) then
	# 15 bytes, if we include the number that will be appended; this is the longest allowed name.
	setenv gtm_test_base_inst_name "CALLMENAPOLEON"
endif
$MULTISITE_REPLIC_PREPARE 2 2

$gtm_tst/com/dbcreate.csh mumps 5 125-425 1000-1050 512,768,1024 4096 1024 4096

setenv needupdatersync 1
$MSR START INST1 INST2 RP
$MSR START INST3 INST4 RP
$MSR START INST1 INST3 RP
# Here we stop and restart the replication, to validate that -updateresync, which is used under the hood
# doesn't error out if the stream info is already present in the instance file.
get_msrtime
$MSR RUN INST3 '$gtm_tst/com/wait_for_log.csh -log RCVR_'${time_msr}'.log -message "History has non-zero Supplementary Stream" -duration 30'
$MSR STOP INST1 INST3
$MSR START INST1 INST3 RP
unsetenv needupdatersync

# Updates are made on non-supp (INST1) and supp (INST3) primaries
# Choose "SLOWFILL" for imptp below since on 1-CPU systems, the regular fill INST1 imptp.csh invocation will swamp the system
# enough that the INST3 imptp.csh invocation could error out with a "net/http: TLS handshake timeout" from go get if imptp chose
# the go flavor (i.e. ydb_imptp_flavor = 4). We have seen such timeouts almost always on ARMV6L (which is a 1-CPU system).
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; $gtm_tst/com/imptp.csh' >&! imptp1.out
$MSR RUN INST3 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; setenv gtm_test_dbfill "SLOWFILL" ; $gtm_tst/com/imptp.csh' >&! imptp2.out
sleep 15
$MSR SHOWBACKLOG INST1 INST3 SRC >&! backlog.txt
# Implementation defered, see <receiv_showbacklog>
#$MSR SHOWBACKLOG INST1 INST3 SRC "-supplementary" >&! supp_backlog.txt
#$MSR SHOWBACKLOG INST1 INST3 SRC "-supplementary -instprimary=INST1" >&! supp_inst1_backlog.txt
$MSR RUN INST1 "setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh" >&! endtp1.out
$MSR RUN INST3 "setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/endtp.csh" >&! endtp2.out

# Try an update on each secondary (will fail)
$gtm_tst/com/simplegblupd.csh -instance INST2 -count 1
$gtm_tst/com/simplegblupd.csh -instance INST4 -count 1

$MSR SYNC ALL_LINKS
$MSR STOP ALL_LINKS

# 17) Test that journal -show=header dumps all the strm_start_seqno and strm_end_seqno fields.
foreach inst ("INST1" "INST2" "INST3" "INST4")
	echo "Start/End RegSeqno for $inst"
	$MSR RUN $inst 'source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh '$0' ; $MUPIP journal -show=header -forward a.mjl,b.mjl,c.mjl,d.mjl,mumps.mjl' >&! ${inst}_jnl_show_hdr.out
	$grep RegSeqno ${inst}_jnl_show_hdr.out
end

$gtm_tst/com/dbcheck.csh -extract
