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
#setting initial db transaction number to 2**10 = 1024
setenv gtm_test_dbcreate_initial_tn 10

echo "setenv gtm_test_dbcreate_initial_tn 10" >> settings.csh

echo "# Create 3 database files for 3 regions, mumps.dat, a.dat, and b.dat for DEFAULT, AREG, and BREG respectively"
$gtm_tst/com/dbcreate.csh mumps 3 255 8000 16384 1024 1024 1024 > db_log.txt

$MUPIP set -repli=on  -reg "AREG" >>& db_log.txt
$MUPIP set -repli=on  -reg "BREG" >>& db_log.txt
$MUPIP set -repli=off -journal=disable -reg "DEFAULT" >>& db_log.txt

$gtm_tst/com/passive_start_upd_enable.csh >>& passive_start.out

echo " #Calls gtm8202.m to set variables"
$ydb_dist/mumps -run gtm8202 > gtm8202.m.log

echo "# Single region extract -SEQNO=~0,1,~2 "
echo "# Expected to return sequences 1"
$MUPIP journal -forward -extract=./Reg.mjf -seqno=~0,1,~2 "a.mjl" >>& db_log.txt
echo "# Search extract file for set variables"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $6 " " $11 }'
	rm Reg.mjf
else
	echo "# Reg.mjf not created (not supposed to happen here)"
endif

echo "# Multi region extract -SEQNO=~1,2,3,4,5 "
echo "# Expected to return only variables a and b (not c)"
$MUPIP journal -forward -extract=./Reg.mjf -seqno=~1,2,3,4,5 "*" >>& db_log.txt
echo "# Search extract file for set variables"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $6 " " $11 }'
	rm Reg.mjf
else
	echo "# Reg.mjf not created (not supposed to happen here)"
endif

echo "# Multi region extract -SEQNO=~1,2,3,4,5,6 "
echo "# Expected to return sequences 2,3,4,5"
$MUPIP journal -forward -extract=./Reg.mjf -seqno=~1,2,3,4,5,6 "*" >>& db_log.txt
echo "# Search extract file for set variables"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $6 " " $11 }'
	rm Reg.mjf
else
	echo "# Reg.mjf not created (not supposed to happen here)"
endif

echo "# Multi region extract -SEQNO=~1,2,~3"
echo "# Expected to return sequences 2"
$MUPIP journal -forward -extract=./Reg.mjf -seqno=~1,2,~3 "*" >>& db_log.txt
echo "# Search extract file for set variables"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $6 " " $11 }'
	rm Reg.mjf
else
	echo "# Reg.mjf not created (not supposed to happen here)"
endif

echo "# Multi region extract -SEQNO=~(~1,2,~3)"
echo "# Expected to return sequences 1,3"
$MUPIP journal -forward -extract=./Reg.mjf -seqno="~(~1,2,~3)" "*" >>& db_log.txt
echo "# Search extract file for set variables"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $6 " " $11 }'
	rm Reg.mjf
else
	echo "# Reg.mjf not created (not supposed to happen here)"
endif

echo "# Multi region extract -SEQNO=1,~2,3"
echo "# Expected to return sequences 1,3"
$MUPIP journal -forward -extract=./Reg.mjf -seqno=1,~2,3 "*" >>& db_log.txt
echo "# Search extract file for set variables"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $6 " " $11 }'
	rm Reg.mjf
else
	echo "# Reg.mjf not created (not supposed to happen here)"
endif

echo "# Multi region extract -SEQNO=~(1,~2,3)"
echo "# Expected to return sequences 2"
$MUPIP journal -forward -extract=./Reg.mjf -seqno="~(1,~2,3)" "*" >>& db_log.txt
echo "# Search extract file for set variables"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $6 " " $11 }'
	rm Reg.mjf
else
	echo "# Reg.mjf not created (not supposed to happen here)"
endif

echo "# Single region extract -SEQNO=1,2,3,4,5,6,7,8 TP transaction "
echo "# Expecting a.broken to contain a(3) and a(4)"
echo "# Expecting Reg.mjf to contain a(1) and a(2)"
$MUPIP journal -forward -extract=./Reg.mjf -seqno=1,2,3,4,5,6,7,8 "a.mjl" >>& db_log.txt;
$grep "a.broken" db_log.txt
echo "# a.broken"
if (  -f "a.broken" ) then
	$grep "=" a.broken | awk -F '\\' '{ print $6 " " $11 }'
else
	echo "# No a.broken file created (NOT expected)"
endif
echo "# Reg.mjf"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $6 " " $11 }'
	rm Reg.mjf
else
	echo "# Reg.mjf not created (not supposed to happen here)"
endif


echo "# Shutdown replication for BREG"
$MUPIP replic -source -shutdown -timeout=0 >>& passive_stop.out
$gtm_tst/com/dbcheck.csh >> dbcreate_log.txt
$MUPIP set -repli=off  -reg "BREG" >>& db_log.txt

echo "# Multi region extract -SEQNO=1,2,3,4 with BREG replication turned off"
echo "# Expecting JNLEXTRCTSEQNO error"
$MUPIP journal -forward -extract=./Reg.mjf -seqno="1,2,3,4" "*" >>& db_log.txt
$grep "JNLEXTRCTSEQNO" db_log.txt


echo "# Grep db_log.txt for the b.mjl_* file holding the previous transactions"
set bjnl=`$grep 'b.mjl_' db_log.txt | awk -F '/' 'END{ print $(NF) }'`


echo "# Single region extract -SEQNO="3,4" (journal sequence numbers) with BREG replication turned off"
echo "# Expecting to find no set variables"
$MUPIP journal -forward -extract=./Reg.mjf -seqno="3,4" "$bjnl" >>& db_log.txt
echo "# Search extract file for set variables"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $6 " " $11 }'
	rm Reg.mjf
else
	echo "# Reg.mjf not created (NOT expected)"
endif

echo "# Single region extract -SEQNO="1024,1025,1026,1027,1028,1029" (DB transaction numbers) with BREG replication turned off"
echo "# Expecting variables b(1) and b(2) to be set"
$MUPIP journal -forward -extract=./Reg.mjf -seqno="1024,1025,1026,1027,1028,1029" "$bjnl" >>& db_log.txt
echo "# Search extract file for set variables"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $3 " " $11 }'
	rm Reg.mjf
else
	echo "# Reg.mjf not created (NOT expected)"
endif


echo "# Single region extract -SEQNO="1024" (DB transaction numbers) with BREG replication turned off"
echo "# Expecting variables b(1) to be set"
$MUPIP journal -forward -extract=./Reg.mjf -seqno="1024" "$bjnl" >>& db_log.txt
echo "# Search extract file for set variables"
if (  -f Reg.mjf ) then
	$grep "=" Reg.mjf | awk -F '\\' '{ print $3 " " $11 }'
	rm Reg.mjf
else
	echo "# Reg.mjf not created (NOT expected)"
endif

