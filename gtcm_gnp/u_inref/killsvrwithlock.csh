#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test is for the case:
# On the server (2) side, there is a process holding a lock (^b)
# The client starts waiting on the lock.
# The GT.CM server is killed
# 	client should error out
# GT.CM server is restarted
# client retries the lock. (no success)
# Server side process releases lock
# client gets the lock

source $gtm_tst/com/dbcreate.csh . 4
# lock ^b on one server
# region REGB is always going to be on server 2
($rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; "'$gtm_exe/mumps'" -run lockb </dev/null  >& lockb.out" & )
$rsh $tst_remote_host_2  "cd $SEC_DIR_GTCM_2;$gtm_tst/$tst/u_inref/lke_check.csh $gtm_tst $SEC_DIR_GTCM_2 2 b yes"
if ( "0" != $status)  then
	echo "$tst_remote_host_2 could not lock ^b. Cannot continue testing"
	$gtm_tst/com/dbcheck.csh
	exit
endif

#client tries to get the lock
$gtm_exe/mumps -run lbcl </dev/null >& lockb_on_client.log &
set gtmps = $!

#wait for the trylockb.out
$gtm_tst/com/wait_for_log.csh -log trylockb.out -waitcreation -duration 300
set wait_status = $status
#
if ($wait_status) then
	echo "TEST-E-Timeout, client process lbcl timed out"
	echo "Release lock on the server side..."
	$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2; cd $SEC_DIR_GTCM_2; "'$gtm_exe/mumps'" -run releb"
	sleep 20 # give them some time to exit
	$gtm_tst/com/dbcheck.csh
	exit
endif

# kill server
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2;  $gtm_tst/$tst/u_inref/gtcm_server_crash.csh"

# check clients response
$gtm_tst/com/wait_for_proc_to_die.csh $gtmps 300
set killst = $status

if (0 != $killst) then
        echo "`date` TEST-E-TIMEOUT Waited for 300 seconds for $gtmps to die"
        echo "Client did not stop though server crashed."
	echo "The test will exit without cleaning up"
	$psuser
        exit
endif

cat lockb_on_client.log

# restart server
echo "Re-start the server (on $tst_remote_host_2)"
setenv start_time `date +%H_%M_%S`
setenv portno_gtcm `$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ;cd $SEC_DIR_GTCM_2;source $gtm_tst/com/portno_acquire.csh"`
if (-e gtcm_portno_2.txt) mv gtcm_portno_2.txt  gtcm_portno_2.txt_`date +%H_%M_%S`
echo $portno_gtcm >&! gtcm_portno_2.txt
set rmthost = ${tst_remote_host_2:ar}
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_cm_${rmthost} GTCM_${rmthost} "[${tst_remote_host_2}]:$portno_gtcm"
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; $gtm_tst/com/GTCM_SERVER.csh $portno_gtcm $start_time >&! $SEC_DIR_GTCM_2/gtcm_start_${start_time}.out"

echo "GT.CM Server up again, retry the lock (the lock is still held on the server side)..."
# client tries again (no success)
$GTM << GTM_EOF
l ^b:10
s stat=\$T
if (stat) w "How did I get this lock???",!
if ('stat) w "Could not get the lock, just as expected",!
h
GTM_EOF

# release lock on the server side
echo "Release lock on the server side..."
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2; cd $SEC_DIR_GTCM_2; "'$gtm_exe/mumps'" -run releb"
sleep 20 # give them some time to exit

echo "Retry the lock on the client side now..."
# client should get it now.
$GTM << GTM_EOF
l ^b:10
s stat=\$T
if (stat) w "I got the lock, as expected",!
if ('stat) w "FAILED. Could not get the lock!.",!
h
GTM_EOF

$gtm_tst/com/dbcheck.csh
