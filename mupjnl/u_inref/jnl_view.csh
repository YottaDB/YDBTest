#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2003, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

# This test does kill -9 of a GT.M process followed by a MUPIP RUNDOWN. A kill -9 could hit the running GT.M process while it
# is in the middle of executing wcs_wtstart. This could potentially leave some dirty buffers hanging in the shared memory. So,
# set the white box test case to avoid asserts in wcs_flu.c

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 29
$gtm_tst/com/dbcreate.csh mumps 1
setenv gtmgbldir "mumps.gld"
#
echo "Enable journaling"
if ($?test_replic == 0) then
	$MUPIP set $tst_jnl_str -reg "*"
endif
cp mumps.dat before.dat

echo "Start a GT.M process in the background ..."
$gtm_exe/mumps -run jnlview >& jnlview.out < /dev/null &

set gtmps = $!

$gtm_exe/mumps -run track^jnlview
if ($status) then
	exit -1
endif

echo "Now crash the gtm process ..."
$kill9 $gtmps
#
$MUPIP rundown -region DEFAULT -override
$MUPIP rundown -relinkctl >&! mupip_rundown_rctl.logx
cp before.dat mumps.dat
echo "mupip journal -recover -forw mumps.mjl"
$MUPIP journal -recov -forw mumps.mjl
echo "mupip journal -extract -forw mumps.mjl"
$MUPIP journal -extract -forward mumps.mjl
#
echo "Verifying the data ..."
$GTM << gtm_ver
 d dverify^jnlview
gtm_ver
#
echo "Verifying the journal extract file ..."
$GTM << gtm_ver
 d everify^jnlview
gtm_ver
#
echo "Test view function "
$gtm_exe/mumps -direct << bbb
 d view1^jnlview
bbb
#
$gtm_exe/mumps -direct << ccc
 d view2^jnlview
ccc
#
echo "PASS"
$gtm_tst/com/dbcheck.csh -extract
