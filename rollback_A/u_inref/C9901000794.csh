#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST : JOURNAL FILE ROLLBACK(03/17/2003)
#
#
$gtm_tst/com/dbcreate.csh mumps
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
echo "Start M process"
#
$GTM << gtm_eof
	d set1^c000794
gtm_eof
#
# Do RF_sync. If not done, it can lead to REPLBRKNTRANS. See <REPLBRKNTRANS_duetonosync>
$gtm_tst/com/RF_sync.csh
#now stop the replication servers
echo "Receiver shut down ..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>& $SEC_SIDE/SHUT_${start_time}.out"
echo "Source shut down ..."
$gtm_tst/com/SRC_SHUT.csh "." >>& SHUT_${start_time}.out
#
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before copying databases in a quiescent state.
$MUPIP set -replication=off -reg "*"
$MUPIP set -journal=off,enable,before -reg "*"
#now start the replication servers
setenv start_time `date +%H_%M_%S`
echo "Starting receiver server ..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh ""on"" $portno $start_time < /dev/null "">&!"" $SEC_SIDE/RCVR_${start_time}.out"
echo "Starting source server ..."
$gtm_tst/com/SRC.csh "on" $portno $start_time >&! SRC_${start_time}.out
#
$GTM << gtm_eof2
	d set2^c000794
gtm_eof2
#
#
#now stop the replication servers
echo "Receiver shut down ..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>& $SEC_SIDE/SHUT_${start_time}.out"
echo "Source shut down ..."
$gtm_tst/com/SRC_SHUT.csh "." >>& SHUT_${start_time}.out
#
cd $PRI_SIDE
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
mkdir ./save
cp mumps.* ./save
#rollback the database
echo "Rolling back on primary side "
$gtm_tst/com/mupip_rollback.csh -resync=50 -back -lost=lost.glo "*"
set stat1=$status
#
cd $PRI_SIDE
echo "*********************************"
echo "Backward recovery on primary side"
echo "*********************************"
cp ./save/*.* .
set time1=`cat time1.txt`
set time2=`cat time2.txt`
$MUPIP journal -recov -back -since=\"$time1\" mumps.mjl
set stat3=$status
#
echo "PASS"
$gtm_tst/com/dbcheck.csh -noshut
$gtm_tst/com/portno_release.csh
