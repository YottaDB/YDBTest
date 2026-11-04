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
echo "#----------------------------------------------------------------------------------------------------#"
echo '# [YDB#1358] DSE CACHE -VERIFY does not fail an assert on a local bitmap in the hole of a database     #'
echo '# created with ydb_test_4g_db_blks                                                                   #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# With the ydb_test_4g_db_blks env var set to N (honored only in Debug builds), local bitmaps 1 to N-1'
echo '# of a new database file are never written, and a read of any block in that hole returns a zeroed'
echo '# buffer. A process can read such a block into the cache for a transaction that then restarts.'
echo '# wcs_verify() skipped the block certification for such a block if it was not a bitmap, but always'
echo '# certified a bitmap, so DSE CACHE -VERIFY of a cache holding a bitmap from the hole issued DBLVLINC'
echo '# and failed the assert (expect_damage) in wcs_verify.c. Here DSE DUMP brings such a bitmap into the'
echo '# cache. Each stage prints PASS or FAIL for each check.'
echo

# Fix the hole at bitmaps 1 to 3 (blocks 0x200 to 0x7FF) whatever the random setting was. The hole exists only if the
# allocation is more than one local bitmap, and it needs a deferred allocation and a V7 database (a V6 MUPIP CREATE
# knows nothing of it). DSE CACHE works only with BG.
setenv ydb_test_4g_db_blks 4
setenv acc_meth BG
setenv gtm_test_use_V6_DBs 0
echo "setenv ydb_test_4g_db_blks 4"	>> settings.csh
echo "setenv acc_meth BG"		>> settings.csh
echo "setenv gtm_test_use_V6_DBs 0"	>> settings.csh

$gtm_tst/com/dbcreate.csh mumps 1 -allocation=1000 -defer_allocate >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows"
	cat dbcreate.out
	exit 1
endif
$gtm_dist/mumps -run %XCMD 'for i=1:1:100 set ^x(i)=$justify(i,200)'

foreach stage (1 2)
	if (1 == $stage) then
		set blk = 200
		echo '# Stage 1 : DSE DUMP -BLOCK=200 (local bitmap 1, in the hole), then DSE CACHE -VERIFY'
		echo '# Before the fix : DBLVLINC for block 0x200, then an assert failure (expect_damage) in wcs_verify.c'
		echo '# With the fix   : expect the cache verification to be clean'
	else
		set blk = 0
		echo '# Stage 2 : DSE DUMP -BLOCK=0 (local bitmap 0, ahead of the hole), then DSE CACHE -VERIFY'
		echo '# Before the fix : the cache verification is clean (this stage is a control)'
		echo '# With the fix   : expect the cache verification to be clean'
	endif
	echo '# Command : $DSE with "dump -block='$blk' -header" and "cache -verify"'
	$DSE >& dse_stage$stage.out << DSE_EOF
dump -block=$blk -header
cache -verify
DSE_EOF
	if (`$grep -c "Region DEFAULT      : Cache verification is clean" dse_stage$stage.out` == 1) then
		echo "PASS : the cache verification is clean"
	else
		echo "FAIL : the cache verification is not clean. dse_stage$stage.out follows"
		cat dse_stage$stage.out
	endif
	if (`$grep -cE "YDB-[EFW]-|YDB-I-DBLVLINC" dse_stage$stage.out` == 0) then
		echo "PASS : DSE issued no error"
	else
		echo "FAIL : DSE issued an error"
	endif
	echo
end

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows"
	cat dbcheck.out
endif
echo "# Done"
