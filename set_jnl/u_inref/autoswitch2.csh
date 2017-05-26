#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps 1 255 1000 -allocation=2048 -extension_count=2048
echo "$MUPIP set -journal=enable,on,before,epoch=10,extension=1,auto=16384 -reg DEFAULT"
$MUPIP set -journal=enable,on,before,epoch=10,extension=1,auto=16384 -reg DEFAULT
if ($?test_replic == 1) then
	echo "Secondary Side: $MUPIP set -journal=enable,on,before,auto=16388,alloc=4100 -reg DEFAULT"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set -journal=enable,on,before,auto=16388,alloc=4100 -reg DEFAULT"
endif
$GTM << aaa
W "Start SET...",!
f i=1:1:100000 s ^newval(i)=\$j(i,800)
h
aaa
sleep 2
source $gtm_tst/com/get_abs_time.csh
###############################################################
$GTM << aaa
W "Again a new process starts SET...",!
f i=1:1:100000 s ^newval(i)=i
h
aaa
$gtm_tst/com/dbcheck.csh -replon -extr
###############################################################
$GTM << aaa
W "Start Application Data Verification",!
f i=1:1:100000 if ^newval(i)'=i W "Verify failed for index",i,!
h
aaa
###############################################################
$gtm_tst/$tst/u_inref/jnlverify.csh >& jnlverify.out
if ($?test_replic == 1) then
	$gtm_tst/$tst/u_inref/jnlrollback.csh 19999 >>&! rollback.out
	$grep "JNLSUCC" rollback.out
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/jnlverify.csh >>&! jnlverify.out"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/jnlrollback.csh 19999 >>&! sec_rollback.out; $grep 'JNLSUCC' sec_rollback.out"
	$tst_tcsh $gtm_tst/com/RF_EXTR.csh
else
	echo "$MUPIP journal -recover -back * -since=<gtm_test_since_time>"
	$MUPIP journal -recover -back "*" -since=\"$gtm_test_since_time\" >& back_rec.out
	if ($status) then
		echo "TEST-E-recover failed!"
		exit
	endif
	$grep "JNLSUCC" back_rec.out
endif
