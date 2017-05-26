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
# TEST CASE #78: test that the virtual end caused by rollback can be caught by secondary side. (03/28/2003)
#
$gtm_tst/com/dbcreate.csh mumps
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
#stop the receiver server
echo "# Force the receiver shut down"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_${start_time}.log.updproc -message 'New History Content' -duration 120"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>& $SEC_SIDE/SHUT_${start_time}.out"
#
$GTM << gtm_eof
	f i=1:1:40 s ^a(i)="a"_i
	zsy "\$DSE buff"
	f i=41:1:100 s ^a(i)="a"_i
gtm_eof
#
echo "# Stop source server for rollback"
$gtm_tst/com/SRC_SHUT.csh "." >>& SHUT_${start_time}.out
#
#rollback the database
echo "********************"
echo "Rolling back ... "
echo "********************"
$gtm_tst/com/mupip_rollback.csh -resync=51 -lost=glo.lost "*" >>& rollback.log
set stat1=$status
$grep "Rollback successful" rollback.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0) then
	echo "Virtual file end test failed"
	cat rollback.log
	exit 1
endif
#start the source server
echo "# Starting source server from rollback"
setenv start_time2 `date +%H_%M_%S`
$gtm_tst/com/SRC.csh "." $portno $start_time2 >&! SRC_${start_time2}.out
#do more database updates
echo "# Do more database updates"
$GTM << gtm_eof
	f i=51:1:100 s ^a(i)="newa"_i
gtm_eof
#
#Force the source server to shut down
echo "# Force the source server down"
$gtm_tst/com/SRC_SHUT.csh "." >>& SHUT_${start_time}.out
#
# RF_START below will pickup fresh port. So release the port reservation file used until now
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/portno_release.csh"
echo "# Now bring up both servers"
$gtm_tst/com/RF_START.csh
echo "# Shutdown the servers and compare the db extracts on both the sides"
$gtm_tst/com/dbcheck.csh -extract
