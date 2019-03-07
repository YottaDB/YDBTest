#!/usr/local/bin/tcsh -f
#################################################################
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
# This module is derived from FIS GT.M.
#################################################################

$gtm_tst/com/dbcreate.csh mumps 1 255 1010 4096 1000 4096 1000
echo "$MUPIP set -journal=enable,on,before,alloc=2500,extension=1000,auto=17384 -reg DEFAULT"
$MUPIP set -journal=enable,on,before,alloc=2500,extension=1000,auto=17384 -reg DEFAULT
if ($?test_replic == 1) then
	echo "Secondary Side: $MUPIP set -journal=enable,on,before,alloc=2500,extension=1000,auto=17384 -reg DEFAULT"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set -journal=enable,on,before,alloc=2500,extension=1000,auto=17384 -reg DEFAULT"
endif
$GTM << aaa
W "Start SET...",!
f i=1:1:29000 s ^newval(i)=\$j(i,400)
h
aaa
# At this point a few more (potentially hundreds but < 8000) set commands will autoswitch
sleep 2
source $gtm_tst/com/get_abs_time.csh
###############################################################
$GTM << aaa
W "Again a new process starts SET...",!
for i=1:1:8000 s ^newval("new")=\$j(1,400)
h
aaa
$gtm_tst/com/dbcheck.csh  -replon -extr
###############################################################
#
$GTM << aaa
W "Start Application Data Verification",!
f i=1:1:29000 if ^newval(i)'=\$j(i,400) W "Verify failed for index",i,!
if ^newval("new")'=\$j(1,400) W "Verify failed for ^newval(""new"")",!
h
aaa
###############################################################
$gtm_tst/$tst/u_inref/jnlverify.csh >& jnlverify.out
if ($?test_replic == 1) then
	# Randomly supplementary instance might have been chosen either on primary or secondary or both. Supplementary instance has an additional line YDB-I-RLBKSTRMSEQ Filter it off
	# Actually the other subtests that uses jnlrollback.csh actually greps ONLY for JNLSUC message.
	$gtm_tst/$tst/u_inref/jnlrollback.csh 10000 >&! rollback.out
	$grep -v "YDB-I-RLBKSTRMSEQ" rollback.out
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/jnlverify.csh >>&! jnlverify.out"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/jnlrollback.csh 10000 >&! rollback.out ; $grep -v YDB-I-RLBKSTRMSEQ rollback.out"
	$tst_tcsh $gtm_tst/com/RF_EXTR.csh
else
	echo $gtm_test_since_time  > since_time.txt
	mkdir bak
	cp *.dat *.mjl* bak
	echo "$MUPIP journal -recover -back * -since=<gtm_test_since_time>"
	$MUPIP journal -recover -back "*" -since=\"$gtm_test_since_time\"
	if ($status) then
		echo "TEST-E-recover failed!"
		exit
	endif
endif
