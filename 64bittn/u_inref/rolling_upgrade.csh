#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST : Rolling upgrade
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
setenv test_no_ipv6_ver 1
source $gtm_tst/com/gtm_test_setbeforeimage.csh

source $gtm_tst/com/gtm_test_trigupdate_disabled.csh	# This test does a switchover and so disable -trigupdate

#
setenv gtm_test_tptype "ONLINE"
setenv tst_buffsize 33000000
setenv gtm_test_dbfill "IMPTP"
# Because this test uses prior versions that may not handle large alignsize values, remove the alignsize part
setenv tst_jnl_str `echo "$tst_jnl_str" | sed 's/,align=[1-9][0-9]*//'`
# Start with A->B and at the end the test converts this A->B to A->P
setenv test_replic_suppl_type 0
# If secondary doesn't support SSL/TLS allow the source side to fallback to plaintext communication.
setenv gtm_test_plaintext_fallback
# Encryption is disabled in instream.csh. This subtest can run with encryption on, if applicable
setenv test_encryption $test_encryption_orig

if (! $?gtm_test_replay) then
	setenv msver `$gtm_tst/com/random_ver.csh -type ms`
	setenv rolling_upgrade_shut_kill `$gtm_exe/mumps -run rand 2`
	echo "setenv msver $msver"						>>& settings.csh
	echo "setenv rolling_upgrade_shut_kill $rolling_upgrade_shut_kill"	>>& settings.csh
endif

if ("$msver" =~ "*-E-*") then
	echo "No prior versions available: $msver"
	exit -1
endif

source $gtm_tst/com/ydb_prior_ver_check.csh $msver

if (`expr "$msver" "<" "V62000"`) then
	# disable triggers for versions prior to V62000 as replication between pre and post V62000 isn't supported
	setenv gtm_test_trigger 0
	# disable encryption for versions prior to V62000 as encryption setup (config files) changed from V62000
	setenv test_encryption NON_ENCRYPT
endif

# The default prompt is "GTM>" for versions < r1.00 and "YDB>" for other versions.
# Since we want a deterministic reference file, and it is not possible to get pre r1.00 versions to
# display a "YDB>" prompt, keep the prompt at "GTM>" even in post-r1.00 versions.
setenv gtm_prompt "GTM>"

# V62001 pro has a different layout of the relinkshm_hdr_t structure than debug or later versions. We do not want other
# processes to be accessing the relinkctl file it creates.
if ("V62001" == $msver) then
	setenv gtm_linktmpdir .
endif

setenv sv_oldver "source $gtm_tst/com/switch_gtm_version.csh $msver pro"
setenv sv_curver "source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image"
# priorver.txt is to filter the old version names in the reference file
echo $msver >& priorver.txt

$sv_oldver
$gtm_tst/com/dbcreate.csh mumps 3 125 1000
setenv portno `$sec_shell 'cd $SEC_SIDE; cat portno'`
setenv start_time1 `cat start_time`

#
echo "=================================================="
echo "############## Primary Side ######################"
echo "=================================================="
cd $PRI_SIDE
echo "Database fill program starts"

# use only v4imptp for all versions prior to V52000 because imptp.m uses ugenstr
# which has calls to ZCHAR available only from V52000
if (`expr "$msver" "<" "V52000"`) then
	$gtm_tst/com/v4imptp.csh >>&! v4imptp.out
else
	$gtm_tst/com/imptp.csh >>&! imptp.out
	source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
endif
#
echo "=================================================="
echo "############# Secondary Side #####################"
echo "=================================================="
echo "Shut down receiver server/update process...(B)"

# Before shutting down the receiver, make sure at least one update (i.e. seqno > 1) goes through on B and gets hardened.
# This is necessary to ensure a REPLINSTNOHIST error is issued by the source server on A when it connects
# to B in upgrade_and_start_repl.csh after switching to the new version in the case where the new version
# has a different replication instance file format than the version running on A.
# wait until update process has processed seqno=1
set stat = `$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_transaction_seqno.csh 2 RCVR 300; echo $status"`
if (0 != "$stat") then
	echo "TEST-E-TRANSACTIONS processed by the secondary did not reach the expected number (2)"
	echo "Since the rest of the test relies on this, no point in continuing it. Will exit now."
	$gtm_tst/com/endtp.csh >>& endtp.out
        $gtm_tst/com/dbcheck.csh
	exit 1
endif

# Since it is possible the "shut_normal_kill.csh" call done below could choose to crash B and remove db shm,
# we need to ensure the db file header and journal file buffers containing seqno=1 are flushed to disk before
# the shutdown that way we are guaranteed a fetchresync rollback done (after the crash if randomly chosen) would
# not take B back to seqno=1 (which would later cause REPLINSTNOHIST error to not be seen in the receiver log
# in upgrade_and_start_repl.csh).
$sec_shell '$sec_getenv; cd $SEC_SIDE; $sv_oldver; $gtm_tst/com/sync_to_disk.csh'

# randomly decide to shutdown gracefully or kill -15 the receiver server
$sec_shell '$sec_getenv; cd $SEC_SIDE;$sv_oldver;$gtm_tst/$tst/u_inref/shut_normal_kill.csh $start_time1'

# V62001 pro has a different layout of the relinkshm_hdr_t structure than debug or later versions. So, in case
# we have left a relinkctl shared memory around, run it down.
if ("V62001" == $msver) then
	$sec_shell '$sec_getenv; cd $SEC_SIDE;$sv_oldver;$gtm_dist/mupip rundown -relinkctl >&! mupip_rundown_relinkctl.log'
endif

echo "After shutting down receiver server in side B"
sleep 5
setenv start_time2 `date +%H_%M_%S`
$sec_shell '$sec_getenv;cd $SEC_SIDE;$gtm_tst/$tst/u_inref/upgrade_and_start_repl.csh $start_time2 "" check_jnlbadlabel'

echo "=================================================="
echo "############## Primary Side ######################"
echo "=================================================="
echo "Stop updates on primary side (Side A)"
$GTM << aa
write "GTM_TEST_DEBUGINFO: ",\$zv
aa
$gtm_tst/com/endtp.csh
mv endtp.out endtp1.out
# wait until backlog is clear
$gtm_tst/com/wait_until_src_backlog_below.csh 0

echo "=================================================="
echo "############# Secondary Side #####################"
echo "=================================================="
$sec_shell '$sec_getenv; cd $SEC_SIDE;$sv_curver;$gtm_tst/com/wait_until_rcvr_backlog_clear.csh'
echo "Stop replication servers in the upgraded secondary site (B)"
$sec_shell '$sec_getenv; cd $SEC_SIDE;$sv_curver; $gtm_tst/com/RCVR_SHUT.csh "." < /dev/null >& $SEC_SIDE/SHUT_${start_time2}_RCVR.out'

echo "=================================================="
echo "############## Primary Side ######################"
echo "=================================================="
echo "Do some more updates on side A, while receiver server is down"
# touch a file by name test_replic.txt. This is because jnlrecm routine will identify that file
# and will NOT do ZTS,ZTC transaction sets
touch test_replic.txt
$GTM << aa
write "GTM_TEST_DEBUGINFO: ",\$zv
d ^jnlrecm
aa

# SWITCH OVER STARTS#
#########################################################
echo "Switch over started at: `date +%H:%M:%S`" >>&! time.log
echo "Shut down primary source server..."
$gtm_tst/com/SRC_SHUT.csh "." >>&! SHUT_${start_time1}_OLDVER_SRC.out
$DO_FAIL_OVER
#
# NEW PRIMARY SIDE (B) UP
echo "======================================================================================================="
setenv start_time3 `date +%H_%M_%S`
echo "Restarting (B) as primary..."
$pri_shell '$pri_getenv; cd $PRI_SIDE;$sv_curver; $gtm_tst/com/SRC.csh "." $portno $start_time3 < /dev/null >& $PRI_SIDE/SRC_${start_time3}.out'
echo "Start some updates in side B (new Primary)"
$pri_shell '$pri_getenv; cd $PRI_SIDE;$sv_curver; $gtm_tst/com/imptp.csh >& $PRI_SIDE/imptp.out'
$pri_shell "$pri_getenv; source $gtm_tst/com/imptp_check_error.csh $PRI_SIDE/imptp.out"; if ($status) exit 1
sleep 5
cd $SEC_SIDE
echo "Do rollback in side A"
$sec_shell '$sec_getenv; cd $SEC_SIDE;$sv_oldver;$gtm_tst/com/mupip_rollback.csh -fetchresync=$portno -losttrans=prev_pri.lost "*" >& rollback_sideA.out'
# Search not just for YDB-S-JNLSUCCESS as if the random prior version chosen is < r1.20, it would have a GTM-S-JNLSUCCESS instead.
$grep -qE 'YDB-S-JNLSUCCESS|GTM-S-JNLSUCCESS' $SEC_SIDE/rollback_sideA.out
if (0 == $status) then
	echo  "Rollback succesful"
else
	echo "TEST-E-ERROR. Rollback failed. Pls. check rollback_sideA.out"
endif
echo "Now update side A to the current version"
# Since instance file format might be changing as part of the GT.M version upgrade, it is possible that we need
# to use the -updateresync qualifier inside the upgrade_and_start_repl.csh invocation below. In that case, we need
# a copy of the instance file from the new primary (B). Get that and pass it along.
$pri_shell '$pri_getenv; cd $PRI_SIDE;$sv_curver; $MUPIP backup -replinstance=pri_mumps.repl >&! replinst_bkup.out; cp pri_mumps.repl $SEC_SIDE/'
$gtm_tst/$tst/u_inref/upgrade_and_start_repl.csh "$start_time3" pri_mumps.repl

# get back to the test version here after rolling_upgrade completion on both sides now.
$sv_curver
$gtm_tst/com/rfstatus.csh "BOTH_UP:"
echo "Switch ends at: `date +%H:%M:%S`" >>&! time.log
# SWITCH OVER ENDS#
#
#
$gtm_tst/com/rfstatus.csh "BEFORE_SUPPLEMENTARY:"
echo "# Switch over ends. Now the replication setup is of the type A->B i.e secondary is non-supplementary"
$sec_shell '$sec_getenv; cd $SEC_SIDE;$sv_curver; $MUPIP replic -edit -show mumps.repl >& show_mumps_repl_orig.out ; $grep "HDR Supplementary Instance" show_mumps_repl_orig.out'
echo "# The below steps convert this setup to A->P"
echo "# Shutdown secondary"
# If there are no history records before shutting down the receiver, the subsequent start with -updresync will error out with "Input instance file has NO history records"
$sec_shell '$sec_getenv; cd $SEC_SIDE;$sv_curver; $gtm_tst/com/wait_for_log.csh -log RCVR_'${start_time3}'.log.updproc -message "New History Content" '
$sec_shell '$sec_getenv; cd $SEC_SIDE;$sv_curver; $gtm_tst/com/wait_until_rcvr_trn_processed_above.csh +1000'
$sec_shell '$sec_getenv; cd $SEC_SIDE;$sv_curver; $gtm_tst/com/RCVR_SHUT.csh "." < /dev/null >& $SEC_SIDE/SHUT_'${start_time3}'_RCVR.out'

setenv start_time4 `date +%H_%M_%S`
echo "# Recreate instance file with -supplementary"
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before moving replication instance files
$sec_shell '$sec_getenv; cd $SEC_SIDE;$sv_curver; mv mumps.repl old_nonsuppl_mumps.repl ; $MUPIP replic -instance_create -name=$gtm_test_cur_sec_name -supplementary '$gtm_test_qdbrundown_parms' '
echo "# Start source server with -updok"
$sec_shell '$sec_getenv; cd $SEC_SIDE;$sv_curver; $MUPIP replic -source -start -instsecondary=$gtm_test_cur_pri_name -passive -buffsize=$tst_buffsize -log=passive_${start_time4}.log -updok >& passive_start_${start_time4}_.out '

echo "# Start rcvr with -updateresync=<old_non-suppl_repl_file>"
$sec_shell '$sec_getenv; cd $SEC_SIDE;$sv_curver; $MUPIP replic -receiv -start -buffsize=$tst_buffsize -listenport=$portno -log=RCVR_${start_time4}.log -updateresync=old_nonsuppl_mumps.repl -initialize'

# Make sure the secondary side is supplementary instance
$sec_shell '$sec_getenv; cd $SEC_SIDE;$sv_curver; $MUPIP replic -edit -show mumps.repl >& show_mumps_repl_new.out ; $grep "HDR Supplementary Instance" show_mumps_repl_new.out'
echo "# Stop updates on the primary side"
$pri_shell '$pri_getenv; cd $PRI_SIDE;$sv_curver; $gtm_tst/com/endtp.csh;mv endtp.out endtp2.out'
# restore '$gtm_tst/com/dbcheck.csh -extract' once C9902-000863 is fixed
$gtm_tst/com/dbcheck_filter.csh
#
