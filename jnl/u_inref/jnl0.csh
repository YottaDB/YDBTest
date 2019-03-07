#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
#
#! "*** 1B1SBN: 1 BG REGION, 2 USERS, BACKWARD RECOVERY, NO FENCES ***
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
setenv gtmgbldir "myjnl0.gld"
source $gtm_tst/com/dbcreate.csh myjnl0 1 . . . 1000 256
#
if ($?test_replic == 0) then
	$MUPIP set -file -journal=enable,on,before,buff=2308 myjnl0.dat
endif
#
#
$GTM <<xxyy
	do ^jnl0("$gtmgbldir")
xxyy

$gtm_tst/com/dbcheck.csh -extract
#
#! *** DB RECOVERY WITH ROLL BACKWARD
#
$MUPIP journal -back -show myjnl0.mjl >>& show.out
# This should be same as above with all
$MUPIP journal -back -show=all myjnl0.mjl >>& show_all.out
#filter the timestamp before the diff - zhouc - 05/07/2003
$tst_awk '{if ($0 ~ /^%YDB-I-MUJNLSTAT, .* at/) {gsub(/at .*/,"at #timestamp#");$0="##TEST_AWK"$0} print $0}' show.out > ! show_new.out
$tst_awk '{if ($0 ~ /^%YDB-I-MUJNLSTAT, .* at/) {gsub(/at .*/,"at #timestamp#");$0="##TEST_AWK"$0} print $0}' show_all.out > ! show_all_new.out
diff show_new.out show_all_new.out
#
#
$MUPIP journal -recover -back -fences=NONE -verify myjnl0.mjl >>& rec_bak.log
set stat1 = $status
$grep "successful" rec_bak.log
set stat2 = $status
if ($stat1 != 0 || $stat2 != 0) then
	echo "Jnl0 TEST FAILED"
	cat  rec_bak.log
	exit 1
endif
#
#
$GTM <<yyxx
w "d in0^jdbfill(""ver"")",!  d in0^jdbfill("ver")
w "d in1^jdbfill(""ver"")",!  d in1^jdbfill("ver")
w "h",!  h
yyxx
#
#
#
$gtm_tst/com/dbcheck_base.csh
#
#! END
#
