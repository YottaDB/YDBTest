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
# The test sets a bunch of TP transactions expecting a YDB-E-JNLTRANS2BIG - exceeding AUTOSWITCHLIMIT of the region
# The assumption is all the globals go to the same region. Spanning regions violates this assumption
setenv gtm_test_spanreg 0	# The test expects all subscripts of a global to go to the same region

$gtm_tst/com/dbcreate.csh mumps 3 255 2500 4096 2048 2048 2048
echo "$MUPIP set -journal=enable,on,before,alloc=2048,extension=1024,auto=16384 -reg AREG"
$MUPIP set -journal=enable,on,before,alloc=2048,extension=1024,auto=16384 -reg AREG
echo "$MUPIP set -journal=enable,on,before,alloc=2048,extension=1024,auto=16384 -reg BREG"
$MUPIP set -journal=enable,on,before,alloc=2048,extension=1024,auto=16384 -reg BREG
echo "$MUPIP set -journal=enable,on,before,alloc=2048,extension=1024,auto=16384 -reg DEFAULT"
$MUPIP set -journal=enable,on,before,alloc=2048,extension=1024,auto=16384 -reg DEFAULT
if ($?test_replic == 1) then
	echo "Secondary Side:"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set -journal=enable,on,before,alloc=2048,extension=1024,auto=16384 -reg AREG"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set -journal=enable,on,before,alloc=2048,extension=1024,auto=16384 -reg BREG"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set -journal=enable,on,before,alloc=2048,extension=1024,auto=16384 -reg DEFAULT"
endif
$GTM << \aaa
d laba^bigtp
h
\aaa
sleep 2
source $gtm_tst/com/get_abs_time.csh
$GTM << \aaa
d labb^bigtp
h
\aaa
$GTM << aaa
d lab2^bigtp
h
aaa
$gtm_tst/com/dbcheck.csh  -extr -replon
$gtm_tst/$tst/u_inref/jnlverify.csh >& jnlverify.out
if ($?test_replic == 1) then
	$gtm_tst/$tst/u_inref/jnlrollback.csh 1 >>&! rollback.out
	$grep "JNLSUCC" rollback.out
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/jnlverify.csh >>&! jnlverify.out"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/jnlrollback.csh 1 >>&! sec_rollback.out; $grep 'JNLSUCC' sec_rollback.out"
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
