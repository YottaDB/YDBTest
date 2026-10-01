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
echo '# [YDB#1289] MUPIP LOAD of a ZWR file with many $ze(...) records stays within its line buffer         #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# go_load.c read every line of the file into a 9,446,402 byte buffer, but each $ze(...) record left'
echo '# the read position 4 bytes further into it. After about 2,361,600 such records, lines were copied'
echo '# past the end of the buffer, and MUPIP LOAD reported errors on valid records or died with a SIG-11.'
echo '#'
echo '# The file loaded here has 3,000,000 $ze(...) records. Stages 2 and 3 fail without the fix.'
echo

# The ZWR file is written in M mode, so load it in M mode
$switch_chset M >& switch_chset_m.out
# 3,000,000 updates would write a large journal file to no purpose, so disable test-system dictated journaling
setenv gtm_test_jnl NON_SETJNL
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
	exit -1
endif

cp $gtm_tst/$tst/inref/ydb1289.m .

echo '# Stage 1 : write the ZWR file ze.zwr, a 2 line header and 3,000,000 records $ze(^a(i#1000+1),0,1)=$char(97+(i#26))'
echo '# Command : $ydb_dist/yottadb -run gen^ydb1289 ze.zwr'
echo '#   expect 3,000,002 lines, each record line of the form $ze(^a(<n>),0,1)="<letter>"'
$ydb_dist/yottadb -run gen^ydb1289 ze.zwr
set nlines = `wc -l < ze.zwr`
set nrecs = `$grep -Ec '^[$]ze[(]\^a[(][0-9]+[)],0,1[)]="[a-z]"$' ze.zwr`
if ((3000002 == $nlines) && (3000000 == $nrecs)) then
	echo "PASS : ze.zwr has 3000002 lines, 3000000 of them records of the expected form"
else
	echo "WRONG : ze.zwr has $nlines lines and $nrecs records of the expected form, expected 3000002 and 3000000"
endif
echo

echo '# Stage 2 : load the file'
echo '# Command : $ydb_dist/mupip load ze.zwr'
echo '#   expect exit status 0, no error message, and a key count of 3000000'
$ydb_dist/mupip load ze.zwr >& load.out
set loadstat = $status
set nerrs = `$grep -Ec -- '-[EFW]-' load.out`
set keycnt = `$tst_awk '/^LOAD TOTAL/ {print $5}' load.out`
if (0 == $loadstat) then
	echo "PASS : MUPIP LOAD exited with status 0"
else
	echo "WRONG : MUPIP LOAD exited with status $loadstat, expected 0"
endif
if (0 == $nerrs) then
	echo "PASS : MUPIP LOAD issued no error or warning message"
else
	echo "WRONG : MUPIP LOAD issued $nerrs error or warning messages, expected none. The first few follow."
	$grep -E -- '-[EFW]-' load.out | head -5
endif
if ("3000000" == "$keycnt") then
	echo "PASS : MUPIP LOAD reported a key count of 3000000"
else
	echo "WRONG : MUPIP LOAD reported a key count of [$keycnt], expected 3000000"
endif
echo

echo '# Stage 3 : check the loaded data'
echo '# Command : $ydb_dist/yottadb -run check^ydb1289'
echo '#   expect ^a(1) to ^a(1000) to exist, and each to hold the letter of the last record that set it'
$ydb_dist/yottadb -run check^ydb1289
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif

echo "# Done"
