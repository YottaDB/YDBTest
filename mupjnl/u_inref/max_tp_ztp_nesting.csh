#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#############ZTP#########################
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
echo "##########################"
echo "TESTING ZTP NESTING..."
mkdir ztp
cd ztp
$gtm_tst/com/dbcreate.csh .
$gtm_tst/com/jnl_on.csh
cp mumps.dat cp.dat
$gtm_tst/com/abs_time.csh time0
set time0 = `cat time0_abs`
$GTM << XXX
d lztp^nesting
XXX

cp mumps.mjl cp.mjl
set verbose
$MUPIP journal -recov -back -since=\"$time0\" mumps.mjl -lost=mumps.lost1 -broken=mumps.broken1 -extract=mumps.mjf1 >& recov_back.out
$grep -v MUJNLSTAT recov_back.out
$GTM << XXX
d verztp^nesting
XXX

$grep -q -w za mumps.broken1
set st1 = $status
$grep -q -w za mumps.lost1
set st2 = $status
$grep -q -w za mumps.mjf1
set st3 = $status
echo "$st1$st2$st3"
if ("011" != "$st1$st2$st3") echo "TEST-""E-FAILED. all ^za should go to broken"

mkdir back
cp mumps* back
cp cp.dat mumps.dat
cp cp.mjl mumps.mjl
$MUPIP journal -recov -forw mumps.mjl -verify -lost=mumps.lost2 -broken=mumps.broken2 -extract=mumps.mjf2 >&! recov_forw.out
$grep -v MUJNLSTAT recov_forw.out

$grep -q -w za mumps.broken2
set st1 = $status
$grep -q -w za mumps.lost2
set st2 = $status
$grep -q -w za mumps.mjf2
set st3 = $status
if ("011" != "$st1$st2$st3") echo "TEST-E-FAILED. all ^za should go to broken"

unset verbose
$GTM << XXX
d verztp^nesting
XXX

$gtm_tst/com/dbcheck.csh
##############TP#########################
echo "##########################"
echo "TESTING TP NESTING..."
cd ..
mkdir tp
cd tp

$gtm_tst/com/dbcreate.csh .
$gtm_tst/com/jnl_on.csh
cp mumps.dat cp.dat
$gtm_tst/com/abs_time.csh time0
set time0 = `cat time0_abs`
$GTM << XXX
d ltp^nesting
XXX
sleep 1

cp mumps.mjl cp.mjl
set verbose
$MUPIP journal -recov -back -since=\"$time0\" mumps.mjl -lost=mumps.lost1 -broken=mumps.broken1 -extract=mumps.mjf1 >& recov_back.out
$grep -v MUJNLSTAT recov_back.out
$GTM << XXX
d vertp^nesting
XXX

mkdir back
cp mumps* back
cp -p mumps.dat bak.dat
cp cp.dat mumps.dat
cp cp.mjl mumps.mjl
$MUPIP journal -recov -forw mumps.mjl -verify -lost=mumps.lost2 -broken=mumps.broken2 -extract=mumps.mjf2 >& recov_forw.out
$grep -v MUJNLSTAT recov_forw.out

unset verbose
$GTM << XXX
d vertp^nesting
XXX

$gtm_tst/com/dbcheck.csh
