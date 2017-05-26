#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv gtm_trigger_etrap 'do error^replicerrors'
setenv gtm_test_autorollback FALSE
$gtm_tst/com/dbcreate.csh mumps 5 >&! dbcreate1.out

set timestamp1 = `cat $PRI_DIR/start_time`

env avoiderror=1 $gtm_dist/mumps -run replicerrors

echo "# Wait for the update process to exit"
$gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_$timestamp1.log.updproc -message "Update process exiting" -duration 60

echo "# Shut down the secondary and restart it with protection"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replic -receiv -shut -time=0 < /dev/null >>&! $SEC_SIDE/SHUT_${timestamp1}.out"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replic -source -shut -time=0 < /dev/null >>&! $SEC_SIDE/SHUT_${timestamp1}.out"
sleep 1	# make sure time chosen below is different from $timestamp1
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv timestamp2 `date +%H_%M_%S`
# Let the update process avoid the DIVZERO error
setenv avoiderror 1
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh "." $portno $timestamp2 < /dev/null "">>&!"" $SEC_SIDE/START_${timestamp2}.out"

$gtm_tst/com/dbcheck.csh -extract >&! dbcheck1.out

