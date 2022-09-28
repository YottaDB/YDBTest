#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test to verify when the source server has a name resolution failure, it gives more information (specifically'
echo '# the node name) and is more persistent about retrying the resolution until it succeeds or is stopped.'
# Starting the source server has two processes attached to shared memory for a short time so a gtm_db_counter_sem_incr value
# causes an intermittent counter overflow. Unset this envvar to prevent counter overflows.
unsetenv gtm_db_counter_sem_incr
echo
echo "# Set up half of a replicated environment. We won't really use the other side as this issue is tested when the"
echo '# configuration is rather borked since we are attempting to connect to a bogus host.'
$ydb_dist/yottadb -run GDE E   # Create GDE file
$MUPIP create
setenv ydb_repl_instname "INSTANCE1"
setenv ydb_repl_instance "gtm9157.repl"
$MUPIP set -replication=on -region "DEFAULT"
$MUPIP replicate -instance_create -noreplace -name=INSTANCE1
echo
echo "# Obtain a usable port number"
source $gtm_tst/com/portno_acquire.csh >>& portno.out
echo
echo '# Now, start up a replication source server to a node that does not exist. We should continue to run until we'
echo '# stop it and the name should show up in the messages. Also set reconnect attempt duration to 2 seconds to'
echo '# drop the number of retries per second to avoid flooding source server log. Note while we use -CONNECTPARAMS'
echo '# option to make the source log smaller by increasing the time periods for hard retries as well as making the'
echo '# soft retry shorter so we test generate some of the messages that were incorrect, we do not have a good way'
echo '# of validating them. See discussion of this at https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1412#note_991497600'
# Note - source log is a logx filetype to keep the framework from scanning the file which has an indeterminite number
# of GETADDRINFO messages in it. It depends on how fast the source server is shutdown as to how many of them appear.
$MUPIP replic -source -start -secondary=bogushost:${portno} -log=src.logx -buff=256 -instsecondary=INSTANCE2 -connectparams=5,1000,2,2,15,60
if (0 != $status) then
    echo
    $echoline
    echo "# TEST-F-NOSRCSRVSTART Starting of the source server failed - test terminating - cannot proceed"
    # Release our acquired port
    $gtm_tst/com/portno_release.csh
    exit 1
endif
echo
echo '# Wait for GETADDRINFO message to appear in src.logx'
$gtm_tst/com/wait_for_log.csh -log src.logx -message "GETADDRINFO" -duration 90
set waitForLogStatus = $status
if (0 == $waitForLogStatus) then
    echo "## GETADDRINFO message seen"
    echo
    echo '# Verify that not only did we see the GETADDRINFO message but this came out as a 3 message bundle with the secondary'
    echo '# system name mentioned in this bundle of messages.'
    $grep -m 1 -A 2 GETADDRINFO src.logx
    echo
    echo '# We know we have at least one GETADDRINFO message to indicate the condition has been detected. Now wait for'
    echo '# a second and third GETADDRINFO message to show the server being more resilient about this error.'
    $gtm_tst/com/wait_for_log.csh -log src.logx -message "GETADDRINFO" -duration 90 -count 3
    if (0 == $status) echo "## 3 or more GETADDRINFO messages seen"
    echo
    echo '# Verify source server is *still* alive'
    $MUPIP replicate -source -checkhealth
    echo
    echo '# Shutting down the source server'
    # Note just prior to invoking the source server shutdown, randomly (just 30% of time) invoke a 10 second sleep which will get
    # us past the hardspin loop and into the softspin loop to verify its correct operation as well.
    if (1 == `$gtm_dist/mumps -run ^%XCMD 'write $random(10)>6'`) sleep 10s
    $MUPIP replic -source -shutdown -timeout=0 >& SRC_SHUTDOWN.log
else
    # No need to print the return code here as wait_for_log would already have printed the needed messages. Just say we're
    # exiting and we're done!
    echo
    $echoline
    echo "## Failed to find GETADDRINFO in the log. Suspect possible issue with the source server starting"
    $echoline
    echo
    # Fall into cleanup and exit
endif
# Release our acquired port
$gtm_tst/com/portno_release.csh
# Integ our database. We didn't really use it but verify it anyway. Don't use com/dbcheck.csh here as it tries to talk
# to "the other side" of our replication setup which was never configured or started.
echo
$echoline
echo "# Verify DB on our side is still OK"
echo "#"
$MUPIP integ -reg "DEFAULT"
