#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# gtm7398.csh
# this test has jnl extract output, so let's not change the tn
setenv gtm_test_disable_randomdbtn
setenv gtm_test_mupip_set_version "disable"
setenv gtm_tst_ext_filter_rcvr "$gtm_exe/mumps -run ^extfilter"
source $gtm_tst/com/gtm_test_setbeforeimage.csh         # We need BEFORE IMAGE journaling for ROLLBACK (done below)
setenv tst_jnl_str "-journal=enable,on,before,epoch=300"
$gtm_tst/com/dbcreate.csh mumps 3
setenv timestamp1 `cat start_time`
$sec_shell '$sec_getenv ; cd $SEC_SIDE ; $gtm_tst/com/abs_time.csh time1 >& time1.log'	# Note down time for later -since usage
$gtm_dist/mumps -run gtm7398
# wait up to 4 minutes for updates to the secondary to be complete
$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/sec_updates.csh WAIT'

# crash secondary so we can make rollback come back to the NULL record in its backward processing
# RECEIVER SIDE (B) CRASH
$gtm_tst/com/rfstatus.csh "BEFORE_SEC_B_CRASH:"
$sec_shell "$sec_getenv; $gtm_tst/com/receiver_crash.csh"

echo "Source shut down ..."
echo
$gtm_tst/com/SRC_SHUT.csh "." >>& SHUT_${timestamp1}.out

echo "Run down on secondary"
echo
$sec_shell '$sec_getenv; cd $SEC_SIDE; $MUPIP rundown -override -reg "*" < /dev/null >>&! $SEC_SIDE/SHUT_'"${timestamp1}"'.out'

echo "Do extract on secondary before rollback"
echo
$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/sec_updates.csh EXTRACT >>&! $SEC_SIDE/first_extract.out'

echo "The NULL record jnl_seqno is:"
$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/sec_updates.csh GETJNLSEQNO'
echo
echo "Make mjf and bak directories on secondary and save files"
echo
$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/sec_updates.csh SAVEOUTPUT'

echo "Do a journal rollback on secondary"
echo
$sec_shell '$sec_getenv; cd $SEC_SIDE; set time1 = `cat time1_abs`; $gtm_tst/com/mupip_rollback.csh -verbose -since=\"$time1\" -lost=x.los "*" >>&! rollback.log; $grep "successful" rollback.log'

echo
echo "Do extract on secondary after rollback"
echo
$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/sec_updates.csh EXTRACT >>&! $SEC_SIDE/second_extract.out'

echo "The NULL record jnl_seqno is:"
$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/sec_updates.csh GETJNLSEQNO'
echo

$sec_shell "$sec_getenv ; cd $SEC_SIDE; source $gtm_tst/com/portno_release.csh"
$gtm_tst/com/dbcheck_filter.csh -noshut
