#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004-2015 Fidelity National Information		#
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
echo "Test :: C9E03-002539 source server fails to read non-tp logical record after align record"
$gtm_tst/com/dbcreate.csh mumps 5 255 140000 8192
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
$MUPIP set -journal=enable,on,before,epoch=30,align=4096 -reg AREG
$MUPIP set -journal=enable,on,before,epoch=30,align=4096 -reg BREG
$MUPIP set -journal=enable,on,before,epoch=30,align=4096 -reg CREG
$MUPIP set -journal=enable,on,before,epoch=30,align=4096 -reg DREG
$MUPIP set -journal=enable,on,before,epoch=30,align=8192 -reg DEFAULT

echo "GTM Process will do some updates"
$GTM << xyz
do main^c9002539
halt
xyz
$gtm_tst/com/RF_sync.csh
#
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC_SHUT.csh ""."" < /dev/null >>&! $PRI_SIDE/SHUT_${start_time}.out"
#
if ($?test_debug) then
	$pri_shell "cd $PRI_SIDE; $gtm_tst/com/backup_dbjnl.csh bak1 '*.dat *.mjl*' cp nozip"
endif

# See comments in c9002539.m how resync=126 and -resync=41 are chosen
echo "Do rollback in primary side..."
echo "$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo -resync=126 '*' " >>&! rollback1.log
$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo -resync=126 "*" >>&! rollback1.log
$grep "successful" rollback1.log
#
if ($?test_debug) then
	$sec_shell "cd $SEC_SIDE; $gtm_tst/com/backup_dbjnl.csh bak2 '*.dat *.mjl*' cp nozip"
endif
#
echo "Do rollback in secondary side..."
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'echo $gtm_tst/com/mupip_rollback.csh -losttrans=lost2.glo -resync=41 >>&! rollback2.log'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$gtm_tst/com/mupip_rollback.csh -losttrans=lost2.glo "*" -resync=41  >>&! rollback2.log; $grep "successful" rollback2.log'
#
ls -lart >>& show_head.out
$MUPIP journal -show=head -for "*" >>& show_head.out # bypassok
setenv start_time `date +%H_%M_%S`
echo "Restarting Secondary (B)..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh "." $portno $start_time < /dev/null "">>&!"" $SEC_SIDE/START_${start_time}.out"
#
echo "Restarting Primary (A)..."
$gtm_tst/com/SRC.csh "." $portno $start_time >& START_${start_time}.out
#
echo "Verify:"
$GTM << xyz
do verify^c9002539(16)
halt
xyz
$gtm_tst/com/dbcheck.csh -extract
