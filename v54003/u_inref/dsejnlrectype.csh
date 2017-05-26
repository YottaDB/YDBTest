#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test case verifies that **** are not printed in output of "dse dump -file -all "

setenv gtmgbldir mumps.gld
setenv gtm_test_jnl NON_SETJNL
setenv tst_jnl_str "$tst_jnl_str,epoch_interval=1"
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP set -region "*" $tst_jnl_str >& jnl_on.out

cat >&! tran.m <<EOF
tran; write large records journal buffer
	for i=0:1:1000 do
	.	tstart ():(serial:transaction="BATCH")
	.	set ^x(i)=i
	.	tcommit
EOF

$GTM <<EOF
do tran^tran
zsy "dse dump -file -all >&! dsedump.log"
EOF

$grep 'Jnl Rec Type    TSET' dsedump.log | $grep '\*\*\*\*\*\*\*'

if ($status == 0) then
	echo 'asterisk is present in the DSE DUMP -FILE -ALL output'
endif

$gtm_tst/com/dbcheck.csh
