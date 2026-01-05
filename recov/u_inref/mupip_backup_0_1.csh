#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
unsetenv test_replic
setenv test_reorg "NON_REORG"
source $gtm_tst/com/set_crash_test.csh	# sets YDBTest and YDB-white-box env vars to indicate this is a crash test
# Cannot use triggers while turning journaling on and off
setenv gtm_test_trigger 0
$gtm_tst/com/dbcreate.csh mumps 8 125 1000 1024 4096 1024 4096
echo "$MUPIP set -journal=enable,off,before -reg *"
## $MUPIP set -journal=enable,off,before -reg "*" |& sort -f
$MUPIP set -journal=enable,off,before -reg "*" |& sort -f
echo "Multi-Process GTM Process starts in background..."
$gtm_tst/com/imptp.csh "5" >&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep 120
\mkdir ./backup
echo "$MUPIP backup * -newj ./backup"
### $MUPIP backup "*" -newj ./backup |& sort -f
$MUPIP backup "*" -newj ./backup  >& back.out
if ($status) then
	echo "TEST-E-BACKUPFAIL Mupip backup failed. Test Failed"
	# Pause the IMPTP processes before exiting as otherwise they would soon fill up the disk
	# Do not stop/kill them as they might have important debugging information in case of process hangs etc.
	$ydb_dist/mumps -run %XCMD 'do pause^pauseimptp'
	exit
endif
$grep BACKUPSUCCESS back.out
sleep 30
$gtm_tst/com/gtm_crash.csh
#
if ($?test_debug) then
	\mkdir ./save; \cp {*.dat,*.mj*} ./save
endif
#
echo "$MUPIP journal -recover -backward *"
$MUPIP journal -recover -backward "*" >>&! recover1.out
set recstat = $status
$grep "successful" recover1.out
if ($recstat != 0) then
	echo "TEST-E-RECOVFAIL Mupip recover failed. Test FAILED"
	exit
endif
$gtm_tst/com/dbcheck_filter.csh
if ($status) exit
#
echo "Extact from database..."
$MUPIP extract tmp.glo >>& extract.out
if ($status) echo "Extract fails"
$tail -n +3  tmp.glo >! data2.glo
\rm -f tmp.glo
#
\rm *.dat
\cp ./backup/*.dat .
sleep 10
echo "$MUPIP journal -recover -forward a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,mumps.mjl"
$MUPIP journal -recover -forward a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,mumps.mjl >>&! recover2.out
$grep -vE "MUJNLSTAT|MUJNLPREVGEN" recover2.out
$gtm_tst/com/dbcheck.csh -nosprgde
$gtm_tst/com/checkdb.csh
if ($status) exit
#
$MUPIP extract tmp.glo >>& extract.out
if ($status) echo "Extract fails"
$tail -n +3  tmp.glo >! data3.glo
\rm -f tmp.glo
echo "diff data2.glo data3.glo"
$tst_cmpsilent data2.glo data3.glo
if ($status) echo "TEST falied in MUPIP recover"
$grep -E "YDB-E|YDB-F" *.out
cat *.mje*
