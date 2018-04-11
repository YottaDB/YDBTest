#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
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

$gtm_tst/com/dbcreate.csh mumps 1 255 2500 4096 2048 2048 2048
echo "$MUPIP set -journal=enable,on,[no]before,alloc=2048,extension=1000,auto=16500 -reg DEFAULT"
$MUPIP set $tst_jnl_str,alloc=2048,extension=1000,auto=16500 -reg DEFAULT
if ($?test_replic == 1) then
	echo "Secondary :"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set $tst_jnl_str,alloc=2048,extension=1000,auto=16500 -reg DEFAULT"
endif
$GTM << aaa
SET ^a(\$j)=\$h
SET ^a(\$h)=\$j("TEST",2400)
h
aaa
echo "$MUPIP set -journal=enable,on,[no]before,alloc=4096,extension=200,auto=17200 -reg DEFAULT"
$MUPIP set $tst_jnl_str,alloc=4096,extension=200,auto=17200 -reg DEFAULT >&! jnl_on_1.log
$grep "YDB-I-JNLSWITCHSZCHG" jnl_on_1.log
$grep "YDB-I-FILERENAME" jnl_on_1.log
$grep "YDB-I-JNLSTATE" jnl_on_1.log
$DSE dump -file |& $grep AutoSwitchLimit  | $tst_awk '{print $1,$2,$3}'
$DSE dump -file |& $grep Allocation
echo "$MUPIP set -journal=enable,on,[no]before,alloc=16384,extension=0,auto=16384 -reg DEFAULT"
$MUPIP set $tst_jnl_str,alloc=16384,extension=0,auto=16384 -reg DEFAULT >&! jnl_on_2.log
$grep "YDB-I-JNLSTATE" jnl_on_2.log
$DSE dump -file |& $grep AutoSwitchLimit  | $tst_awk '{print $1,$2,$3}'
$DSE dump -file |& $grep Allocation
echo "$MUPIP set -journal=enable,on,[no]before,alloc=2048,extension=10,auto=20 -reg DEFAULT"
$MUPIP set $tst_jnl_str,alloc=2048,extension=10,auto=20 -reg DEFAULT
$DSE dump -file |& $grep AutoSwitchLimit  | $tst_awk '{print $1,$2,$3}'
$DSE dump -file |& $grep Allocation
echo "$MUPIP set -journal=enable,on,[no]before,alloc=16584,extension=200,auto=16384 -reg DEFAULT"
$MUPIP set $tst_jnl_str,alloc=16584,extension=200,auto=16384 -reg DEFAULT
$DSE dump -file |& $grep AutoSwitchLimit  | $tst_awk '{print $1,$2,$3}'
$DSE dump -file |& $grep Allocation
echo "$MUPIP set -journal=enable,on,[no]before,alloc=4096,extension=200,auto=8400000 -reg DEFAULT"
$MUPIP set $tst_jnl_str,alloc=4096,extension=200,auto=8400000 -reg DEFAULT
$DSE dump -file |& $grep AutoSwitchLimit  | $tst_awk '{print $1,$2,$3}'
$DSE dump -file |& $grep Allocation
echo "$MUPIP set -journal=enable,on,[no]before,alloc=2048,extension=0,auto=16384 -reg DEFAULT"
$MUPIP set $tst_jnl_str,alloc=2048,extension=0,auto=16384 -reg DEFAULT
$DSE dump -file |& $grep AutoSwitchLimit  | $tst_awk '{print $1,$2,$3}'
$DSE dump -file |& $grep Allocation
if ($?test_replic == 1) then
	echo "Secondary :"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set $tst_jnl_str,alloc=16384,extension=0,auto=16384 -reg DEFAULT" \
		>&! jnl_on_3.log
	$grep "YDB-I-JNLSTATE" jnl_on_3.log
endif
$GTM << aaa
d in3^sfill("set",5,5)
d in3^sfill("ver",5,5)
d in3^sfill("kill",5,5)
d in1^sfill("set",1,1)
d in1^sfill("ver",1,1)
h
aaa
$gtm_tst/com/dbcheck.csh  -replon -extr
$gtm_tst/$tst/u_inref/jnlverify.csh >&! jnlverify.out
#\ls -lart *.mjl* | $tst_awk '{print $5}' | sort
