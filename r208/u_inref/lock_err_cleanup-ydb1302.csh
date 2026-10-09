#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#--------------------------------------------------------------------------------------------------#"
echo "# [YDB#1302] An error inside a LOCK makes a later incremental LOCK of the same name report success #"
echo "# without acquiring it, and makes the next simpleAPI lock call fail with BADLOCKNEST               #"
echo "#--------------------------------------------------------------------------------------------------#"
echo
echo '# While a LOCK is processed, lks_this_cmd counts its names and the trans flag of each name is set.'
echo '# An error that interrupted the LOCK left the flags set, so a later incremental LOCK of such a name'
echo '# did not count it, and returned success without acquiring it. The simpleAPI error handler also left'
echo '# lks_this_cmd set, so the next simpleAPI lock call issued BADLOCKNEST.'
echo '#'
echo '# Without the fix, stages 1 to 3 and 5 each print WRONG for the lock taken after the error: a timed LOCK +'
echo '# sets $TEST to 1, and an untimed one returns at once, without acquiring the lock (even if another process'
echo '# holds it), and a simpleAPI lock call returns BADLOCKNEST, or YDB_OK without acquiring the lock.'
echo

$gtm_tst/com/dbcreate.csh mumps 2 >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif
cp $gtm_tst/$tst/inref/ydb1302.m .

echo '# Stage 1 : LOCK (alock,alock(<256 bytes>)), which issues LOCKSUB2LONG, then LOCK +alock:5'
echo '# Command : $ydb_dist/yottadb -run sub2long^ydb1302'
echo '#   expect LOCK +alock:5 to set $TEST to 1 and ZSHOW "L" to show alock held'
$ydb_dist/yottadb -run sub2long^ydb1302
echo

echo '# Stage 2 : LOCK +(clock,dlock($$nest)), where $$nest does a LOCK and so issues BADLOCKNEST, then'
echo '#           LOCK +clock:5'
echo '# Command : $ydb_dist/yottadb -run nested^ydb1302'
echo '#   expect LOCK +clock:5 to set $TEST to 1 and ZSHOW "L" to show clock held'
$ydb_dist/yottadb -run nested^ydb1302
echo

echo '# Stage 3 : the same errors in simpleAPI lock calls'
echo '# Command : build and run ydb1302_sapi.c'
echo '#   expect each lock call after the error to return YDB_OK, and another process to find the lock held'
set file = ydb1302_sapi
$gt_cc_compiler $gtt_cc_shl_options -I$ydb_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map
./$file
echo

echo '# Stage 4 : LOCK -(^a,^x), where AREG (the region of ^a) shares LOCK crit with database crit and its file'
echo '#           header is marked corrupt. LOCK - releases ^x and removes it from the list of locks, then'
echo '#           issues DBFLCORRP for ^a, leaving lks_this_cmd larger than the list.'
echo '# Commands: $MUPIP SET -REGION AREG -LCK_SHARES_DB_CRIT'
echo '#           $ydb_dist/yottadb -run crit^ydb1302'
echo '#   expect DBFLCORRP, and the process to continue. A build whose error handler clears the trans flags'
echo '#   (lckclr()) without lckclr() stopping at the end of the list gets a SIG-11 in the handler instead.'
$MUPIP set -region AREG -lck_shares_db_crit >& mupip_set_lck_shares_db_crit.out
$grep -q "now has LOCK sharing crit with DB  TRUE" mupip_set_lck_shares_db_crit.out
if ($status) then
	echo "WRONG : MUPIP SET -LCK_SHARES_DB_CRIT did not report TRUE. Output follows."
	cat mupip_set_lck_shares_db_crit.out
else
	echo "PASS : MUPIP SET -LCK_SHARES_DB_CRIT reported TRUE for AREG"
endif
$ydb_dist/yottadb -run crit^ydb1302
echo

echo '# Stage 5 : LOCK (ulock,ulock(<256 bytes>)), which issues LOCKSUB2LONG, then an untimed LOCK +ulock while'
echo '#           a child process holds ulock for 2 seconds'
echo '# Command : $ydb_dist/yottadb -run untimed^ydb1302'
echo '#   expect LOCK +ulock to wait until the child process releases ulock, and then to hold it. Without the'
echo '#   fix, it returns at once without acquiring ulock.'
$ydb_dist/yottadb -run untimed^ydb1302
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif

echo "# Done"
