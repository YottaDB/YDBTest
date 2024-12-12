#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST GTM CRASH AND RECOVER FORWARD
#
# HP gives problem, if multiple job compliles a module at the same time
$gtm_exe/mumps $gtm_tst/com/npfill.m
set iteration = 3
setenv gtm_test_maxdim 15
setenv gtm_test_parms "1,7"
setenv gtm_test_dbfill "IMPRTP"
$gtm_tst/com/dbcreate.csh mumps 9 125 1000 1024 500 8192 500
$gtm_tst/com/backup_dbjnl.csh last_data "*.dat" cp nozip
@ count = 0
while ($count < $iteration)
	@ count = $count + 1
	$MUPIP set -journal=enable,on,nobefore -reg "*" |& sort -f
	echo "GTM Process starts in background..."
	setenv gtm_test_jobid $count
	$gtm_tst/com/imptp.csh >>&! imptp.out
	source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
	sleep 120
	$gtm_tst/com/get_dse_df.csh "BEFORE_CRASH" "" "-all"
	echo "Crash ..."
	$gtm_tst/com/gtm_crash.csh
	if ($?test_debug) then
		$gtm_tst/com/backup_dbjnl.csh save_${count} "*.dat *.mj*"
	endif
	\cp ./last_data/*.dat .
	echo "Recover..."
	echo "$MUPIP journal -recover -forward a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,h.mjl,mumps.mjl"
	$MUPIP journal -recover -forward a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,h.mjl,mumps.mjl >>&  for2_${count}.log
	set stat1 = $status
	$grep "successful" for2_${count}.log
	set stat2 = $status
	ls *.mjl_forw_phase >& /dev/null
	set stat3 = $status
	cat *.mje*
	if ($count != $iteration) then
		$gtm_tst/com/dbcheck.csh -nosprgde
	else
		$gtm_tst/com/dbcheck.csh
	endif
	$gtm_tst/com/checkdb.csh
	if ($stat1 != 0 || $stat2 != 0 || $stat3 == 0) then
		echo "crash_rec_for2 TEST FAILED on iteration $count"
		cat  for2_${count}.log
		exit 1
	endif
	\rm last_data/*.dat ; \cp *.dat ./last_data	# BYPASSOK backup_dbjnl.csh
end
$gtm_tst/$tst/u_inref/check_prev.csh
echo "crash_rec_for2 TEST FINISHED"
