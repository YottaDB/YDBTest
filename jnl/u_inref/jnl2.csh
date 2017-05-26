#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#! jnl_1b1sfn.com: 	- single BG region,  (1b)
#!		        - single user        (1)
#!      		- successful process termination (s)
#!			- forward recovery
#!			- no fences
#!"*************** 1B1SFN: 1 BG REGION, 1 USER, NOBEFORE, FORWARD RECOVERY, NO FENCES ***************"
#
setenv gtmgbldir "myjnl2.gld"
# the output of this test relies on transaction numbers, so let's not do anything that might change the TN
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
source $gtm_tst/com/dbcreate.csh myjnl2 1 . . . 1000 256
sleep 3
#
#
if ($?test_replic == 0) then
	$MUPIP set -file $tst_jnl_str,buff=2308 myjnl2.dat
endif
if (-f tmp.dat) then
    \rm -f tmp.dat
endif
$MUPIP backup DEFAULT tmp.dat
#
#
$GTM <<xxyy
w "s pass=16",!  s pass=16
w "d ^jnlbas0",!  d ^jnlbas0
w "h 5",!  h 5
xxyy
#
#
$gtm_tst/com/dbcheck.csh -extract
#
#! DB RECOVERY WITH ROLL FORWARD
#
if (-f myjnl2.dat) then
    \rm -f myjnl2.dat
endif
cp tmp.dat myjnl2.dat
#
#
$MUPIP set -file -journal=off myjnl2.dat
if ($?test_replic == 1) then
	\rm -f *.dat
	$MUPIP create
endif
#
#
sleep 1
$MUPIP journal -recover -forward -fences=NONE -verify myjnl2.mjl >>& rec_for.log
set stat1 = $status
#
$grep "successful" rec_for.log
set stat2 = $status
if ($stat1 != 0 || $stat2 != 0) then
	echo "Jnl2 TEST FAILED"
	cat  rec_for.log
	exit 1
endif
#
#
$GTM <<yyxx
w "s pass=16",!  s pass=16
w "d ^jnlbas1",!  d ^jnlbas1
w "h 3",!  h 3
yyxx
#
#
$gtm_tst/com/dbcheck_base.csh
#
#!"*************** 1B1SFN COMPLETE ***************"
#

