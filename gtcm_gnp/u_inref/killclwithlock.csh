#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test is for the case:

source $gtm_tst/com/dbcreate.csh . 4

echo "# First lock ^b from the client side..."
$gtm_exe/mumps -run lbcl </dev/null >& lockb_on_client.log &
set pid = $!
#check that the client side process has locked ^b
$gtm_exe/mumps -run chcklb > check_lock_b.out
$grep FAIL check_lock_b.out
if !($status) then
	echo "%TEST-E-TIMEOUTLB Waited too long for client to lock ^b. FAILED. Exiting"
	$gtm_exe/mumps -run releb
	sleep 20
	$gtm_tst/com/dbcheck.csh
	exit
else
	$grep OK check_lock_b.out
endif

# lock ^b on one server
# region REGB is always going to be on server 2
echo "# Now start the server side process..."
($rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; "'$gtm_exe'"/mumps -run lbsvr2 </dev/null >& lbsvr2.out " &) > lockb.out

echo "# Check that it indeed cannot lock ^b..."
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; $gtm_tst/com/wait_for_log.csh -log lbsvr2.out -message 'LOCK STATUS:0' -waitcreation -grep -duration 600 >& lockb_status.out"
$rcp "$tst_remote_host_2":"$SEC_DIR_GTCM_2/lockb_status.out" "lockb_status.out"
$grep "LOCK STATUS:0" lockb_status.out > /dev/null
if ($status) then
	echo "%TEST-E-LOCKREMOTE2"
	echo "Lock status from remote host 2:"
	cat lockb_status.out
	echo "error from $tst_remote_host_2. FAILED. Cannot continue testing."
	#kill client side process
	$gtm_exe/mumps -run releb
	sleep 20
	$gtm_tst/com/dbcheck.csh
	exit
else
	echo "# As expected server side process could not lock ^b:"
	cat lockb_status.out
endif

# kill the client side process
echo "# Kill client side process holding the lock..."
$kill9 $pid
echo "# Done:"

# server side process should get the lock now:
echo "# Server side process should get the lock now..."
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2 ; grep LOCK2 lbsvr2.out; grep OK2 lbsvr2.out; grep FAIL2 lbsvr2.out" # BYPASSOK grep on other side would point to a different path and fail if it expands here

# clean up relinkctl shared memory
$MUPIP rundown -relinkctl >&! mupip_rundown_rctl.logx

$gtm_tst/com/dbcheck.csh
