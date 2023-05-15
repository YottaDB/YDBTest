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
# Verify we can terminate a MUPIP REPLIC -SOURCE -SHUTDOWN command during its wait with a ^C
#
if (! $?test_replic) then
	echo '### Test requires being invoked with -replic'
	exit 1
endif
#
echo '# gtm9368 - Verify we can interrupt/stop a MUPIP REPLIC -SOURCE -SHUTDOWN command during its wait period with ^C'
echo
echo '# Run dbcreate.csh'       # Should configure and start up replication
$gtm_tst/com/dbcreate.csh mumps 1 255 1000 1024 500 128 500
echo
echo '# Start some constant DB activity creating, updating, and removing lots of nodes so replication has more of a chance'
echo '# of having a non-zero backlog'
$gtm_tst/com/imptp.csh >>&! imptp.out
echo
echo '# We want to send a ^C to the source server while it is shutting down - figure out which process that is'
set srcpid = `$gtm_tst/com/get_pid.csh "src"`
echo "srcpid $srcpid" >> gtm9368_dbg.txt
#
# Run this ^C/shutdown loop twice - once without specifying -zerobacklog and once with it. First time through we use
# only the first of the following options while the second time we use both. We do it this way as "foreach" doesn't
# allow a null string to be specified the first time and -zerobacklog the second time.
#
set options = `echo "-timeout=95 -zerobacklog"`
foreach shutoptidx ( 1 2 )
    echo
    echo "###### Iteration #${shutoptidx} using options ${options[1-$shutoptidx]}"
    echo
    echo '# Start the shutdown for the SRC server - have it wait for a significant bit so we have a good interruption window'
    set opts = "${options[1-$shutoptidx]}"
    set shutpid = `($MUPIP replicate -source -shutdown ${opts} >& mupip_source_shutdown${shutoptidx}.logx&; set pid=$!; echo $pid)`
    echo "shutpidorig${shutoptidx}: $shutpid" >> gtm9368_dbg.txt
    set shutpid = $shutpid[2]  # Extract actual PID from reply of form '[1] <pid> <pid>'
    echo "shutpid${shutoptidx}:     $shutpid" >> gtm9368_dbg.txt
    ps -ef | grep $shutpid >> gtm9368_dbg.txt
    echo
    echo '# Now send the ^C to the MUPIP REPLIC -SOURCE -SHUTDOWN command while the shutdown is pending - But sleep'
    echo '# for 5 seconds first so shutdown command starts sleeping'
    sleep 5 # Wait for mupip command to get going
    kill -INT $shutpid
    echo
    echo '# Start waiting for the MUPIP REPLIC -SOURCE -SHUTDOWN process to die'
    set wait_start = `$gtm_dist/mumps -run ^%XCMD 'write $H'`
    sleep 1 # Make sure $wait_elapsed is non-zero
    $gtm_tst/com/wait_for_proc_to_die.csh $shutpid 200 # Wait for process to completely stop
    set wait_end = `$gtm_dist/mumps -run ^%XCMD 'write $H'`
    set wait_elapsed = `$gtm_dist/mumps -run ^%XCMD 'write $$^difftime("'$wait_end'","'$wait_start'"),!'`
    echo
    echo '# Copy the shutdown log into the reference file - Note this file is a logx instead of log to keep the test'
    echo '# framework from making an error out of the MUNOFINISH error which is expected'
    cat mupip_source_shutdown${shutoptidx}.logx
    #
    # Max timeout is 95 (max sleep) - 5 (actual sleep) = 90 seconds. If we took more than 10 seconds, then we weren't paying attention
    # to ^C interrupting the shutdown process. Note prior version had a 30 max/default sleep so fails in about 27 seconds.
    #
    echo
    echo "# See if we managed to cancel the shutdown with our ^C in a timely manner"
    if ($wait_elapsed > 10) then
	echo "***** FAIL: Elapsed wait of $wait_elapsed seconds indicates the ^C shutdown of the source server did not work"
    else  if ($wait_elapsed > 0) then
	echo "PASS - Elapsed wait of $wait_elapsed second(s) - ^C seems to have been recognized by the MUPIP REPLIC -SOURCE -SHUTDOWN command"
    endif
end
echo
echo '# Shutdown imptp background processes'
$gtm_tst/com/endtp.csh >>&! endtp.out
echo
echo '# Validate DBs and verify they are the same'
$gtm_tst/com/dbcheck.csh -extract
