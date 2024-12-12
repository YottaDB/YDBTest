#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
#
$gtm_tst/com/dbcreate.csh mumps 5 125 1000
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
$MUPIP set -journal=enable,on,before,epoch=30 -reg AREG
$MUPIP set -journal=enable,on,before,epoch=30 -reg BREG
$MUPIP set -journal=enable,on,before,epoch=30 -reg CREG
$MUPIP set -journal=enable,on,before,epoch=30 -reg DREG
$MUPIP set -journal=enable,on,before,epoch=30 -reg DEFAULT
#
echo "GTM Process starts "
$GTM << xyz
d allreg1^d9e02447
halt
xyz
$GTM << xyz
d allreg2^d9e02447
halt
xyz
$gtm_tst/com/RF_sync.csh
setenv start_time `date +%H_%M_%S`
echo "Shutdown RCVR..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh "." < /dev/null "">>&!"" $SEC_SIDE/RCVR_SHUT_${start_time}.out"
echo "Restart RCVR..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh "." $portno $start_time < /dev/null "">>&!"" $SEC_SIDE/RCVR_START_${start_time}.out"
$GTM << xyz
;d allreg2^d9e02447	; Work around of the TR in V4.4002 to V4.4-004
d partial^d9e02447	; Updates only some regions
halt
xyz
#
sleep 70
$gtm_tst/com/RF_sync.csh
setenv start_time `date +%H_%M_%S`
echo "SRC SHUT..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC_SHUT.csh ""."" < /dev/null >>&! $PRI_SIDE/SRC_SHUT_${start_time}.out"
#
if ($?test_debug) then
	$gtm_tst/com/backup_dbjnl.csh bak1 '*.dat *.mjl* *.gld' cp nozip
endif
setenv tst_seqno 9000
echo "$gtm_tst/com/mupip_rollback.csh -resync=$tst_seqno -verbose -losttrans=lost1.glo " >>&! rollback1.log
$gtm_tst/com/mupip_rollback.csh -resync=$tst_seqno -verbose -losttrans=lost1.glo "*" >>&! rollback1.log
#
echo "RCVR SHUT..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh "." < /dev/null "">>&!"" $SEC_SIDE/RCVR_SHUT_${start_time}.out"
#
echo "SRC START..."
setenv start_time `date +%H_%M_%S`
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh "." $portno $start_time < /dev/null "">>&!"" START_${start_time}.out"
#
echo "Rollback on coming secondary (B):"
if ($?test_debug) then
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/backup_dbjnl.csh bak2 '*.dat *.mjl *.gld*' cp nozip"
endif
$sec_shell "echo portno=$portno"">>&!"" $SEC_DIR/env.txt"
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'echo $gtm_tst/com/mupip_rollback.csh -fetchresync=$portno -verbose -losttrans=fetch.glo  >>&! rollback2.log'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$gtm_tst/com/mupip_rollback.csh -fetchresync=$portno -verbose -losttrans=fetch.glo "*" >>&! rollback2.log; $grep "successful" rollback2.log'
#
setenv start_time `date +%H_%M_%S`
echo "Restarting Secondary (B)..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh "." $portno $start_time < /dev/null "">>&!"" $SEC_SIDE/START_${start_time}.out"
$GTM << xyz
d allreg2^d9e02447
d partial^d9e02447	; Updates only some regions
d verify^d9e02447
halt
xyz
#
$gtm_tst/com/dbcheck.csh -extract
