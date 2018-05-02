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
#

setenv gtm_test_jnl SETJNL
setenv gtm_repl_instance mumps.repl
setenv gtm_repl_instname INSTANCE1

#setting this skips turning on replication in the passive start script
setenv gtm_test_repl_skipsetreplic ""


echo "#Create 3 database files for 3 regions, mumps.dat, a.dat, and b.dat for DEFAULT, AREG, and BREG respectively"
$gtm_tst/com/dbcreate.csh mumps 3 255 8000 16384 1024 1024 1024 > db_log.txt

$MUPIP set -repli=on  -reg "AREG" >>& db_log.txt
$MUPIP set -repli=on  -reg "BREG" >>& db_log.txt
$MUPIP set -repli=off -journal=disable -reg "DEFAULT" >>& db_log.txt

$gtm_tst/com/passive_start_upd_enable.csh >>& passive_start.out

echo "#calls gtm8202.m to set variables"
$ydb_dist/mumps -run gtm8202 > gtm8202.m.log

echo "#  single region extract -SEQNO=~0,1,~2 "
echo "#  expected to return sequences 1"
$MUPIP journal -forward -extract=./Reg.mjf -seqno=~0,1,~2 "a.mjl" >>& db_log.txt
echo "#  search extract file for set variables"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $6 " " $11 }'
	rm Reg.mjf
else
	echo "Reg.mjf not created (not supposed to happen here)"
endif

echo "#  multi region extract -SEQNO=~1,2,3,4,5 "
echo "#  expected to return only variables a and b (not c)"
$MUPIP journal -forward -extract=./Reg.mjf -seqno=~1,2,3,4,5 "*" >>& db_log.txt
echo "#  search extract file for set variables"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $6 " " $11 }'
	rm Reg.mjf
else
	echo "Reg.mjf not created (not supposed to happen here)"
endif

echo "#  multi region extract -SEQNO=~1,2,3,4,5,6 "
echo "#  expected to return sequences 2,3,4,5"
$MUPIP journal -forward -extract=./Reg.mjf -seqno=~1,2,3,4,5,6 "*" >>& db_log.txt
echo "#  search extract file for set variables"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $6 " " $11 }'
	rm Reg.mjf
else
	echo "Reg.mjf not created (not supposed to happen here)"
endif

echo "#  multi region extract -SEQNO=~1,2,~3"
echo "#  expected to return sequences 2"
$MUPIP journal -forward -extract=./Reg.mjf -seqno=~1,2,~3 "*" >>& db_log.txt
echo "#  search extract file for set variables"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $6 " " $11 }'
	rm Reg.mjf
else
	echo "Reg.mjf not created (not supposed to happen here)"
endif

echo "#  multi region extract -SEQNO=~(~1,2,~3)"
echo "#  expected to return sequences 1,3"
$MUPIP journal -forward -extract=./Reg.mjf -seqno="~(~1,2,~3)" "*" >>& db_log.txt
echo "#  search extract file for set variables"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $6 " " $11 }'
	rm Reg.mjf
else
	echo "Reg.mjf not created (not supposed to happen here)"
endif

echo "#  multi region extract -SEQNO=1,~2,3"
echo "#  expected to return sequences 1,3"
$MUPIP journal -forward -extract=./Reg.mjf -seqno=1,~2,3 "*" >>& db_log.txt
echo "#  search extract file for set variables"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $6 " " $11 }'
	rm Reg.mjf
else
	echo "Reg.mjf not created (not supposed to happen here)"
endif

echo "#  multi region extract -SEQNO=~(1,~2,3)"
echo "#  expected to return sequences 2"
$MUPIP journal -forward -extract=./Reg.mjf -seqno="~(1,~2,3)" "*" >>& db_log.txt
echo "#  search extract file for set variables"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $6 " " $11 }'
	rm Reg.mjf
else
	echo "Reg.mjf not created (not supposed to happen here)"
endif

echo "#  single region extract -SEQNO=1,2,3,4,5,6,7,8 TP transaction "
echo "#  expecting a.lost to be created"
$MUPIP journal -forward -extract=./Reg.mjf -seqno=1,2,3,4,5,6,7,8 "a.mjl" >>& db_log.txt;
if (  -f "a.lost" ) then
	echo "a.lost file created (expected)"
else
	echo "No a.lost file created (NOT expected)"
endif


echo "#  shutdown replication and turn it back on for AREG"
$MUPIP replic -source -shutdown -timeout=0 >>& passive_stop.out
$gtm_tst/com/dbcheck.csh >> dbcreate_log.txt
$MUPIP set -repli=on  -reg "AREG" >>& db_log.txt
$MUPIP set -repli=off  -reg "BREG" >>& db_log.txt
$MUPIP set -repli=off  -reg "DEFAULT" >>& db_log.txt

echo "#  multi region extract -SEQNO=1,2,3,4 with BREG replication turned off"
echo "#  expecting JNLEXTRCTSEQNO error"
$MUPIP journal -forward -extract=./Reg.mjf -seqno="1,2,3,4" "*" >>& db_log.txt
