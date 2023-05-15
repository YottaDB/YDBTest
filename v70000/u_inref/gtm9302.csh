#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
#
echo
echo '# Test (gtm9302) that the acknowledged sequence number shows up in -SOURCE -SHOWBACKLOG output'
echo '# and that the value is available via ^%PEEKBYNAME().'
if (! $?test_replic) then
	echo
	echo '### Test requires being invoked with -replic'
	exit 1
endif
echo
echo '# Create database - Start replication'
$gtm_tst/com/dbcreate.csh mumps 1
## Make sure the source server and receiver server complete the handshake
setenv start_time `cat start_time`
$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log RCVR_'${start_time}'.log.updproc -message "New History Content" -duration 120'
echo
echo '# Do a small amount of work to push 10,001 transactions through'
$gtm_dist/mumps -run dbInit^gtm9302
$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_dist/mumps -run waitDone^gtm9302'
echo
echo '# Need to wait heartbeat seconds (default 15) to see the acknowledged sequence number value'
sleep 16 # Sleep one sec extra
echo
echo '# Drive MUPIP REPLICATE -SOURCE -SHOWBACKLOG'
$MUPIP repl -source -showbacklog >& mupip_show_backlog.log
$grep 'sequence number acknowledged by the secondary instance' mupip_show_backlog.log
set ackseqno1 = `$tst_awk '/sequence number acknowledged by the secondary instance/ {print $1}' mupip_show_backlog.log`
echo
echo '# Show last acknowleged sequence number via ^%PEEKBYNAME() - Note that the values displayed here are the value'
echo '# returned by ^%PEEKBYNAME("gtmsource_local_struct.heartbeat_jnl_seqno",0)) but minus 1 if the value is > 0'
echo '# because that is what sr_unix/gtmsource_showbacklog.c does.'
set ackseqno2 = `$gtm_dist/mumps -run writeSeqno^gtm9302`
echo $ackseqno2
echo
echo '# Compare the sequence numbers obtained from the two source'
if ("$ackseqno1" == "$ackseqno2") then
    echo "PASS - the two sequence numbers are the same"
else
    echo "FAIL - the two sequence numbers differ: backlog: $ackseqno1  peekbyname: $ackseqno2"
endif
echo
echo '# Verify database'
$gtm_tst/com/dbcheck.csh
