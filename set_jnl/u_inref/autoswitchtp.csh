#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2013 Fidelity Information Services, Inc	#
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

# The test creates a lot of journal files and if run with -replic can cause the source server to go out-of-memory if the align size
# is set to a large value. So, force the alignsize to be a smaller value.

source $gtm_tst/com/set_limits.csh
@ force_align_size = $MIN_JOURNAL_ALIGN_SIZE
set tstjnlstr = `echo $tst_jnl_str | sed 's/,align=[1-9][0-9]*//;s/$/,align='$force_align_size'/'`
setenv tst_jnl_str "$tstjnlstr"
echo "# Align size forced to be the minimum value due to source server out-of-memory issues"	>> settings.csh
echo "setenv tst_jnl_str $tstjnlstr"								>> settings.csh
echo "setenv test_align $force_align_size"							>> settings.csh

# The test creates sets a calculated number of globals in each region within a transaction
# Spanning regions result in more globls going to a single region and end up with the below error.
# YDB-E-JNLTRANS2BIG, Transaction needs an estimated [xxx blocks]...which exceeds the AUTOSWITCHLIMIT of yyy blocks
setenv gtm_test_spanreg 0	# Spanningregions cause imbalance and JNLTRANS2BIG error

$gtm_tst/com/dbcreate.csh mumps 9 125 3500 4096 5000 1024 5000
#
# Note : The "-journal=enable,on,before" usage below should normally be replaced with $tst_jnl_str. This will make sure we use
# BEFORE_IMAGE or NOBEFORE_IMAGE depending on what was specified at the test startup. But in the case the test was started with
# NOBEFORE_IMAGE, we do want to test the scenario where a fetchresync rollback is done below (jnlrollback.csh) with a mix
# of regions some of which have all generations of journal files with NOBEFORE_IMAGE (e.g. BREG, CREG, DREG) and some of which
# having a mix of BEFORE_IMAGE and NOBEFORE_IMAGE generations. Hence we unconditionally use BEFORE_IMAGE on the below journal
# file switch commands (note:the dbcreate.csh above would have created NOBEFORE or BEFORE_IMAGE jnl files based on $tst_jnl_str).
#
echo "On Primary:"
$MUPIP set -journal=enable,on,before,epoch=10,extension=1,auto=16448 -reg AREG
$MUPIP set -journal=enable,on,before,epoch=10,extension=1,auto=16448 -reg EREG
$MUPIP set -journal=enable,on,before,epoch=900,auto=19800,alloc=3000,exten=2100 -reg FREG
$MUPIP set -journal=enable,on,before,epoch=10,auto=19800,alloc=3000,exten=2100 -reg GREG
$MUPIP set -journal=enable,on,before,epoch=10,auto=19800,alloc=3000,exten=2100 -reg HREG
$MUPIP set -journal=enable,on,before,epoch=900,auto=19800,alloc=3000,exten=2100 -reg DEFAULT
if ($?test_replic == 1) then
	echo "On Secondary:"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set -journal=enable,on,before,epoch=30,auto=20288,alloc=8000 -reg BREG"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set -journal=enable,on,before,epoch=30,auto=19800,alloc=3000,exten=2100 -reg CREG"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set -journal=enable,on,before,epoch=900,auto=19800,alloc=3000,exten=2100 -reg DREG"
endif
sleep 1
@ count = 0
while ($count < 2)
	$GTM << GTM_EOF
	d ^autotp1(2)
	h
GTM_EOF
	sleep 2
	source $gtm_tst/com/get_abs_time.csh
	$GTM << GTM_EOF
	d ^autotp1(2)
	h
GTM_EOF
	@ count = $count + 1
end
$gtm_tst/com/dbcheck.csh  -extr -replon
$gtm_tst/com/get_dse_df.csh "After_dbcheck"
###############################################################
$gtm_tst/$tst/u_inref/jnlverify.csh >& verification.out
sleep 1
$grep -E 'YDB-E|YDB-F'  verification.out
if ($status == 0) then
	echo "Please look at verification.out for details"
endif
if ($?test_replic == 1) then
	$gtm_tst/$tst/u_inref/jnlrollback.csh 2 >>&! rollback.out
	$grep -E "JNLSUCC" rollback.out
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/jnlrollback.csh 2 >>&! sec_rollback.out; $grep 'JNLSUCC' sec_rollback.out"
	$tst_tcsh $gtm_tst/com/RF_EXTR.csh
else
	echo "$MUPIP journal -recover -back * -since=<gtm_test_since_time>"
	$MUPIP journal -recover -back "*" -since=\"$gtm_test_since_time\" >& back_rec.out
	if ($status) then
		echo "TEST-E-recover failed!"
		exit
	endif
	$grep "JNLSUCC" back_rec.out
endif
