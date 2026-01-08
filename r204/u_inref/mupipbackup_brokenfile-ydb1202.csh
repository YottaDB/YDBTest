#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# -------------------------------------------------------------------------------------------------------------'
echo '# Test YDB#1202 : Mupip backup -online does not produce broken backup file when the backup'
echo '# is being performed on a disk partition different from the one where the database itself resides'
echo '# -------------------------------------------------------------------------------------------------------------'
echo

setenv acc_meth BG
echo '# Create a database'
$gtm_tst/com/dbcreate.csh mumps -record_size=1048576 >&! dbcreate.out

eval 'set testareas = ($gtm_tstdir_'${HOST}')'
set bak = "`echo $testareas | cut -f 2 -d ' '`/$USER/$gtm_tst_out/$testname"
echo "# Create a backup directory on another disk partition [mkdir $bak]"
mkdir -p $bak
echo '# Run [$gtm_dist/mupip backup -replace -database -online "DEFAULT" TARGETDIR/mumps.dat] in the background'
($gtm_dist/mupip backup -replace -database -online "DEFAULT" $bak/mumps.dat & ; echo $! >&! mupip-backup.pid ) >&! mupip-backup.out
echo "# Run updates in the foreground while the backup is running in the background:"
echo '# [$gtm_dist/mumps -run %XCMD '"'kill ^test for i=1:1:1000 set ^test(i)="'$j("q",1024)'"']"
$gtm_dist/mumps -run %XCMD 'kill ^test for i=1:1:1000 set ^test(i)=$j("q",1024)'

$gtm_tst/com/wait_for_proc_to_die.csh `cat mupip-backup.pid`
echo '# Run [$gtm_dist/mupip integ -fast TARGETDIR/mumps.dat]'
($gtm_dist/mupip integ -fast $bak/mumps.dat & ; echo $! >&! mupip-integ.pid ) >&! mupip-integ.out
$gtm_tst/com/wait_for_proc_to_die.csh `cat mupip-integ.pid`
echo '# Expect NO integrity errors (e.g. DBMRKBUSY, DBTNTOOLG, etc.) in [mupip-integ.out]'
echo '# Previously, in r2.02, DBMRKBUSY and DBTNTOOLG would be emitted by MUPIP INTEG.'
echo '# The test framework will examine MUPIP INTEG output for errors and, if present, display them below.'

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
