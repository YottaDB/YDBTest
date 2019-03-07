#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv gtm_test_disable_randomdbtn
setenv gtm_test_mupip_set_version "disable"	# As we play with V4 - V6 formats
setenv gtm_test_jnl "SETJNL"			# For journal creation at database creation time
setenv test_encryption "NON_ENCRYPT"		# As the test plays with V4 - V6 formats
source $gtm_tst/com/gtm_test_setbeforeimage.csh	# We need before image journaling enabled so that PBLKs gets written

$gtm_tst/com/dbcreate.csh mumps 1 -block_size=1024

$echoline
echo "STEP 1 ==> Create some V6 blocks (global ^a)"
$echoline
$gtm_exe/mumps -run %XCMD 'for i=1:1:1000  set ^a(i)=$J(i,5)'
echo

$echoline
echo "STEP 2 ==> Set database to V4 format"
$echoline
$MUPIP set -version=V4 -reg DEFAULT
echo

$echoline
echo "STEP 3 ==> Updates to global ^b. This will touch BLOCK 0 (BITMAP) and BLOCK 2 (DIRECTORY TREE) thereby downgrading them to V4"
$echoline
$gtm_exe/mumps -run %XCMD 'for i=1:1:1000  set ^b(i)=$j(i,5)'
echo

$echoline
echo "STEP 4 ==> KILL ^b. This will create a lot of V4 reusable blocks"
# However, the KILL will create two new V4 blocks : 1 Parent and 1 Child representing the KILLed ^b global
$echoline
$gtm_exe/mumps -run %XCMD 'kill ^b'
echo

$echoline
echo "STEP 5 ==> Bring the database back to V6"
$echoline
$MUPIP set -version=V6 -reg DEFAULT
echo

$echoline
echo "STEP 6 ==> More updates: will touch the BITMAP and DIRECTORY TREE thereby upgrading them to V6 again"
$echoline
$gtm_exe/mumps -run %XCMD 'for i=1:1:10  set ^c(i)=$j(i,5)'
echo

# At this point, we have only 2 BUSY blocks with V4 and a few V4 reusable blocks. The t2 BUSY blocks are the remanant of
# the KILL ^b done in STEP 4 - KILL of an entire global will still have a single level TREE. We have to convert these blocks
# to V6 as well.

$echoline
echo "STEP 7 ==> More updates to ^b which will touch the remanant TREE from KILL ^b and hence upgrading them to V6"
$echoline
$gtm_exe/mumps -run %XCMD 'for i=1:1:10  set ^b(i)=$J(i,200)'
echo

$echoline
echo "### At this point, we have NO V4 BUSY blocks, but some V4 REUSABLE blocks and database is NOT Fully Upgraded ###"
$echoline
$DSE dump -file -all |& $grep -E "Blocks to Upgrade  |Fully Upgraded  "
echo

sleep 1 # So that the PBLKs and EPOCH written by the forthcoming REORG are with a different timestamp from the LAST EPOCH

$echoline
echo "STEP 8 ==> UPGRADE will touch all the REUSABLE blocks (remanant of KILL ^B) and will write their BEFORE IMAGES"
$echoline
$MUPIP reorg -upgrade -reg "*"
echo

$echoline
echo "STEP 9 ==> Get the time of the last PBLK record. This will be our -SINCE and -BEFORE time for the forthcoming RECOVER command"
$echoline
# The last PBLK record is written by the MUPIP REORG. What we are attempting here is to undo the PBLKs written by MUPIP REORG
# which will take the database just before the MUPIP REORG was attempted. At that point, cs_data->fully_upgraded was FALSE and hence
# RECOVER should update cs_data->fully_upgraded to FALSE. However, in V5.4-002 and before, the flag was untouched (i.e, remained
# TRUE) even after the RECOVER. This is an out-of-state design state since the database has V4 REUSABLE blocks but the file header
# will indicate that the database is fully upgraded.
#
# First get the extract of the journal file
$MUPIP journal -extract -noverify -detail -for -fences=none mumps.mjl
# Next, get the $H value of the last PBLK written
setenv pblk_dollarh `$tail mumps.mjf | $grep PBLK | $tail -n 1 | $tst_awk -F"\\" '{print $2}'` # setenv so we can use $ztrnlnm
echo $pblk_dollarh >&! dollarh.txt
# Then, get the $ZDATE value of this $H
set pblk_time = `$gtm_exe/mumps -run %XCMD 'write $zdate($ztrnlnm("pblk_dollarh"),"DD-MON-YEAR 24:60:SS")'`
echo $pblk_time >&! dollarzdate.txt
echo

# Before the recovery take a backup of the databases and journals so that we can rerun the below recovery command later if needed
$gtm_tst/com/backup_dbjnl.csh bak_before_recover "*.dat *.gld *.mj*" cp nozip

#
$echoline
echo "STEP 10 ==> RECOVER the database with a SINCE time set to the LAST PBLK record so that all the updates by REORG are undone"
$echoline
$MUPIP journal -recover -backward -verbose -since=\"$pblk_time\" -before=\"$pblk_time\" mumps.mjl >>&! MUPIP_RECOVER.log
$grep JNLSUCCESS MUPIP_RECOVER.log
echo

$echoline
echo "### At this point, cs_data->fully_upgraded should be FALSE ###"
$echoline
$DSE dump -file -all |& $grep -E "Blocks to Upgrade  |Fully Upgraded  "
echo

$echoline
echo "STEP 11 ==> Do a few updates in the final retry which will cause a reusable block to be read. We should see no errors/asserts"
$echoline
$gtm_exe/mumps -run c003344
echo

$gtm_tst/com/dbcheck.csh -noonline # Since the database is V4
