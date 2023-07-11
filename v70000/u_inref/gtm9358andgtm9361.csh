#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Starting the source server has two processes attached to shared memory for a short time so a gtm_db_counter_sem_incr value
# causes an intermittent counter overflow. Unset this envvar to prevent counter overflows.
#
unsetenv gtm_db_counter_sem_incr
setenv gtm_repl_instance "mumps.repl"
set primary = $tst_working_dir
set secondary = $primary/secondary
#
# gtm9358 - test runs as non-replic as it needs to be able to start and stop receiver and source servers at will with
#           varying startup and shutdown options.
# gtm9361 - Test extents of changes to -TIMEOUT option of MUPIP REPLIC -SOURCE -SHUTDOWN, verify three new messages come
#           out appropriately (REPL0BACKLOG, REPLBACKLOG, and INVSHUTDOWN )
#
$echoline
echo '#'
echo '# This test contains the tests for two issues - gtm9358 and gtm9361 (YDBTest#511/512). The two issues have'
echo '# very similar setup with some portions of the test actually overlapping so they are taken care of together.'
echo '#'
echo '# (1) gtm9358 - Verify MUPIP REPLIC -SOURCE -ZEROBACKLOG -SHUTDOWN cleans up jnlpool IPC semaphores'
echo '#               A) Find jnlpool up/down semaphore'
echo '#               B) Verify jnlpool semaphore exists'
echo '#               C) Shutdown replic source server with parms -ZEROBACKLOG and -TIMEOUT=10'
echo '#               D) Verify the "Initiating ZEROBACKLOG shutdown operation" message is in the log'
echo '#               E) Verify the jnlpool up/down semaphore is cleaned up'
echo '# (2) gtm9361 - Verify new messages (REPL0BACKLOG, REPLBACKLOG), default timeout, and max timeout changes'
echo '#               A) In [1C] (shutdown zerobacklog), also verify that log contains REPL0BACKLOG message'
echo '#               B) Restart the source server shutdown in 1C above'
echo '#               C) Stop the receiver server to setup to create an intentional backlog'
echo '#               D) Do some updates'
echo '#               E) Shutdown source server with parms -ZEROBACKLOG and -TIMEOUT=10'
echo '#               F) Verify that the REPLBACKLOG message exists'
echo '#               G) Restart source server and receiver server'
echo '#               H) Shutdown the source server with parm -TIMEOUT=3601 (expect failure)'
echo '#               I) Verify got INVSHUTDOWN in the shutdown (source server not shutdown)'
echo '#               J) Shutdown the source server with parms -ZEROBACKLOG and -TIMEOUT=3600'
echo '#               K) Restart the source server that was shutdown (with no specified CONNECTPARAMS)'
echo '#               L) Test the default shutdown of the source server with ZEROBACKLOG so it shuts down'
echo '#                  quickly but it should record the default shutdown is 120 seconds in its log file'
echo '#               M) Verify from the shutdown log we have a 120 second shutdown timer'
echo '#               N) Verify success of shutdown'
echo '#'
echo '# All steps below are common to both tests unless otherwise indicated with [<test#><subtest#>] in output.'
echo '# Note all servers are started with -CONNECTPARAMS options that specify a heartbeat time of 2 seconds so'
echo '# the TIMEOUT values are generally multiples of that value. A warning message (SHUT2QUICK) is raised if'
echo '# the TIMEOUT is smaller than the (default) heartbeat of 15 seconds. The reason for using -CONNECTPARAMS'
echo '# is discussed in a note here: https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1651#note_1462125236'
echo '#'
echo '# Note all values for the CONNECTPARAMS value string must be specified up to the value you want to change.'
echo '# The values after the one changed do not need to be specified. You CANNOT default params by simply not'
echo '# specifying them (ie. -CONNECTPARAMS=,,,,2). Attempting to do so silently fails.'
echo '#'
echo
echo "# Obtain port number to use"
source $gtm_tst/com/portno_acquire.csh >>& portno.out
cat > primary_env << EOF
setenv gtm_repl_instname "INSTANCE1"
setenv gtm_test_cur_sec_name "INSTANCE1"
EOF
echo
echo '# Build primary and secondary replicated databases'
mkdir $secondary
foreach repldir (. $secondary)
    cd $repldir
    $gtm_dist/mumps -run GDE E      # Create local global directory
    $MUPIP create
    if ($repldir == '.') then
	$gtm_dist/mupip replicate -instance -name=INSTANCE1
    else
	$gtm_dist/mupip replicate -instance -name=INSTANCE2
    endif
    $gtm_dist/mupip set -replication=on -reg "*" -journal=enable,on,before
end
# Note we are still in the secondary directory at the end of this loop
echo
echo '# Setup environment file for secondary side'
cd $secondary
cat > secondary_env << EOF
setenv gtm_repl_instname "INSTANCE2"
setenv gtm_test_cur_sec_name "INSTANCE2"
EOF
setenv start_time `date +%H_%M_%S`
source secondary_env
echo
echo '# Start up the passive source server and receiver server. Note when we start either of active or passive source'
echo '# server, we do so with a -connectparams option to change the heartbeat from its default of 15 seconds to 2 seconds.'
echo '# The reason for this is the checks for the ZEROBACKLOG shutdown option are done at each heartbeat so rather than'
echo '# have a long timeout (20-30 seconds), we can still have a fairly short timeout making the test run faster.'
$MUPIP replic -source -start -passive -log=SRC_START_PASSIVE.log -instsecondary=INSTANCE1 -connectparams=5,500,5,0,2 >& replic_src_passive_startup.log
if (0 != $status) then
    echo
    $echoline
    echo "# TEST-F-NOSRCSRVSTART Starting of the passive source server failed - test terminating - cannot proceed"
    # Release our acquired port
    $gtm_tst/com/portno_release.csh
    exit 1
endif
$MUPIP replic -receiver -start -listen=$portno -log=RCVR_START.log -buf=1048576 >& replic_rcvr_startup.log # 1MB buffer
if (0 != $status) then
    echo
    $echoline
    echo "# TEST-F-NORCVSRVSTART Starting of the receiver server failed - test terminating - cannot proceed"
    # Release our acquired port
    $gtm_tst/com/portno_release.csh
    exit 1
endif
#
# Back to primary
#
cd $primary
source primary_env
echo
echo '# Start up the active source server'
$MUPIP replic -source -start -secondary="$HOST":"$portno" -log=SRC_START.log -buff=1048576 -instsecondary=INSTANCE2 -connectparams=5,500,5,0,2 >& replic_src_startup.log
if (0 != $status) then
    echo
    $echoline
    echo "# TEST-F-NOSRCSRVSTART Starting of the source server failed - test terminating - cannot proceed"
    # Release our acquired port
    $gtm_tst/com/portno_release.csh
    exit 1
endif
#
# The following calls make sure everything is up and operational (both sides)
#
echo
echo '# Wait for replication initialization to complete waiting for messages on both sides'
# Back to secondary
cd $secondary
source secondary_env
$gtm_tst/com/wait_for_log.csh -log RCVR_START.log.updproc -message "New History Content"
# Back to primary
cd $primary
source primary_env
echo
echo '# Generate a small amount of updates that must propagate to get things going'
$gtm_dist/mumps -run ^%XCMD 'for i=1:1:10000 set ^a(i)=$justify(i,64)'
echo
echo '# Obtain backlog stats for each server - verify both are 0 as we want the previous'
echo '# updates to be in a stable state.'
set srcbacklog = -1		# Set initial values so goes into while loop
set rcvrbacklog = -1
set first = 1
while (("$srcbacklog" != "0") || ("$rcvrbacklog" != "0"))
    if ("$first" == "0") then   # Snooze a second and set to primary (except first time)
        sleep 1
    endif
    set srcbacklog = `cd $primary; source primary_env; $gtm_tst/com/get_src_backlog.csh INSTANCE2`
    set rcvrbacklog = `cd $secondary; source secondary_env; $gtm_tst/com/get_rcvr_backlog.csh`
    set first = 0
end
echo
$echoline
# Back to primary
cd $primary
source primary_env
echo
echo '# [1A] Find the up/down semaphore (the one with the non-zero key) for the journal pool in the primary'
echo '# directory. This semaphore is the one left over when the source server is shutdown on a pre-V70000'
echo '# version. We need to change the ftoks fetched to have a 0x2c prefix instead of 0x2b prefix (which'
echo '# is for databases) to match the semkey used for the the jnlpool up/down semaphore.'
setenv jnlppftok `$MUPIP FTOK -ONLY mumps.repl |& $tst_awk '{print $5}'`		# jnlpool main ftok
set jnlppsem = `$gtm_dist/mumps -run ^%XCMD 'set x=$ztrnlnm("jnlppftok") write "0x2c"_$zextract(x,5,10)'`
echo
echo '# [1B] Verify semaphore exists'
ipcs -s | $grep -w $jnlppsem >& ipcs_jnlppsem.txt
set savestatus = $status
if (0 != $savestatus) then
    echo "** [1B] FAIL - jnlpool main semaphore does not seem to exist ($savestatus)"
else
    echo '## [1B] PASS - jnlpool main semaphore was found and exists'
endif
echo
echo '# [1C] Shutdown the source server with a 10 second timeout and the -ZEROBACKLOG option. This should expire in about 2 seconds'
echo '# as that is what the heartbeat was set to above.'
$MUPIP REPLIC -source -shutdown -zerobacklog -timeout=10 >& replic_src_shutdown.log
cat replic_src_shutdown.log | cut -c 28- >& replic_src_shutdown_nts.log
echo
echo '# [1D] Verify that the new expected messages are in the source log file (the "Initiating ZEROBACKLOG shutdown operation" msg).'
$grep 'Initiating ZEROBACKLOG shutdown operation' replic_src_shutdown_nts.log
if (0 != $status) then
    echo '** [1D] FAIL - "Initiating ZEROBACKLOG shutdown operation" message was not found in replic_src_shutdown.log'
else
    echo '** [1D] PASS - Found "Initiating ZEROBACKLOG shutdown operation" message in log'
endif
echo
echo '# [1E] Verify that the up/down jnlpool semaphore has been removed.'
ipcs -s | $grep -w $jnlppsem >& ipcs_jnlppsem.txt
if (0 == $status) then
    echo "** [1E] FAIL - jnlpool primary semaphore ($jnlppsem) still exists after source server shutdown!"
    set fail = 1
else
    echo '** [1E] PASS - jnlpool primary semaphore was cleaned up'
endif
echo
echo '# [2A] Verify that the shutdown log file contains a REPL0BACKLOG message.'
$grep '\-S-REPL0BACKLOG' replic_src_shutdown_nts.log
if (0 != $status) then
    echo '** [2A] FAIL - REPL0BACKLOG message was not found in replic_src_shutdown.log'
    set fail = 1
else
    echo '** [2A] PASS - Found REPL0BACKLOG message in log'
endif
echo
$echoline
echo
echo '# [2B] Restart the source server'
$MUPIP replic -source -start -secondary="$HOST":"$portno" -log=SRC_START_2.log -buff=1048576 -instsecondary=INSTANCE2 -connectparams=5,500,5,0,2 >& replic_src_startup_2.log
if (0 != $status) then
    echo
    $echoline
    echo "# TEST-F-NOSRCSRVSTART Restarting of the source server failed - test terminating - cannot proceed"
    # Release our acquired port
    $gtm_tst/com/portno_release.csh
    exit 1
 endif
echo
echo '# [2C] Stop receiver server so we create an intentional backlog'
cd $secondary
source secondary_env
$MUPIP replic -receiver -shutdown -timeout=0 >& replic_receiver_shutdown_2.log
set savestatus = $status
if (0 != $savestatus) then
    echo " ** [2C] FAIL - Error shutting down receiver server - test terminating - cannot proceed (status: $savestatus)"
    # Release our acquired port
    $gtm_tst/com/portno_release.csh
    exit 1
endif
echo
echo '# [2D] Do some updates to create actual backlog'
cd $primary
source primary_env
$gtm_dist/mumps -run ^%XCMD 'kill ^a for i=1:1:10000 set ^b(i)=$justify(i,64)'
echo
echo '# [2E] Shutdown source server with parms -ZEROBACKLOG and -TIMEOUT=10 - expecting REPLBACKLOG error'
# Note the output file is logx because we expect an error here we don't need the framework to call out as well
$MUPIP replic -source -shutdown -zerobacklog -timeout=10 >& replic_src_shutdown_2.logx
set savestatus = $status
if (0 != $savestatus) then
    echo " ** [2E] FAIL - Error shutting down source server - test terminating - cannot proceed (status: $savestatus)"
    # Release our acquired port
    $gtm_tst/com/portno_release.csh
    exit 1
endif
echo
echo '# [2F] Verify that the REPLBACKLOG message exists in the shutdown log (by its appearance in reference file)'
cat replic_src_shutdown_2.logx | cut -c 28-
echo
echo '# [2G] Restart source and receiver server'
$MUPIP replic -source -start -secondary="$HOST":"$portno" -log=SRC_START_3.log -buff=1048576 -instsecondary=INSTANCE2 -connectparams=5,500,5,0,2 >& replic_src_startup_3.log
if (0 != $status) then
    echo
    $echoline
    echo "# TEST-F-NOSRCSRVSTART Restarting of the source server failed - test terminating - cannot proceed"
    # Release our acquired port
    $gtm_tst/com/portno_release.csh
    exit 1
endif
# Move to secondary
cd $secondary
source secondary_env
$MUPIP replic -receiv -start -listen=$portno -log=RCVR_START_3.log -buf=1048576 >& replic_rcvr_startup_3.log  # 1MB buffer
if (0 != $status) then
    echo
    $echoline
    echo "# TEST-F-NOSRCSRVSTART Restarting of the receiver server failed - test terminating - cannot proceed"
    # Release our acquired port
    $gtm_tst/com/portno_release.csh
    exit 1
endif
# Back to primary
cd $primary
source primary_env
echo
echo '# Wait for replication initialization to complete waiting for messages on both sides'
# Back to secondary
cd $secondary
source secondary_env
$gtm_tst/com/wait_for_log.csh -log RCVR_START_3.log.updproc -message "New History Content"
# Back to primary
cd $primary
source primary_env
echo
echo '# [2H] Shutdown the source server with parm -TIMEOUT=3601 (expect INVSHUTDOWN failure)'
# Note the output file is logx because we expect an error here we don't need the framework to call out as well
$MUPIP replic -source -zerobacklog -shutdown -timeout=3601 >& replic_src_shutdown_3.logx
if (0 == $status) then
    echo '## [2I] FAIL - command was supposed to raise INVSHUTDOWN failure'
endif
$grep '\-E-INVSHUTDOWN' replic_src_shutdown_3.logx
if (0 != $status) then
    echo '** [2I] FAIL - INVSHUTDOWN was not found in replic_src_shutdown_3.log'
    set fail = 1
else
    echo '** [2I] PASS - Found INVSHUTDOWN message in replic_src_shutdown_3.log'
endif
echo
echo '# [2J] Shutdown source server with parms -ZEROBACKLOG, -TIMEOUT=3600 (expect it to shutdown in 2 seconds or so)'
$MUPIP REPLIC -source -shutdown -zerobacklog -timeout=3600 >& replic_src_shutdown_4.log
cat replic_src_shutdown_4.log | cut -c 28- >& replic_src_shutdown_4_nts.log
if (0 != $status) then
    echo '** [2J] FAIL - shutdown of source server failed'
endif
# Pull the two lines out of the shutdown log that show (a) that the 3600 second timeout was accepted and that the
# backlog really was 0.
$grep -E "(ZEROBACKLOG|REPL0BACKLOG)" replic_src_shutdown_4_nts.log
echo
echo '# [2K] Restart source server'
$MUPIP replic -source -start -secondary="$HOST":"$portno" -log=SRC_START_5.log -buff=1048576 -instsecondary=INSTANCE2 >& replic_src_startup_5.log
if (0 != $status) then
    echo
    $echoline
    echo "# TEST-F-NOSRCSRVSTART Restarting of the source server failed - test terminating - cannot proceed"
    # Release our acquired port
    $gtm_tst/com/portno_release.csh
    exit 1
endif
set srcpid = `$gtm_tst/com/get_pid.csh src INSTANCE2`
echo
echo '# [2L] Shutdown the primary source server with the -ZEROBACKLOG option so we do not wait the full 2 mins'
$MUPIP replic -source -zerobacklog -shutdown >& replic_src_shutdown_5.log
cat replic_src_shutdown_5.log | cut -c 28- >& replic_src_shutdown_5_nts.log
echo
echo '# [2M] Verify there was a default 120 second timeout'
$grep ZEROBACKLOG replic_src_shutdown_5_nts.log
#
# Test complete - shutting down the replicated environment we built.
#
echo
$echoline
echo
echo '# [2N] Shutdown primary side source server if it is still up'
if (! `$gtm_tst/com/is_proc_alive.csh $srcpid; echo $status`) then
    echo '  ** [2N] FAIL - Shutting down source server still alive'
    $MUPIP REPLIC -source -shutdown -timeout=0 >& source_shutdown.log
else
    echo '  ** [2N] PASS - Source server is not alive so is not shut down'
endif
echo
echo '# Shutdown secondary side of replication (source server is already down)'
cd $secondary
source secondary_env
$MUPIP replic -receiver -shutdown -timeout=0 >& RCVR_SHUT.log
set savestatus = $status
if ($savestatus != 0) then
    echo "MUPIP REPLIC -RECEIVER -SHUTDOWN command failed - see RCVR_SHUT.log (rc=$savesatatus)"
endif
$MUPIP replic -source -shutdown -timeout=0 >& SRC_SHUT_PASSIVE.log
set savestatus = $status
if ($savestatus != 0) then
    echo "MUPIP REPLIC _SOURCE _SHUTDOWN command failed - see SRC_SHUT_PASSIVE.log (rc=$savestatus)"
endif
# Back to primary
cd $primary
source primary_env
echo
echo '# Verify DBs'
$MUPIP integ -file mumps.dat >& primary_integ.log
set savestatus = $status
if (0 != $savestatus) then
    echo "** FAIL - Integ of primary database failed rc = $savestatus"
endif
$MUPIP integ -file secondary/mumps.dat >& secondary_integ.log
set savestatus = $status
if (0 != $savestatus) then
    echo "** FAIL - Integ of secondary database failed rc = $savestatus"
endif
echo
$echoline
echo
echo '# Release our acquired port'
$gtm_tst/com/portno_release.csh
