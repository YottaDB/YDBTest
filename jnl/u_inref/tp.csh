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
#! "*** TP BASIC WITH BEFORE IMAGE JOURNALLING  ***
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
setenv gtmgbldir "mumps.gld"
source $gtm_tst/com/dbcreate.csh mumps 1 125 500 1024 50 1024
#
#
if ($?test_replic == 0) then
	$MUPIP set -file -journal=enable,on,before mumps.dat
endif
#
#
cp $gtm_tst/tp/inref/tpbasic.m .		# Use the tpbasic.m from the 'tp' suite
$GTM << EOF
w "do ^tpbasic",!  do ^tpbasic
w "h",!  h
EOF
#
#
#
$gtm_tst/com/dbcheck.csh "mumps" -extract
#
$MUPIP journal -recover -back mumps.mjl
#
#
$gtm_tst/com/dbcheck_base.csh "mumps"
#
#! "*** CHECK EXTRACT FOR A KEY LENGTH OF 255  ***
#
# Take a backup before overwriting databases
mkdir bak_tpbasic
mv mumps.dat mumps.mj* *key* *mapping* bak_tpbasic
setenv gtmgbldir "extr.gld"
source $gtm_tst/com/dbcreate.csh extr 1 255 500 1024 500 1024
if ($?test_replic == 0) then
	$MUPIP set -file -journal=enable,on,before extr.dat
endif
$GTM << EOF
w "do ^tpset5",!  do ^tpset5
w "h",!  h
EOF
$gtm_tst/com/dbcheck.csh -extract
#
$MUPIP journal -recover -extract -back extr.mjl
#
#
$gtm_tst/com/dbcheck_base.csh
#
#! END
#
