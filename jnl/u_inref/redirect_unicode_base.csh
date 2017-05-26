#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2007-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
set dbbase="ＡＢＣＤＥＦＧ"
setenv gtmgbldir "$dbbase.gld"
$gtm_tst/com/dbcreate.csh $dbbase 1 255 1000 . 1000 256
$MUPIP set $tst_jnl_str,buff=2308 -reg "*"
$GTM <<xxyy
w "d in0^udbfill(""set"")",!  d in0^udbfill("set")
h
xxyy
$gtm_tst/com/dbcheck.csh $dbbase

if ("ENCRYPT" == $test_encryption) then
	sed 's/ＡＢＣＤＥＦＧ\.dat/ＲＥＤＩＲ.dat/' $gtm_dbkeys > ${gtm_dbkeys}.both
	cat $gtm_dbkeys >> ${gtm_dbkeys}.both
	$gtm_dist/mumps -run CONVDBKEYS ${gtm_dbkeys}.both ${gtmcrypt_config}.both
	mv $gtmcrypt_config ${gtmcrypt_config}.orig
	sed "s|##GTM_TST##|$gtm_tst|" gtmtls.cfg >&! $gtmcrypt_config
	cat ${gtmcrypt_config}.both >>&! $gtmcrypt_config
endif

#
#
$gtm_tst/com/backup_dbjnl.csh .save "*.dat" mv nozip
$MUPIP create
echo \cp $dbbase.dat ＲＥＤＩＲ.dat
\cp $dbbase.dat ＲＥＤＩＲ.dat
echo $MUPIP journal -recover -forward -redir="$dbbase.dat=ＲＥＤＩＲ.dat" -fences=NONE -verify $dbbase.mjl >>& rec_forw.log
$MUPIP journal -recover -forward -redir="$dbbase.dat=ＲＥＤＩＲ.dat" -fences=NONE -verify $dbbase.mjl >>& rec_forw.log
set stat1 = $status
$grep "Update successful" rec_forw.log
set stat2 = $status
if ($stat1 != 0 || $stat2 != 0) then
	echo "Redirect forward TEST FAILED"
	cat  rec_forw.log
	exit 1
endif
echo \cp ＲＥＤＩＲ.dat $dbbase.dat
\cp ＲＥＤＩＲ.dat $dbbase.dat
$GTM <<yyxx
w "d in0^udbfill(""ver"")",!  d in0^udbfill("ver")
h
yyxx
#
$gtm_tst/com/dbcheck_base.csh $dbbase
#
#! END
#
