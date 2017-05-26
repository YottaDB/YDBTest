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
echo "Test case 29: C9B11-001780 Handling out of sync EPOCH  records"
$gtm_tst/com/dbcreate.csh mumps 2
echo mupip set -journal="enable,before" -reg '"*"'
$MUPIP set -journal="enable,before" -reg "*" |& sort -f
cp $gtm_tst/$tst/inref/c1780.m .
$gtm_exe/mumps -run c1780
#ipcrm -m
#ipcrm -s
set db_ftok_key = `$gtm_exe/ftok -id=43 *.dat| egrep "dat" | $tst_awk '{printf("%s ",$5);}'`
setenv ftok_key "$db_ftok_key"
set dbipc_private = `$gtm_tst/com/db_ftok.csh`
$gtm_tst/com/ipcrm $dbipc_private
$gtm_tst/com/rem_ftok_sem.csh # arguments $ftok_key
# Collecting the IDs of relinkctl shared memory segments from the RCTLDUMP is prohibitive, so clean directly.
$MUPIP rundown -relinkctl >&! mupip_rundown_rctl.logx
#$gtm_tst/com/ipcrmall
echo mupip journal -recover -back -since=\"0 00:00:00\" -look=\"time=0 00:00:00\" a.mjl,mumps.mjl
$MUPIP journal -recover -back -since=\"0 00:00:00\" -look=\"time=0 00:00:00\" a.mjl,mumps.mjl >& recov.out
$grep "successful" recov.out
$gtm_tst/com/dbcheck.csh
