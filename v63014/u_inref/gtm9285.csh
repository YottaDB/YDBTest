#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
if (! $test_replic) then
    echo '*** This test must be run with -replic - exiting'
    exit 1
endif
#
echo '# GTM-9285 - Test multiple changes to how -CONNECTPARAMS affects starting of source server'
echo
echo '# Test the following issues:'
echo '#   1. REPLALERT logging is by default disabled due to default 0 value of the 4th field of the -connect parameter.'
echo '#   2. Hard tries loop is bypassed when value is set to 0.'
echo '#   3. Adjusts the soft-tries-period to be half of the computed shutdown wait (120 seconds for one region).'
echo '#   4. Source server log includes unit of measure for hard & soft wait log messages.'
echo '#   5. MUPIP reports a BADCONNECTPARAM if the specification is incorrect or the user specifies a value that may'
echo '#      lead to an out-of-design situation. This test also exercises the code that one no longer needs to specify'
echo '#      all 6 values but one does need to specify all values up through the one that one is intending to change.'
#
echo
echo '# Create database - start replication'
$gtm_tst/com/dbcreate.csh mumps >& dbreate.log

if (! $?portno) then
	setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
endif

set instsecondary = "-instsecondary=$gtm_test_cur_sec_name"
## Make sure the source server and receiver server complete the handshake
setenv start_time `cat start_time`
$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log RCVR_'${start_time}'.log.updproc -message "New History Content" -duration 120'
## Shutdown INST1-source-server and INST2-receiver-server"
$gtm_tst/com/SRC_SHUT.csh >& SRC_SHUTDOWN_test0.log
$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh "." < /dev/null >>& $SEC_SIDE/SHUT_`date +%H_%M_%S`.out'

echo
$echoline
echo '#'
echo '# Test #1: Show default alert setting - start up source with no receiver server which would produce REPLALERT'
echo '#          messages but the default value 0 at startup will not show REPLALERT messages in the log.'
$pri_shell "cd $PRI_SIDE; $MUPIP replic -source -start -secondary="$HOST":"$portno" -log=src1.log -buffsize=1 $instsecondary" >&inst1_activity_test1.out
echo
echo '# Waiting for mention of what the alert setting is'
$gtm_tst/com/wait_for_log.csh -log src1.log -message "REPLALERT message period"
echo
echo '# Shutting down INST1 source server'
$gtm_tst/com/SRC_SHUT.csh >& SRC_SHUTDOWN_test1.log
echo
echo '# Show any REPLALERT messages or mentions of REPLALERT in the source server log (should be one message also'
echo '# mentioning "Soft tries" and a REPLALERT value of 0)'
$grep REPLALERT src1.log | cut -c 28-

echo
$echoline
echo '#'
echo '# Test #2: Show that specifying 0 for a hard-tries count bypasses the hard spin loop.'
$pri_shell "cd $PRI_SIDE; $MUPIP replic -source -start -secondary="$HOST":"$portno" -log=src2.log -buffsize=1 -conn=0 $instsecondary" >&inst1_activity_test2.out
echo
echo '# Waiting for Soft tries message indicating hard tries loop is either done or bypassed'
$gtm_tst/com/wait_for_log.csh -log src2.log -message "Soft tries period = 5 seconds, REPLALERT message period = 0 seconds"
echo
echo '# Shutting down INST1 source server'
$gtm_tst/com/SRC_SHUT.csh >& SRC_SHUTDOWN_test2.log
echo
echo '# Show any source log message mentioning hard tries or hard connection - should be just one showing the parameters:'
$grep -E 'hard tries|hard connection attempt' src2.log | cut -c 28-

echo
$echoline
echo '#'
echo '# Test #3: Adjusts the soft-tries-period to be half of the computed shutdown wait (120 seconds for one region). Start the'
echo '#          source server with a soft tries period of 300 (5 mins) and verify the auto-adjust.'
$pri_shell "cd $PRI_SIDE; $MUPIP replic -source -start -secondary="$HOST":"$portno" -log=src3.log -buffsize=1 -conn=0,500,300 $instsecondary" >&inst1_activity_test3.out
echo
echo '# Wait for message to see what the soft tries got reduced to'
$gtm_tst/com/wait_for_log.csh -log src2.log -message "Soft tries period = "
echo
echo '# Shutting down INST1 source server'
$gtm_tst/com/SRC_SHUT.csh >& SRC_SHUTDOWN_test3.log
echo
echo '# Show any source log message mentioning soft tries period - looking for message resetting the soft-tries-period'
echo '# to half the maximum shutdown wait. Note that ARM process equipped systems have a much larger maximum shutdown'
echo '# wait (240 seconds) than the x86 systems do (120 seconds):'
$grep 'Soft tries period' src3.log | cut -c 28-

echo
$echoline
echo '#'
echo '# Test #4: Source server log includes unit of measure for hard & soft wait log messages'
echo
echo '# Scan earlier source  server log (from Test #1) for hard & soft log messages'
$grep -E 'Connect hard tries count|Soft tries period =' src1.log | cut -c 28-

echo
$echoline
echo '#'
echo '# Test #5: MUPIP reports a BADCONNECTPARAM if the specification is incorrect or the user specifies a value that may'
echo '#          lead to an out-of-design situation. This test also exercises the code that one no longer needs to specify'
echo '#          all 6 values but one does need to specify all values up through the one that one is intending to change.'
echo
echo '# The following commands all have an invalid -connect parameter string with one or more of the parameters inside'
echo '# being either outright invalid (non-numerics) or values that lead to out-of-design situations.'
echo
echo '# $MUPIP REPLIC -source -start -secondary=xxx -log=src5.log, buffsize=1 -CONN=0,0 $instsecondary : Expect BADCONNECTPARAM error'
$pri_shell "cd $PRI_SIDE; $MUPIP replic -source -start -secondary="$HOST":"$portno" -log=src5.log -buffsize=1 -conn=5,0 $instsecondary"
echo
echo '# $MUPIP REPLIC -source -start -secondary=xxx -log=src5.log, buffsize=1 -CONN=5,500,60,30 $instsecondary : Expect BADCONNECTPARAM error'
$pri_shell "cd $PRI_SIDE; $MUPIP replic -source -start -secondary="$HOST":"$portno" -log=src5.log -buffsize=1 -conn=5,500,60,30 $instsecondary"
echo
echo '# $MUPIP REPLIC -source -start -secondary=xxx -log=src5.log, buffsize=1 -CONN=5,500,10,60,100,60 $instsecondary : Expect BADCONNECTPARAM error'
$pri_shell "cd $PRI_SIDE; $MUPIP replic -source -start -secondary="$HOST":"$portno" -log=src5.log -buffsize=1 -conn=5,500,10,60,100,60 $instsecondary"
echo
echo '# $MUPIP REPLIC -source -start -secondary=xxx -log=src5.log, buffsize=1 -CONN=5,500,10,60,60,100,42 $instsecondary : Expect BADCONNECTPARAM error'
$pri_shell "cd $PRI_SIDE; $MUPIP replic -source -start -secondary="$HOST":"$portno" -log=src5.log -buffsize=1 -conn=5,500,10,60,60,100,42 $instsecondary"
echo
echo '# The following are all tests that specify each of the 6 parameters as a non-numerica value as they all get different errors.'
echo
echo '# $MUPIP REPLIC -source -start -secondary=xxx -log=src5.log, buffsize=1 -CONN=z $instsecondary : Expect BADCONNECTPARAM error'
$pri_shell "cd $PRI_SIDE; $MUPIP replic -source -start -secondary="$HOST":"$portno" -log=src5.log -buffsize=1 -conn=z $instsecondary"
echo
echo '# $MUPIP REPLIC -source -start -secondary=xxx -log=src5.log, buffsize=1 -CONN=5,z $instsecondary : Expect BADCONNECTPARAM error'
$pri_shell "cd $PRI_SIDE; $MUPIP replic -source -start -secondary="$HOST":"$portno" -log=src5.log -buffsize=1 -conn=5,z $instsecondary"
echo
echo '# $MUPIP REPLIC -source -start -secondary=xxx -log=src5.log, buffsize=1 -CONN=5,500,z $instsecondary : Expect BADCONNECTPARAM error'
$pri_shell "cd $PRI_SIDE; $MUPIP replic -source -start -secondary="$HOST":"$portno" -log=src5.log -buffsize=1 -conn=5,500,z $instsecondary"
echo
echo '# $MUPIP REPLIC -source -start -secondary=xxx -log=src5.log, buffsize=1 -CONN=5,500,10,z $instsecondary : Expect BADCONNECTPARAM error'
$pri_shell "cd $PRI_SIDE; $MUPIP replic -source -start -secondary="$HOST":"$portno" -log=src5.log -buffsize=1 -conn=5,500,10,z $instsecondary"
echo
echo '# $MUPIP REPLIC -source -start -secondary=xxx -log=src5.log, buffsize=1 -CONN=5,500,10,60,z $instsecondary : Expect BADCONNECTPARAM error'
$pri_shell "cd $PRI_SIDE; $MUPIP replic -source -start -secondary="$HOST":"$portno" -log=src5.log -buffsize=1 -conn=5,500,10,60,z $instsecondary"
echo
echo '# $MUPIP REPLIC -source -start -secondary=xxx -log=src5.log, buffsize=1 -CONN=5,500,10,60,100,z $instsecondary : Expect BADCONNECTPARAM error'
$pri_shell "cd $PRI_SIDE; $MUPIP replic -source -start -secondary="$HOST":"$portno" -log=src5.log -buffsize=1 -conn=5,500,10,60,100,z $instsecondary"

echo
$echoline
echo '#'
echo '# Test #6: Verify that if hard-try-count is 5, that there are 5 hard-try loops and no more'
echo '#'
echo '# Note - Test#1 created a log file that we can use for this so show all of the "hard connection attempt" messages.'
echo '# Expect 5 hard connection attempts:'
$grep 'hard connection attempt' src1.log | cut -c 28-

echo
$echoline
echo
echo '# Integ databases (output at dbcheck.log)'
$gtm_tst/com/dbcheck.csh -noshut >& dbcheck.log
#==================================================================================================================================
