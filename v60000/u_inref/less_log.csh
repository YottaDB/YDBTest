#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This is to test the mechanism for adaptively adjusting replication logging frequency

cat << EOF
## Test the mechanism for adaptively adjusting replication logging frequency
##  INST1 --> INST2
EOF

$gtm_tst/com/dbcreate.csh mumps 1

if (! $?portno) then
	setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
endif

if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_sec_name"
endif
## Make sure the source server and receiver server completes the handshake
setenv start_time `cat start_time`
#$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log RCVR_'${start_time}'.log.updproc -message "History has non-zero Supplementary Stream" -duration 120'
$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log RCVR_'${start_time}'.log.updproc -message "New History Content" -duration 120'
## Turn off INST1 and INST2-receiver"
$MUPIP replicate -source -checkhealth >&! health0.outx
set pidsrc=`$tst_awk  '($1 == "PID") && ($2 ~ /[0-9]*/) { print $2 }' health0.outx`
$pri_shell "cd $PRI_SIDE; $MUPIP replic -source -shut -time=0" >&  init_off.outx
$gtm_tst/com/wait_for_proc_to_die.csh $pidsrc 120
if ($status) then
        echo "TEST-E-ERROR source server $pidsrc did not die."
endif

$sec_shell "cd $SEC_SIDE; $MUPIP replic -receiv -shut -time=0" >>& init_off.outx

##Test 1 is to test that the logging period can exponentially increase until exceeding the threshold for default connection parameters when the receiver is not started
echo " "
echo "# Test 1: Using default settings for connection: soft_tries_period=5, alert_period=30"
$echoline
## Turn on the INST1-source server to start logging soft tries attempts on src1.log
$pri_shell "cd $PRI_SIDE; $MUPIP replic -source -start -secondary="$HOST":"$portno" -log=src1.log -buffsize=1 $gtm_test_instsecondary" >&inst1_activity.outx
# Let source server run up to 175 seconds, during which the logging period will increase such that logs are printed at 5, 10, 20, 40, 80, and then 160 seconds.
# The value of 175 was chosen to (safely) exceed the following: 5 + 10 + 20 + 40 + 80 + hard tries time (5 * 0.5) = 157.5 seconds.
$gtm_tst/com/wait_for_log.csh -log src1.log -message "Could not connect to secondary in 160 seconds" -duration 175
echo "src1.log:"; $grep -E 'soft connection attempt failed|GTM-W-REPLWARN' src1.log|cut -c 28-
echo "============Test1 ends=========="

##Test 2 is to test that the logging period can exponentially increase until exceeding the threshold after changing the connection parameters when the receiver is not started
echo " "
echo "# Test 2: Set the soft tries period=1, alert time = 2"
$echoline

## Turn off INST1-source and turn it on with connection parameters
$MUPIP replicate -source -checkhealth >&! health2.outx
set pidsrc=`$tst_awk  '($1 == "PID") && ($2 ~ /[0-9]*/) { print $2 }' health2.outx`
$MUPIP replic -source -shut $gtm_test_instsecondary -time=0 >>&inst1_activity.outx
$gtm_tst/com/wait_for_proc_to_die.csh $pidsrc 120
if ($status) then
        echo "TEST-E-ERROR source server $pidsrc did not die."
endif
## -conn= 5 (hard tries times), 500 (hard tries period, ms), 1 (soft tries period), 2 (alert period), 15 (heartbeat period), 60 (max heartbeat wait)
$MUPIP replic -source -start -log=src2.log -secondary="$HOST":"$portno" -buff=$tst_buffsize $gtm_test_instsecondary -conn=5,500,1,2,15,60 >>&inst1_activity.outx
# Let source server run up to 85 seconds, during which the logging period will increase, such that logs are printed at 1, 2, 4, 8, 16, 32, and then 64 seconds.
## The value of 85 was chosen to (safely) exceed the following: 1 + 2 + 4 + 8 + 16 + 32 + hard tries time (5 * 0.5) = 65.5 seconds.
$gtm_tst/com/wait_for_log.csh -log src2.log -message "64 soft connection attempt" -duration 85
echo "src2.log:"; $grep -E 'soft connection attempt failed|GTM-W-REPLWARN' src2.log |cut -c 28-
echo "============Test2 ends=========="

##Test 3 is to test that the logging period can exponentially increase until exceeding the threshold when the receiver is down
echo " "
echo "# Test 3: keep the soft tries period=1, alert time = 2, start the receiver, then shut down the receiver "
$echoline

## Change log file of INST1 to src3.log
$MUPIP replic -source -changelog -log=src3.log $gtm_test_instsecondary >>&inst1_activity.outx

## Turn on INST2-receiver, and after the source server connects to the receiver server, turn it off
$sec_shell "cd $SEC_SIDE; $MUPIP replic -receiv -start -listen="$portno" -log=rcv.log -buf=$tst_buffsize" >&inst2_activity.outx
$gtm_tst/com/wait_for_log.csh -log src3.log -message "Connection information" -duration 10
$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log rcv.log.updproc -message "New History Content" -duration 120'
$sec_shell "cd $SEC_SIDE; $MUPIP replic -receiv -shut -time=0" >>&inst2_activity.outx

## Similar to test 2, Let source server run for 85 seconds, during which the logging period always exponentially increases
$gtm_tst/com/wait_for_log.csh -log src3.log -message "64 soft connection attempt failed" -duration 85
echo "src3.log:"; $grep -E 'soft connection attempt failed|GTM-W-REPLWARN' src3.log|cut -c 28-
echo "============Test3 ends=========="

## Test 4 is to test that logging period will no longer increase when it exceeds the threshold
## It is also to test that the servers can run normally with very large soft tries period (larger than maximum logging period)
echo " "
echo "# Test 4: Set the soft tries period larger than maximum logging period (150), soft_tries_period = 155  alert_period=310 "
$echoline

## Turn off INST1-source"
$MUPIP replicate -source -checkhealth >&! health4.outx
set pidsrc=`$tst_awk  '($1 == "PID") && ($2 ~ /[0-9]*/) { print $2 }' health4.outx`
$MUPIP replic -source -shut $gtm_test_instsecondary -time=0 >>&inst1_activity.outx
$gtm_tst/com/wait_for_proc_to_die.csh $pidsrc 120
if ($status) then
        echo "TEST-E-ERROR source server $pidsrc did not die."
endif
## Turn on INST1-source,set the soft tries period as 155 seconds and alert period as 310 seconds
$MUPIP replic -source -start -log=src4.log -secondary="$HOST":"$portno" -log=src4.log -buf=1 $gtm_test_instsecondary -conn=2,500,155,310,15,60 >>&inst1_activity.outx

## Wait up to 175 seconds before starting the receiver server, during which time the source server should have two soft tries. The value of 175 was chosen to (safely)
## exceed the following: hard tries time (2 * 0.5) + 155 + hard tries time (2 * 0.5) = 157 seconds.
$gtm_tst/com/wait_for_log.csh -log src4.log -message "2 soft connection attempt failed" -duration 175
$sec_shell "cd $SEC_SIDE; $MUPIP replic -receiv -start -listen="$portno" -log=rcv4.log -buf=$tst_buffsize" >>&inst2_activity.outx

## Let receiver run up to another 175 seconds to make sure the source server can now connect to it.
$gtm_tst/com/wait_for_log.csh -log src4.log -message "Connection information" -duration 175


echo "src4.log:"; $grep -E 'soft connection attempt failed|GTM-W-REPLWARN' src4.log|cut -c 28-
## In src4.log, there will be no "3 soft connection attempt failed", which would mean that the source server connects to the receiver after more than 310 seconds.
## In the src4.log, the alert message  "Could not connect to secondary in 310 seconds" indicates that two logs take 155+155 seconds, i.e. the logging period does not increase.
echo "============Test4 ends=========="

## Turn off INST1-source
$MUPIP replicate -source -checkhealth >&! health5.outx
set pidsrc=`$tst_awk  '($1 == "PID") && ($2 ~ /[0-9]*/) { print $2 }' health5.outx`
set msg_not_expected = `$grep -E '3 soft connection attempt failed' src4.log`
if ($msg_not_expected != "") then
	echo "# `date` TEST-E-ERROR The source server has not connected to the receiver server"
	echo "# The test will exit now leaving around the replication servers"
	exit 1
endif
$pri_shell "cd $PRI_SIDE; $MUPIP replic -source -shut -time=0" >&inst1_final_shut.outx

## Turn off INST2 after the source server is shut down
$gtm_tst/com/wait_for_proc_to_die.csh $pidsrc 120
if ($status) then
        echo "# `date` TEST-E-ERROR source server $pidsrc did not die in 120 seconds. Test will exit now"
	exit 1
endif
$sec_shell "cd $SEC_SIDE; $MUPIP replic -receiv -shut -time=0" >>&inst2_activity.outx
$sec_shell "cd $SEC_SIDE; $MUPIP replic -source -shut -time=0" >>&inst2_activity.outx
$sec_shell "$sec_getenv ; cd $SEC_SIDE; source $gtm_tst/com/portno_release.csh"

$gtm_tst/com/dbcheck.csh -noshut >& dbcheck.outx
#==================================================================================================================================
