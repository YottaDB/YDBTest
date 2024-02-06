#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-9363 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-001_Release_Notes.html#GTM-9363)

  The Source Server performs its polling activities in a more CPU-efficient manner. Also, the Source Server
  schedules a TLS renegotiation after an appropriate multiple of heartbeat events. This prevents a TLS
  renegotiation from interfering/overlapping with the normal replication message interchange mechanism
  and eliminates the need of a separate timer event for running periodic TLS renegotiation. Previously,
  the Source Server used a separate timer for TLS renegotiation which could cause a race condition. MUPIP
  produces the MUPCLIERR error when the specified heartbeat interval (the fifth parameter of -CONNECTPARAMS)
  is larger than the TLS renegotiate interval. Previously, it did not report this condition as an
  error. The default value of the heartbeat max period (the sixth parameter) of -CONNECTPARAMS is 300
  seconds. Previously, the value was 60 seconds. The Receiver Server logs an REPLCOMM information message
  when the connection breaks during a message exchange. Previously, the Receiver Server reported this
  event in its log file but not as an REPLCOMM informational message.. (GTM-9363)

********************************************************************************************
See the following discussion threads for a few portions of the release note that are not going to be tested.
  1) https://gitlab.com/YottaDB/DB/YDBTest/-/issues/544#note_1751617213
  2) https://gitlab.com/YottaDB/DB/YDBTest/-/issues/544#note_1762707387
********************************************************************************************

CAT_EOF

echo "# Setup SSL/TLS if not already set as this test relies on it."
if ("TRUE" != $gtm_test_tls) then
	setenv gtm_test_tls TRUE
	source $gtm_tst/com/set_tls_env.csh
endif

echo
echo "# ---------------------------------------------------------------------------------------"
echo "# test1 : Test that renegotiate interval is set to a multiple of the heartbeat interval"
echo "# ---------------------------------------------------------------------------------------"
echo "# Choose renegotiate interval randomly as 1 minute OR 2 minutes"
set reneg_interval_in_mins = `$gtm_dist/mumps -run %XCMD 'write 1+$random(2)'`
echo "reneg_interval_in_mins = $reneg_interval_in_mins" >>! random_vars.txt	# Store random value as test artifact in case of need

echo "# Set [gtm_test_tls_renegotiate] env var to that value as that is what gets used by dbcreate.csh"
setenv gtm_test_tls_renegotiate "$reneg_interval_in_mins"

echo "# Choose heartbeat interval randomly between 20 seconds and 60 seconds"
echo "# Choosing minimum as 20 seconds to avoid test failures due to very small heartbeat intervals"
echo "#   as a loaded system might not do a renegotiation at the calculated time."
echo "# Choosing maximum as 60 seconds to ensure heartbeat interval stays below renegotiate interval"
echo "#   which has a minimum value of 1 minute."
set heartbeat_interval = `$gtm_dist/mumps -run %XCMD 'write 20+$random(41)'`
echo "heartbeat_interval = $heartbeat_interval" >>! random_vars.txt	# Store random value as test artifact in case of need

echo
echo "# This test verifies that renegotiation happens exactly at the calculated time."
echo "# This is bound to cause failures on the slower AARCH64/ARMV6L systems so this subtest is disabled there."
echo

set connectparam_values = "5,500,5,0"
# Set heartbeat interval through -CONNECTPARAMS qualifier passed to [mupip replic -source -start]
# Do this by setting [gtm_test_src_connectparams] env var
setenv gtm_test_src_connectparams "-connectparams=$connectparam_values,$heartbeat_interval"

echo '# Run [dbcreate.csh] to create database and start replication servers on source and receiver side'
$gtm_tst/com/dbcreate.csh mumps

echo "# Calculate the actual renegotiation interval (in terms of a multiple of heartbeat intervals)"
echo "# See the rules described at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/544#note_1761057527"
echo "# for details on the below calculation."
set reneg_interval_in_secs = `$gtm_dist/mumps -run %XCMD 'write '$reneg_interval_in_mins'*60'`
set reneg_factor = `echo "$reneg_interval_in_secs/$heartbeat_interval" | bc`
set reneg_interval_rounded = `$gtm_dist/mumps -run %XCMD "set x=$reneg_factor set:x=1 x=2 write x*$heartbeat_interval"`
echo "# Run [mupip replic -source -jnlpool -show] to verify actual renegotiation interval matches expected."
$MUPIP replic -source -jnlpool -show >& jnlpool_show1.out
set input_reneg_interval_in_secs = `$grep 'Input Renegotiate Interval' jnlpool_show1.out | $tst_awk '{print $10}'`
set actual_reneg_interval_in_secs = `$grep 'Actual Renegotiate Interval' jnlpool_show1.out | $tst_awk '{print $10}'`
if ($input_reneg_interval_in_secs == $reneg_interval_in_secs) then
	echo "PASS : [Input Renegotiate Interval] matches expected value"
else
	echo "FAIL : [Input Renegotiate Interval] : Expected = $reneg_interval_in_secs : Actual = $input_reneg_interval_in_secs"
endif
if ($actual_reneg_interval_in_secs == $reneg_interval_rounded) then
	echo "PASS : [Actual Renegotiate Interval] matches expected value"
else
	echo "FAIL : [Actual Renegotiate Interval] : Expected = $reneg_interval_rounded : Actual = $actual_reneg_interval_in_secs"
endif

echo
echo "# ---------------------------------------------------------------------------------------"
echo "# test2 : Test that [Next Renegotiate Time] is accurate"
echo "# ---------------------------------------------------------------------------------------"
echo "# Wait for source and receiver to connect. That will ensure TLS renegotiation happened as part of initial handshake."
setenv start_time `cat start_time`
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_${start_time}.log.updproc -message 'New History Content' -duration 120"
echo "# Get [Next Renegotiate Time] from [mupip replic -source -jnlpool -show] output in jnlpool_show2.out."
$MUPIP replic -source -jnlpool -show >& jnlpool_show2.out
set next_renegotiate_time = `$grep 'Next Renegotiate Time' jnlpool_show2.out | $tst_awk '{print $9}'`
echo "# Wait and verify actual renegotiation happens at that time."
set reneg_ack_me_msg = "Sending REPL_RENEG_ACK_ME message"
# Since the renegotiation period can be as high as 2 minutes, wait longer than the default 2 minutes (120 seconds)
# in wait_for_log.csh. Hence the use of "-duration 300" below.
$gtm_tst/com/wait_for_log.csh -log SRC_${start_time}.log -message "$reneg_ack_me_msg" -duration 300
echo "# Look at the timestamp of the [$reneg_ack_me_msg] line in the source server log."
set actual_reneg_time = `$grep "$reneg_ack_me_msg" SRC_${start_time}.log | $tst_awk '{print $4}'`

# In some cases, actual renegotiation time has been seen to be off by just 1 second. So allow for that.
set next_renegotiate_time_in_epoch_seconds = `date -d"$next_renegotiate_time" +%s`
@ next_renegotiate_time_in_epoch_seconds_plus_one = $next_renegotiate_time_in_epoch_seconds + 1
set next_renegotiate_time_plus_one = `date -d @$next_renegotiate_time_in_epoch_seconds_plus_one +"%T"`

echo "# Check if the timestamp matches the [Next Renegotiate Time] timestamp noted above."
if (("$actual_reneg_time" == "$next_renegotiate_time") || ("$actual_reneg_time" == "$next_renegotiate_time_plus_one")) then
	echo "PASS : Actual renegotiation happened exactly when [Next Renegotiate Time] indicated"
else
	echo "FAIL : Actual renegotiation happened at [$actual_reneg_time] which does not match [Next Renegotiate Time] = [$next_renegotiate_time]"
endif

echo
echo "# ---------------------------------------------------------------------------------------"
echo "# test3 : Test that [Prev Renegotiate Time] is accurate"
echo "# ---------------------------------------------------------------------------------------"
echo "# Verify [Prev Renegotiate Time] becomes old value of [Next Renegotiate Time]"
echo "# Get [mupip replic -source -jnlpool -show] output again in jnlpool_show3.out"
$MUPIP replic -source -jnlpool -show >& jnlpool_show3.out
set prev_renegotiate_time = `$grep 'Prev Renegotiate Time' jnlpool_show3.out | $tst_awk '{print $9}'`
if ($prev_renegotiate_time == $next_renegotiate_time) then
	echo "PASS : [Prev Renegotiate Time] after renegotiation matches [Next Renegotiate Time] before renegotiation"
else
	echo "FAIL : [Prev Renegotiate Time] after renegotiation = [$prev_renegotiate_time] does not match [Next Renegotiate Time] before renegotiation = [$next_renegotiate_time]"
endif

echo
echo '# Run [dbcheck.csh] to integ database and shut replication servers on source and receiver side'
$gtm_tst/com/dbcheck.csh

echo
echo "# ---------------------------------------------------------------------------------------------------"
echo "# test4 : Test that MUPCLIERR error is seen if heartbeat interval is larger than renegotiate_interval"
echo "# ---------------------------------------------------------------------------------------------------"
echo "# Set heartbeat interval to a random value guaranteed to be larger than the renegotiate_interval"
if (1 == $reneg_interval_in_mins) then
	# Renegotiate interval was randomly chosen to be 1 minute in a previous stage of the test.
	# Reset heartbeat interval to be 61 seconds or higher
	set heartbeat_interval2 = `$gtm_dist/mumps -run %XCMD 'write 61+$random(100)'`
else
	# Renegotiate interval was randomly chosen to be 1 minute in a previous stage of the test.
	# Reset heartbeat interval to be 121 seconds or higher
	set heartbeat_interval2 = `$gtm_dist/mumps -run %XCMD 'write 121+$random(100)'`
endif
echo "test4 : heartbeat_interval = $heartbeat_interval2" >>! random_vars.txt	# Store random value as test artifact in case of need

echo "# Try restarting source server using the same command as generated in the previous stage of this test"
echo "# But modify just the heartbeat interval to be the new larger value."
echo "# Expect a MUPCLIERR error"
# The first sed expression below removes the date/timestamp from the source server startup command
# The second sed expression does the heartbeat replacement
# The third sed expression removes any IPv6 usages in the -secondary= qualifier (e.g. the "[::1]" in "-secondary=[::1]:36007")
# as that would cause a tcsh "No match" error when trying to expand the ":" usage. We use a hardcoded port of 30000 instead
# which is okay because we expect the source server start command to error out anyways.
head -1 SRC*.log | sed 's/.* : //;s/'$connectparam_values','$heartbeat_interval'/'$connectparam_values','$heartbeat_interval2'/;s/-secondary=[^ ]*/-secondary=:30000/;' > new_SRC.csh
source new_SRC.csh

echo
echo "# -------------------------------------------------------------------------------------------------------"
echo "# test5 : Test that Default value of heartbeat max period (6th parameter in CONNECTPARAMS) is 300 seconds"
echo "# -------------------------------------------------------------------------------------------------------"
set srch_term = "Connect Parms Heartbeat Max Wait"
echo "# Search for [$srch_term] in jnlpool_show2.out (from a previous stage of the test)"
echo "# That stage did not specify an explicit value so the default should have been used"
echo "# We expect the default to be 300 below"
$grep "$srch_term" jnlpool_show2.out

