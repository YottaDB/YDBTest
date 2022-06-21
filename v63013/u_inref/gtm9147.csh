#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# This test makes sure that MUPIP SET -JOURNAL -BUFFSIZE"
echo "# accepts values up to the limit of 1048576 blocks which"
echo "# was increased from 32768 in V6.3-013. It also tests that"
echo "# a BUFFSIZE of 1048577 blocks will be adjusted downward and"
echo "# produce an appropriate error message. Portions of this test"
echo "# were based on the set_jnl/qualifiers_with_arg test."

$gtm_tst/com/dbcreate.csh mumps
if (("MM" == $acc_meth) || (1 == $gtm_test_jnl_nobefore)) then
	set jnlimg = "nobefore"
else
	set jnlimg = "before"
endif
$MUPIP set -journal=enable,$jnlimg -file mumps.dat >& startjnl.out

$echoline

echo "# $MUPIP set -journal=[no]before,buffer_size=32769 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=32769 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 32776 : actual $jnl_buffer_size
$echoline

echo "# $MUPIP set -journal=[no]before,buffer_size=32776 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=32776 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 32776 : actual $jnl_buffer_size
$echoline

echo "# $MUPIP set -journal=[no]before,buffer_size=131103 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=131103 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 131104 : actual $jnl_buffer_size
$echoline

echo "# $MUPIP set -journal=[no]before,buffer_size=131104 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=131104 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 131104 : actual $jnl_buffer_size
$echoline

echo "# $MUPIP set -journal=[no]before,buffer_size=131105 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=131105 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 131112 : actual $jnl_buffer_size
$echoline

echo "# $MUPIP set -journal=[no]before,buffer_size=524414 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=524414 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 524416 : actual $jnl_buffer_size
$echoline

echo "# $MUPIP set -journal=[no]before,buffer_size=524416 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=524416 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 524416 : actual $jnl_buffer_size
$echoline

echo "# $MUPIP set -journal=[no]before,buffer_size=968828 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=968828 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 968832 : actual $jnl_buffer_size
$echoline

echo "# $MUPIP set -journal=[no]before,buffer_size=968832 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=968832 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 968832 : actual $jnl_buffer_size
$echoline

echo "# $MUPIP set -journal=[no]before,buffer_size=1048575 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=1048575 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 1048576 : actual $jnl_buffer_size
$echoline

echo "# $MUPIP set -journal=[no]before,buffer_size=1048576 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=1048576 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 1048576 : actual $jnl_buffer_size
$echoline

echo "# $MUPIP set -journal=[no]before,buffer_size=1048577 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=1048577 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 1048576 : actual $jnl_buffer_size
$echoline

$gtm_tst/com/dbcheck.csh
