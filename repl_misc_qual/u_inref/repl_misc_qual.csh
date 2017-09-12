#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
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
# This is based off of the switch_over test
#
setenv gtm_test_tptype "ONLINE"
setenv test_sleep_sec 30
setenv maxwaittime 300
# This test does a failover. A->P won't work in this case.
if ("1" == "$test_replic_suppl_type") then
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif

# Since the receiver is explicitly restarted without -tlsid, the source server (if started with -tlsid) would error out with
# REPLNOTLS. To avoid that, allow for the source server to fallback to plaintext when that happens.
setenv gtm_test_plaintext_fallback
# For this test buffer size is 1 MB
setenv tst_buffsize 1048576
$gtm_tst/com/dbcreate.csh mumps 4 125 1000 2048 2048 2048 2048
setenv portno `$sec_shell 'cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
#
# GTM Process starts in background
$gtm_exe/mumps $gtm_tst/com/genstr.m
$gtm_tst/com/imptp.csh "4" >>&! imptp.out
sleep $test_sleep_sec
setenv gtm_repl_instsecondary $gtm_test_cur_sec_name
set verbose
### Test for statslog and changelog
## C9C06-002026 Replic Server crashes with SIG 11 for -stats_log option
# Default is OFF
$MUPIP replicate -source -statslog=ON
echo $status
$gtm_tst/com/wait_for_log.csh -log SRC_$start_time.log -message "Begin statistics logging" -duration 120
$MUPIP replicate -source -statslog=OFF
echo $status
$gtm_tst/com/wait_for_log.csh -log SRC_$start_time.log -message "End statistics logging" -duration 120
$MUPIP replicate -source -statslog=ON >>& SRC3_ignore.out
$MUPIP replicate -source -statslog=ON >>& SRC4_ignore.out
sleep 4
$MUPIP replicate -source -statslog=OFF >>& SRC5_ignore.out
$MUPIP replicate -source -statslog=OFF >>& SRC6_ignore.out
$MUPIP replicate -source -statslog=OFF -changelog -log=SRC7.log
sleep 4
$MUPIP replicate -source -changelog -log=SRC8.log
echo $status
$MUPIP replicate -source -changelog -log=SRC9.log >>& SRC9_ignore.out
$MUPIP replicate -source -changelog -log=SRC10.log >>& SRC10_ignore.out
$MUPIP replicate -source -changelog -log=SRC11.log >>& SRC11_ignore.out
$gtm_tst/com/wait_for_log.csh -log SRC8.log -message "Change log to SRC8.log successful" -duration $maxwaittime -waitcreation
unset verbose
foreach x (`$grep "Change log initiated with" *ignore.out | $tst_awk '{print $NF}'`)
$gtm_tst/com/wait_for_log.csh -log $x -message "Change log to $x successful" -duration $maxwaittime -waitcreation
end
set verbose
$MUPIP replicate -source -changelog -log=SRC12.log
echo $status
$gtm_tst/com/wait_for_log.csh -log SRC12.log -message "Change log to SRC12.log successful" -duration $maxwaittime -waitcreation
$MUPIP replicate -source -changelog -log=SRC12.log
echo $status
unset verbose
###
$gtm_tst/com/endtp.csh >>&! imptp.out
$gtm_tst/com/RF_sync.csh
$gtm_tst/com/rfstatus.csh "AFTER_STEP1:"
#
# SWITCH OVER #
#
setenv ctime `date +%H_%M_%S`
echo "Switch started at: `date +%H:%M:%S`" >>&! time.log
#
echo "Shut down current receiver server/update process in side (B)"
#
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$MUPIP replic -receiv -shutdown -timeout=0 >>& $SEC_SIDE/RCVR_SHUT_${ctime}.out'
#
$DO_FAIL_OVER
#
echo "Passive source server will start in side (A)"
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$MUPIP replicate -source -shutdown -timeout=0'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$MUPIP replic -source -start -propagateprimary -buffsize=$tst_buffsize -passive -log=PASSIVE.log'
echo "Start receiver server in (A)"
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$MUPIP replic -receiv -start -buffsize=$tst_buffsize -listen=$portno -log=RCVR0.log'
#
echo "Making (B) ACTIVE from PASSIVE..."
####??? -conn is necessary to workaround a bug
####??? $pri_shell "$pri_getenv; cd $PRI_SIDE;"'$MUPIP replicate -source -activate -connect="5,500,5,30,15,60" -secondary="$tst_now_secondary":"$portno" -log=NEWSRC.log'
$pri_shell "$pri_getenv; cd $PRI_SIDE;"'$MUPIP replicate -source -activate -instsecondary=$gtm_test_cur_sec_name -secondary="$tst_now_secondary":"$portno" -log=SRC0.log >&! $PRI_SIDE/SRC0.out'
$gtm_tst/com/rfstatus.csh "BOTH_UP:"
echo "Switch ends at: `date +%H:%M:%S`" >>&! time.log
echo "Starting GTM on new primary side..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; "'$gtm_exe/mumps $gtm_tst/com/genstr.m'"; $gtm_tst/com/imptp.csh "4" < /dev/null "">>&!"" imptp.out"
sleep $test_sleep_sec
setenv ctime `date +%H_%M_%S`
set verbose
### Test for statslog and changelog
## C9C06-002026 Replic Server crashes with SIG 11 for -stats_log option
# Default is OFF
$MUPIP replicate -receiv -statslog=ON
echo $status
$gtm_tst/com/wait_for_log.csh -log RCVR0.log -message 'Begin statistics logging' -duration 120
$MUPIP replicate -receiv -statslog=OFF
echo $status
$gtm_tst/com/wait_for_log.csh -log RCVR0.log -message 'End statistics logging' -duration 120
$MUPIP replicate -receiv -statslog=ON
$MUPIP replicate -receiv -statslog=ON >>& RCVR4_ignore.out
$MUPIP replicate -receiv -statslog=OFF >>& RCVR5_ignore.out
$MUPIP replicate -receiv -statslog=OFF >>& RCVR6_ignore.out
$MUPIP replicate -receiv -statslog=OFF -changelog -log=RCVR7.log
sleep 4
$MUPIP replicate -receiv -changelog -log=RCVR8.log
echo $status
$MUPIP replicate -receiv -changelog -log=RCVR9.log >>& RCVR9_ignore.out
$MUPIP replicate -receiv -changelog -log=RCVR10.log >>& RCVR10_ignore.out
$MUPIP replicate -receiv -changelog -log=RCVR11.log >>& RCVR11_ignore.out
$gtm_tst/com/wait_for_log.csh -log RCVR8.log.updproc -message "Change log to RCVR8.log.updproc successful" -duration $maxwaittime -waitcreation
date > outputdateRCVR8.log
unset verbose
foreach x (`$grep "Change log initiated with" RCVR*ignore.out | $tst_awk '{print $NF}'`)
$gtm_tst/com/wait_for_log.csh -log $x.updproc  -message "Change log to $x.updproc successful" -duration $maxwaittime -waitcreation
end
date > outputdateBfrRCVR12
set verbose
$MUPIP replicate -receiv -changelog -log=RCVR12.log
echo $status
date > outputdateAftrRCVR12
$gtm_tst/com/wait_for_log.csh -log RCVR12.log.updproc -message "Change log to RCVR12.log.updproc successful" -duration $maxwaittime -waitcreation
date > outputdateAftrRCVR12_2.log
$MUPIP replicate -receiv -changelog -log=RCVR12.log
echo $status
unset verbose
sleep 4
###
echo "Stopping GTM on primary side..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/endtp.csh  < /dev/null "">>&!"" endtp.out"
#
$gtm_tst/com/rfstatus.csh "BEFORE_TEST_STOPS:"
$gtm_tst/com/dbcheck.csh -extract
cd $PRI_DIR
$gtm_tst/com/checkdb.csh
echo "Please look at time.log for timing information."
