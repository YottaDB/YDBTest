#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
$gtm_tst/com/dbcreate.csh mumps 1
setenv gtmgbldir "mumps.gld"
#
echo "Enable no before image journaling"
if ($?test_replic == 0) then
	$MUPIP set -journal="enable,on,nobefore" -reg "*"
endif
#
cp mumps.dat before.dat
$GTM << gtm_eof
	f i=1:1:10 s ^x(i)=i
gtm_eof
#
cp mumps.dat back.dat
#
echo "Forward recovering ......"
cp before.dat mumps.dat
$MUPIP journal -recover -forward "*" >>& rec_for.log
set stat1=$status
#
$grep "Recover successful" rec_for.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0) then
	echo "Journal file name TEST FAILED"
	cat rec_for.log
	exit 1
endif
#
echo "Verifying the data ..."
$GTM << gtm_ver
	zwr ^x
gtm_ver
#
echo "Forward recovering with journaling disabled..."
rm mumps.dat
$MUPIP create
$MUPIP journal -recov -for "*"

echo "Backward rollback with replication/journaling disabled..."
setenv gtm_repl_instance mumps.repl
$MUPIP replicate -instance -name=dummy	# need an instance file to avoid REPLINSTUNDEF error from backward rollback
$gtm_tst/com/mupip_rollback.csh -backward "*"

echo "Forward rollback with replication/journaling disabled..."
$gtm_tst/com/mupip_rollback.csh -forward "*"

echo "PASS"
$gtm_tst/com/dbcheck.csh -extract
