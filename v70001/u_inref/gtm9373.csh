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
GTM-9373 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-001_Release_Notes.html#GTM-9373)

MUPIP REPLICATE -SOURCE -SHOWBACKLOG considers a transaction as backlogged until it is acknowledged
from the Receiver Server. The SRCBACKLOGSTATUS message reports whether a Receiver Server is behind,
ahead, or has not yet acknowledged the transactions. The LASTTRANS message reports the state (posted,
sent, or acknowledged) of the Source Server transactions under replication. Previously, the MUPIP
REPLICATE -SOURCE -SHOWBACKLOG did not display the SRCBACKLOGSTATUS and LASTTRANS messages, did not
consider in-flight transactions as a backlog and did not report when the replicating instance was
ahead during conditions such as online rollback. (GTM-9373)

********************************************************************************************
CAT_EOF

set heartbeat = 32	# seconds

echo
echo "# In order to keep test runtime to a minimum, this test uses a small heartbeat period of $heartbeat seconds"
echo '# We expect events to happen in this short period of time at various stages of this test.'
echo '# This is too small a time period for the ARM systems and hence this subtest is disabled there'
echo

echo "# Set heartbeat period as $heartbeat seconds in -CONNECTPARAMS qualifier passed to [mupip replic -source -start]"
echo "# Do this by setting [gtm_test_src_connectparams] env var to [-connectparams=5,500,5,0,$heartbeat,60]"
setenv gtm_test_src_connectparams "-connectparams=5,500,5,0,$heartbeat,60"
echo

echo '# Since we do online rollback on source side, pass -AUTOROLLBACK to [mupip replic -receiver -start]'
echo '# Do this by setting [gtm_test_autorollback] env var to [TRUE]'
setenv gtm_test_autorollback "TRUE"          # Receiver server will terminate without -autorollback
echo

source $gtm_tst/com/gtm_test_setbeforeimage.csh	# ROLLBACK needs before image journaling for backward recovery

echo '# Run [dbcreate.csh] to create database and start replication servers on source and receiver side'
$gtm_tst/com/dbcreate.csh mumps

echo
echo '# Run [mupip replic -source -showbacklog]'
echo '# Verify LASTTRANS messages show posted/sent/acknowledged sequence number as 0'
echo '# Verify SRCBACKLOGSTATUS message shows [has not acknowledged 0 transaction(s)]'
$MUPIP replic -source -showbacklog

echo
echo '# Perform 100 updates on INST1'
$gtm_dist/mumps -run %XCMD 'for i=1:1:100 set ^x(i)=i'

echo
echo '# Wait for source side backlog to become 0'
$gtm_tst/com/wait_until_src_backlog_below.csh 0

echo
echo '# Run [mupip replic -source -showbacklog]'
echo '# Verify LASTTRANS messages show posted/sent as 100 AND acknowledged as 0'
echo '# Verify SRCBACKLOGSTATUS message shows [has not acknowledged 0 transaction(s)]'
$MUPIP replic -source -showbacklog

echo
echo "# Sleep $heartbeat + 1 seconds (heartbeat period + 1 second for some slack)."
echo '# Run [mupip replic -source -showbacklog]'
echo '# We expect [has not acknowledged] to change into [is behind by].'
echo '# Verify LASTTRANS messages show posted/sent/acknowledged sequence number as 100'
echo '# Verify SRCBACKLOGSTATUS message shows [is behind by 0 transaction(s)]'
sleep `expr $heartbeat + 1`
$MUPIP replic -source -showbacklog

set posted = 100
set sent = 100
set acknowledged = 100

echo
echo '# Start background updates'
$gtm_dist/mumps -run startbgupdates^gtm9373

echo
echo "# Wait until acknowledged number increases from its current value"
$gtm_dist/mumps -run waitAcknowledgedIncrease^gtm9373 $acknowledged

set backlogfile = "backlog2.out"
echo "# Run [mupip replic -source -showbacklog] : Output in [$backlogfile]"
$MUPIP replic -source -showbacklog >& $backlogfile

echo
echo '# Stop background updates'
$gtm_dist/mumps -run endbgupdates^gtm9373

echo '# We now expect posted/sent/acknowledged to all have increased.'
echo '# Verify LASTTRANS messages show posted/sent/acknowledged sequence number ALL to be GREATER THAN 100'
set posted2 = `$grep posted $backlogfile | awk '{print $NF}'`
set sent2 = `$grep sent $backlogfile | awk '{print $NF}'`
set acknowledged2 = `$grep acknowledged $backlogfile | awk '{print $NF}'`

if ($posted2 <= $posted) then
	echo "TEST-E-FAIL : posted2 [= $posted2] is not greater than posted [= $posted]"
else if ($sent2 <= $sent) then
	echo "TEST-E-FAIL : sent2 [= $sent2] is not greater than sent [= $sent]"
else if ($acknowledged2 <= $acknowledged) then
	echo "TEST-E-FAIL : acknowledged2 [= $acknowledged2] is not greater than acknowledged [= $acknowledged]"
else
	echo "PASS"
endif

echo '# Verify acknowledged <= sent <= posted'
if ($acknowledged2 > $sent2) then
	echo "TEST-E-FAIL : acknowledged2 [= $acknowledged2] is greater than sent2 [= $sent2]"
else if ($sent2 > $posted2) then
	echo "TEST-E-FAIL : sent2 [= $sent2] is greater than posted2 [= $posted2]"
else
	echo "PASS"
endif

echo '# Verify SRCBACKLOGSTATUS indicates [is behind by]'
$grep SRCBACKLOGSTATUS $backlogfile
set behind2 = `grep behind $backlogfile | awk '{print $7}'`

echo '# Verify acknowledged + behind = posted'
if ($acknowledged2 + $behind2 != $posted2) then
	echo "TEST-E-FAIL : acknowledged2 [= $acknowledged2] + behind2 [= $behind2] is not equal to posted2 [= $posted2]"
else
	echo "PASS"
endif

echo
echo '# Wait until backlog is 0 on both source and receiver side'
$gtm_tst/com/RF_sync.csh

echo "# Sleep $heartbeat seconds (heartbeat period). To ensure [acknowledged] is updated by receiver on source side in one heartbeat"
sleep $heartbeat

echo
set backlogfile = "backlog3.out"
echo "# Run [mupip replic -source -showbacklog] : Output in [$backlogfile]"
$MUPIP replic -source -showbacklog >& $backlogfile
echo '# Verify LASTTRANS messages show posted/sent/acknowledged as the same value (let us say N)'
set posted3 = `$grep posted $backlogfile | awk '{print $NF}'`
set sent3 = `$grep sent $backlogfile | awk '{print $NF}'`
set acknowledged3 = `$grep acknowledged $backlogfile | awk '{print $NF}'`
if ($posted3 != $sent3) then
	echo "TEST-E-FAIL : posted3 [= $posted3] is not equal to sent3 [= $sent3]"
else if ($posted3 != $acknowledged3) then
	echo "TEST-E-FAIL : posted3 [= $posted3] is not equal to acknowledged3 [= $acknowledged3]"
else
	echo "PASS"
endif

echo '# Verify SRCBACKLOGSTATUS indicates [is behind by 0 transaction(s)]'
$grep SRCBACKLOGSTATUS $backlogfile

echo
echo '# Run [mupip journal -rollback -online -back -resync=101 "*"] to roll INST1 back to seqno=101'
$gtm_dist/mupip journal -rollback -online -back -resync=101 "*" >& rollback.out

echo
set backlogfile = "backlog4.out"
echo "# Run [mupip replic -source -showbacklog] : Output in [$backlogfile]"
$MUPIP replic -source -showbacklog >& $backlogfile
set posted4 = `$grep posted $backlogfile | awk '{print $NF}'`
set sent4 = `$grep sent $backlogfile | awk '{print $NF}'`
set acknowledged4 = `$grep acknowledged $backlogfile | awk '{print $NF}'`
echo '# Verify posted is 100'
if ($posted4 != 100) then
	echo "TEST-E-FAIL : posted4 [= $posted4] is not equal to 100"
else
	echo "PASS"
endif
echo '# Verify sent is 100 or N'
if (($sent4 != 100) && ($sent4 != $posted3)) then
	echo "TEST-E-FAIL : sent4 [= $sent4] is not equal to 100 or N [= $posted3]"
else
	echo "PASS"
endif
echo '# Verify acknowledged is N'
if (($acknowledged4 != $posted3)) then
	echo "TEST-E-FAIL : acknowledged4 [= $acknowledged4] is not equal to N [= $posted3]"
else
	echo "PASS"
endif
echo '# Verify SRCBACKLOGSTATUS message indicates [is ahead by] due to the online rollback'
$grep SRCBACKLOGSTATUS $backlogfile
echo '# Verify SRCBACKLOGSTATUS message indicates ahead by N-100 transaction(s)'
set aheadby = `grep ahead $backlogfile | awk '{print $7}'`
if ($aheadby + 100 != $posted3) then
	echo "TEST-E-FAIL : ahead by [= $aheadby] is not equal to N [= $posted3] + 100"
else
	echo "PASS"
endif

echo
echo '# Wait until receiver server has also done online rollback and reconnected to source server'
echo '# Note: The history record would have a [Cycle = 2] in it so wait for that to show up in the receiver server log'
setenv start_time `cat start_time`
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_${start_time}.log -message 'New History Content.*Cycle = \[2\]' -duration 120"

echo "# Sleep $heartbeat seconds (heartbeat period). To ensure [acknowledged] is updated by receiver on source side in one heartbeat"
sleep $heartbeat

echo
echo '# Run a final [mupip replic -source -showbacklog]'
echo '# Verify LASTTRANS messages show posted/sent/acknowledged sequence number as 100'
echo '# Verify SRCBACKLOGSTATUS message shows [is behind by 0 transaction(s)]'
$MUPIP replic -source -showbacklog

echo
echo '# Run [dbcheck.csh] to integ database and shut replication servers on source and receiver side'
$gtm_tst/com/dbcheck.csh

