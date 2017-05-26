#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This subtest covers test cases 23 to 29
# from mupip set journal test plan
#
echo "Journal qualifiers having numerical values as argument"
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh . 1
if (("MM" == $acc_meth) || (1 == $gtm_test_jnl_nobefore)) then
	set jnlimg = "nobefore"
else
	set jnlimg = "before"
endif
$MUPIP set -journal=enable,$jnlimg -file mumps.dat
echo "Check default value of allocation (2048 blocks), extension (2048 blocks), autoswitch (8386560 blocks)"
echo "Alignsize (4096 blocks), ......"
$DSE dump -fileheader |& $grep "Journal"
echo "============================================================"
#
echo Test Case 23
# ALIGNSIZE OPTION
echo ALIGNSIZE option
echo "$MUPIP set -journal=[no]before,alignsize=255 -file mumps.dat"
$MUPIP set -journal=$jnlimg,alignsize=255 -file mumps.dat
set jnl_alignsize = `$DSE dump -fileheader |& $grep "Journal Alignsize" | $tst_awk '{print $7}'`
echo journal alignsize expected 4096 blocks: actual $jnl_alignsize
#
echo "$MUPIP set -journal=[no]before,alignsize=4096 -file mumps.dat"
$MUPIP set -journal=$jnlimg,alignsize=4096 -file mumps.dat
set jnl_alignsize = `$DSE dump -fileheader |& $grep "Journal Alignsize" | $tst_awk '{print $7}'`
echo journal alignsize expected 4096 blocks: actual $jnl_alignsize
#
echo "$MUPIP set -journal=[no]before,alignsize=65536 -file mumps.dat"
$MUPIP set -journal=$jnlimg,alignsize=65536 -file mumps.dat
#
echo "$MUPIP set -journal=[no]before,alignsize=4194304 -file mumps.dat"
$MUPIP set -journal=$jnlimg,alignsize=4194304 -file mumps.dat
set jnl_alignsize = `$DSE dump -fileheader |& $grep "Journal Alignsize" | $tst_awk '{print $7}'`
echo journal alignsize expected 4194304 blocks: actual $jnl_alignsize
#
echo "$MUPIP set -journal=[no]before,alignsize=4194305 -file mumps.dat"
$MUPIP set -journal=$jnlimg,alignsize=4194305 -file mumps.dat
### #ALIGNSIZE is forced to power of two
echo "$MUPIP set -journal=[no]before,alignsize=4097 -file mumps.dat"
$MUPIP set -journal=$jnlimg,alignsize=4097 -file mumps.dat
echo "============================================================"
echo "Change extension to be 1, so that all values of allocation and AutoSwitchLimit are allowed:"
echo "$MUPIP set -journal=[no]before,auto=8388608,extension=1 -file mumps.dat"
$MUPIP set -journal=$jnlimg,auto=8388608,extension=1 -file mumps.dat
#
echo Test Case 24
# ALLOCATION OPTION
echo ALLOCATION option
echo "$MUPIP set -journal=[no]before,allocation=199 -file mumps.dat"
$MUPIP set -journal=$jnlimg,allocation=199 -file mumps.dat
set jnl_allocation = `$DSE dump -fileheader |& $grep "Journal Allocation" | $tst_awk '{print $3}'`
echo journal allocation: expected 2048 blocks : actual $jnl_allocation
#
echo "$MUPIP set -journal=[no]before,allocation=2048 -file mumps.dat"
$MUPIP set -journal=$jnlimg,allocation=2048 -file mumps.dat
set jnl_allocation = `$DSE dump -fileheader |& $grep "Journal Allocation" | $tst_awk '{print $3}'`
echo journal allocation: expected 2048 blocks : actual $jnl_allocation
#
echo "$MUPIP set -journal=[no]before,allocation=32768 -file mumps.dat"
$MUPIP set -journal=$jnlimg,allocation=32768 -file mumps.dat
set jnl_allocation = `$DSE dump -fileheader |& $grep "Journal Allocation" | $tst_awk '{print $3}'`
echo journal allocation: expected 32768 blocks : actual $jnl_allocation
#
echo "$MUPIP set -journal=[no]before,allocation=maxval -file mumps.dat"
if ("$HOSTOS"  == Linux) then
	$MUPIP set -journal=$jnlimg,allocation=4194303,extension=1 -file mumps.dat
	set jnl_allocation = `$DSE dump -fileheader |& $grep "Journal Allocation" | $tst_awk '{print $3}'`
	if ($jnl_allocation != 4194303) echo journal allocation: expected 4194303 blocks : actual $jnl_allocation
else
	$MUPIP set -journal=$jnlimg,allocation=8388607,auto=8388607,extension=0 -file mumps.dat
	set jnl_allocation = `$DSE dump -fileheader |& $grep "Journal Allocation" | $tst_awk '{print $3}'`
	if ($jnl_allocation != 8388607)  echo journal allocation: expected 8388607 blocks : actual $jnl_allocation
endif
#
echo "$MUPIP set -journal=[no]before,allocation=8388608 -file mumps.dat"
$MUPIP set -journal=$jnlimg,allocation=8388608 -file mumps.dat
set jnl_allocation = `$DSE dump -fileheader |& $grep "Journal Allocation" | $tst_awk '{print $3}'`
if ("$HOSTOS"  == Linux) then
	if ($jnl_allocation != 4194303) echo journal allocation: expected 4194303 blocks : actual $jnl_allocation
else
	if ($jnl_allocation != 8388607) echo journal allocation: expected 8388607 blocks : actual $jnl_allocation
endif
#
$gtm_tst/com/dbcheck.csh
mkdir ./save_24	; mv {*.dat,*.mj*} ./save_24
echo "============================================================"
#
echo Test Case 25
setenv gtm_test_jnl "SETJNL"
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh . 1
setenv gtm_test_jnl "NON_SETJNL"
# AUTOSWITCHLIMIT OPTION
echo AUTOSWITCHLIMIT option
echo "$MUPIP set -journal=[no]before,autoswitchlimit=4095 -file mumps.dat"
$MUPIP set -journal=$jnlimg,autoswitchlimit=4095 -file mumps.dat
set jnl_autoswitchlimit = `$DSE dump -fileheader |& $grep "Journal AutoSwitchLimit" | $tst_awk '{print $3}'`
echo "The AUTOSWITCHLIMIT is $jnl_autoswitchlimit"
#
echo "$MUPIP set -journal=[no]before,autoswitchlimit=16384 -file mumps.dat"
$MUPIP set -journal=$jnlimg,autoswitchlimit=16384 -file mumps.dat
set jnl_autoswitchlimit = `$DSE dump -fileheader |& $grep "Journal AutoSwitchLimit" | $tst_awk '{print $3}'`
echo "The AUTOSWITCHLIMIT is $jnl_autoswitchlimit"
#
echo "$MUPIP set -journal=[no]before,autoswitchlimit=65536 -file mumps.dat"
$MUPIP set -journal=$jnlimg,autoswitchlimit=65536 -file mumps.dat
set jnl_autoswitchlimit = `$DSE dump -fileheader |& $grep "Journal AutoSwitchLimit" | $tst_awk '{print $3}'`
echo "The AUTOSWITCHLIMIT is $jnl_autoswitchlimit"
#
echo "$MUPIP set -journal=[no]before,autoswitchlimit=8388607 -file mumps.dat"
$MUPIP set -journal=$jnlimg,autoswitchlimit=8388607 -file mumps.dat
set jnl_autoswitchlimit = `$DSE dump -fileheader |& $grep "Journal AutoSwitchLimit" | $tst_awk '{print $3}'`
echo "The AUTOSWITCHLIMIT is $jnl_autoswitchlimit"
#
echo "$MUPIP set -journal=[no]before,autoswitchlimit=8388608 -file mumps.dat"
$MUPIP set -journal=$jnlimg,autoswitchlimit=8388608 -file mumps.dat
set jnl_autoswitchlimit = `$DSE dump -fileheader |& $grep "Journal AutoSwitchLimit" | $tst_awk '{print $3}'`
echo "The AUTOSWITCHLIMIT is $jnl_autoswitchlimit"
#
echo "============================================================"
##
echo Test Case 26
# BUFFERSIZE OPTION
echo BUFFER_SIZE option
echo "$MUPIP set -journal=[no]before,buffer_size=2307 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=2307 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 2308 : actual $jnl_buffer_size
#
echo "$MUPIP set -journal=[no]before,buffer_size=2308 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=2308 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 2308, but actual $jnl_buffer_size
#
echo "$MUPIP set -journal=[no]before,buffer_size=2315 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=2315 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 2316, but actual $jnl_buffer_size
#
echo "$MUPIP set -journal=[no]before,buffer_size=2316 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=2316 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 2316, but actual $jnl_buffer_size
#
echo "$MUPIP set -journal=[no]before,buffer_size=2447 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=2447 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 2448, but actual $jnl_buffer_size
#
echo "$MUPIP set -journal=[no]before,buffer_size=32767 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=32767 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 32768, but actual $jnl_buffer_size
#
echo "$MUPIP set -journal=[no]before,buffer_size=32768 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=32768 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 32768, but actual $jnl_buffer_size
#
echo "$MUPIP set -journal=[no]before,buffer_size=32769 -file mumps.dat"
$MUPIP set -journal=$jnlimg,buffer_size=32769 -file mumps.dat
set jnl_buffer_size = `$DSE dump -fileheader |& $grep "Journal Buffer Size" | $tst_awk '{print $4}'`
echo journal buffer_size=: expected 32768, but actual $jnl_buffer_size
#
echo "============================================================"
#
if ("BG" == $acc_meth) then
	echo Test Case 27
	# EPOCH_INTERVAL OPTION
	echo EPOCH_INTERVAL option
	echo $MUPIP set -journal=nobefore,epoch_interval=2047 -file mumps.dat
	$MUPIP set -journal=nobefore,epoch_interval=2047 -file mumps.dat
	set jnl_epoch_interval = `$DSE dump -fileheader |& $grep "Journal Epoch Interval" | $tst_awk '{print $7}'`
	echo journal epoch_interval=: expected 2047 sec, but actual $jnl_epoch_interval
	#
	echo $MUPIP set -journal=before,epoch_interval=0 -file mumps.dat
	$MUPIP set -journal=before,epoch_interval=0 -file mumps.dat
	set jnl_epoch_interval = `$DSE dump -fileheader |& $grep "Journal Epoch Interval" | $tst_awk '{print $7}'`
	echo journal epoch_interval=: expected 2047 sec, but actual $jnl_epoch_interval
	#
	echo $MUPIP set -journal=before,epoch_interval=1 -file mumps.dat
	$MUPIP set -journal=before,epoch_interval=1 -file mumps.dat
	set jnl_epoch_interval = `$DSE dump -fileheader |& $grep "Journal Epoch Interval" | $tst_awk '{print $7}'`
	echo journal epoch_interval=: expected 1 sec, but actual $jnl_epoch_interval
	#
	echo $MUPIP set -journal=before,epoch_interval=600 -file mumps.dat
	$MUPIP set -journal=before,epoch_interval=600 -file mumps.dat
	set jnl_epoch_interval = `$DSE dump -fileheader |& $grep "Journal Epoch Interval" | $tst_awk '{print $7}'`
	echo journal epoch_interval=: expected 600 sec, but actual $jnl_epoch_interval
	#
	echo $MUPIP set -journal=before,epoch_interval=32767 -file mumps.dat
	$MUPIP set -journal=before,epoch_interval=32767 -file mumps.dat
	set jnl_epoch_interval = `$DSE dump -fileheader |& $grep "Journal Epoch Interval" | $tst_awk '{print $7}'`
	echo journal epoch_interval=: expected 32767 sec, but actual $jnl_epoch_interval
	#
	echo $MUPIP set -journal=before,epoch_interval=32768 -file mumps.dat
	$MUPIP set -journal=before,epoch_interval=32768 -file mumps.dat
	set jnl_epoch_interval = `$DSE dump -fileheader |& $grep "Journal Epoch Interval" | $tst_awk '{print $7}'`
	echo journal epoch_interval=: expected 32767 sec, but actual $jnl_epoch_interval
	#
	echo "============================================================"
endif
#
echo Test Case 28
# EXTENSION OPTION
echo EXTENSION option
echo "$MUPIP set -journal=[no]before,extension=-1 -file mumps.dat"
$MUPIP set -journal=$jnlimg,extension=-1 -file mumps.dat
set jnl_extension = `$DSE dump -fileheader |& $grep "Journal Extension" | $tst_awk '{print $6}'`
echo journal extension=: expected 2048 blocks, but actual $jnl_extension
#
echo "$MUPIP set -journal=[no]before,alloc=20000,autoswitch=20000,extension=0 -file mumps.dat"
$MUPIP set -journal=$jnlimg,alloc=20000,autoswitch=20000,extension=0 -file mumps.dat
set jnl_extension = `$DSE dump -fileheader |& $grep "Journal Extension" | $tst_awk '{print $6}'`
echo journal extension=: expected 0 blocks, but actual $jnl_extension
#
echo "$MUPIP set -journal=[no]before,alloc=2048,auto=16584,extension=16384 -file mumps.dat"
$MUPIP set -journal=$jnlimg,alloc=2048,auto=16584,extension=16384 -file mumps.dat
set jnl_extension = `$DSE dump -fileheader |& $grep "Journal Extension" | $tst_awk '{print $6}'`
echo journal extension=: expected 16384 blocks, but actual $jnl_extension
#
echo "$MUPIP set -journal=[no]before,alloc=3000,auto=1049575,extension=1048575 -file mumps.dat"
$MUPIP set -journal=$jnlimg,alloc=3000,auto=1049575,extension=1048575 -file mumps.dat
set jnl_extension = `$DSE dump -fileheader |& $grep "Journal Extension" | $tst_awk '{print $6}'`
echo journal extension=: expected 1048575 blocks, but actual $jnl_extension
#
echo "$MUPIP set -journal=[no]before,alloc=3000,auto=1049575,extension=1073741823 -file mumps.dat"
$MUPIP set -journal=$jnlimg,alloc=3000,auto=1049575,extension=1073741823 -file mumps.dat
set jnl_extension = `$DSE dump -fileheader |& $grep "Journal Extension" | $tst_awk '{print $6}'`
echo journal extension=: expected 1073741823 blocks, but actual $jnl_extension
#
echo "$MUPIP set -journal=[no]before,alloc=3000,auto=1049576,extension=1073741824 -file mumps.dat"
$MUPIP set -journal=$jnlimg,alloc=3000,auto=1049576,extension=1073741824 -file mumps.dat
set jnl_extension = `$DSE dump -fileheader |& $grep "Journal Extension" | $tst_awk '{print $6}'`
echo journal extension=: expected 1073741824 blocks, but actual $jnl_extension
echo "============================================================"
#
echo Test Case 29
# YIELD_LIMIT OPTION
echo YIELD_LIMIT option
echo "$MUPIP set -journal=[no]before,yield_limit=-1 -file mumps.dat"
$MUPIP set -journal=$jnlimg,yield_limit=-1 -file mumps.dat
set jnl_yield_limit = `$DSE dump -fileheader |& $grep "Journal Yield Limit" | $tst_awk '{print $4}'`
echo journal yield_limit=: expected 8, but actual $jnl_yield_limit
#
echo "$MUPIP set -journal=[no]before,yield_limit=0 -file mumps.dat"
$MUPIP set -journal=$jnlimg,yield_limit=0 -file mumps.dat
set jnl_yield_limit = `$DSE dump -fileheader |& $grep "Journal Yield Limit" | $tst_awk '{print $4}'`
echo journal yield_limit=: expected 0, but actual $jnl_yield_limit
#
echo "$MUPIP set -journal=[no]before,yield_limit=1024 -file mumps.dat"
$MUPIP set -journal=$jnlimg,yield_limit=1024 -file mumps.dat
set jnl_yield_limit = `$DSE dump -fileheader |& $grep "Journal Yield Limit" | $tst_awk '{print $4}'`
echo journal yield_limit=: expected 1024 , but actual $jnl_yield_limit
#
echo "$MUPIP set -journal=[no]before,yield_limit=2048 -file mumps.dat"
$MUPIP set -journal=$jnlimg,yield_limit=2048 -file mumps.dat
set jnl_yield_limit = `$DSE dump -fileheader |& $grep "Journal Yield Limit" | $tst_awk '{print $4}'`
echo journal yield_limit=: expected 2048 , but actual $jnl_yield_limit
#
echo "$MUPIP set -journal=[no]before,yield_limit=2049 -file mumps.dat"
$MUPIP set -journal=$jnlimg,yield_limit=2049 -file mumps.dat
set jnl_yield_limit = `$DSE dump -fileheader |& $grep "Journal Yield Limit" | $tst_awk '{print $4}'`
echo journal yield_limit=: expected 2048 , but actual $jnl_yield_limit
echo "============================================================"
#
$gtm_tst/com/dbcheck.csh
#
#! END
#
