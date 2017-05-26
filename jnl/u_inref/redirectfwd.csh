#! /usr/local/bin/tcsh -f
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
#
setenv gtmgbldir "mumps.gld"
source $gtm_tst/com/dbcreate.csh mumps  1 . . . 1000 256
if ($?test_replic == 0) then
	$MUPIP set -file $tst_jnl_str,buff=2308 mumps.dat
endif
#
$GTM <<xxyy
	do ^jnl0("$gtmgbldir")
xxyy
$gtm_tst/com/dbcheck.csh
#
#! *** DB RECOVERY AND REDIRECT WITH ROLL FORWARD
#
\rm -f mumps.dat
$MUPIP create
source $gtm_tst/com/mupip_set_version.csh # randomly decide on V4 or V5 database format
source $gtm_tst/com/change_current_tn.csh # randomly decide on transaction number to start off with
\cp -f mumps.dat redir.dat

if ("ENCRYPT" == $test_encryption) then
	sed 's/mumps\.dat/redir.dat/' $gtm_dbkeys > ${gtm_dbkeys}.both
	cat $gtm_dbkeys >> ${gtm_dbkeys}.both
	$gtm_dist/mumps -run CONVDBKEYS ${gtm_dbkeys}.both ${gtmcrypt_config}.both
	mv $gtmcrypt_config ${gtmcrypt_config}.orig
	sed "s|##GTM_TST##|$gtm_tst|" gtmtls.cfg >&! $gtmcrypt_config
	cat ${gtmcrypt_config}.both >>&! $gtmcrypt_config
endif
$MUPIP journal -recover -forward -redir="mumps.dat=redir.dat" -fences=NONE -verify mumps.mjl >>& rec_for1.log
set stat1 = $status
#
$grep "successful" rec_for1.log
set stat2 = $status
if ($stat1 != 0 || $stat2 != 0) then
	echo "Redirectfwd TEST FAILED"
	cat  rec_for1.log
	exit 1
endif
#
#
cp redir.dat mumps.dat
$GTM <<yyxx
w "d in0^jdbfill(""ver"")",!  d in0^jdbfill("ver")
w "d in1^jdbfill(""ver"")",!  d in1^jdbfill("ver")
w "h",!  h
yyxx
#
#
$gtm_tst/com/dbcheck_base.csh
#
#! END
#
