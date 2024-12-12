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
# TEST GTM CRASH AND RECOVER BACKWARD
#
set iteration = 3
$gtm_tst/com/dbcreate.csh mumps 9 125 1000 4096 2000 4096 2000
echo "$MUPIP set -journal=enable,on,buff=512,before -reg *" >>& jnl_on.log
$MUPIP set -journal=enable,on,buff=512,before -reg "*" >>& jnl_on.log
$GTM  << \xyz  >>& imptp.out
w $J,!
for kk=1:1:10 do in3^npfill("set",1,1)
for kk=1:1:10 do in3^npfill("kill",1,1)
h
\xyz
source $gtm_tst/com/get_abs_time.csh
@ count = 0
while ($count < $iteration)
	@ count = $count + 1
	echo "Start Iteration $count"
	echo "GTM Process starts in background..."
	setenv gtm_test_jobid $count
	$gtm_tst/com/imptp.csh >>&! imptp.out
	source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
	if ($count == 1) sleep 120
	sleep 30
	$gtm_tst/$tst/u_inref/pini_pfini.csh >>& pini_pfini.out
	if ($count > 2) source $gtm_tst/com/get_abs_time.csh
	set filea = a_${count}.mjl
	echo "$MUPIP set -journal=enable,on,before,file=$filea -reg AREG"
	echo "$MUPIP set -journal=enable,on,before,file=$filea -reg AREG" >>& jnl_on.log
	$MUPIP set -journal=enable,on,before,file=$filea -reg AREG  >>& jnl_on.log
	set filemumps = mumps_${count}.mjl
	echo "$MUPIP set -journal=enable,on,before,file=$filemumps -reg DEFAULT"
	echo "$MUPIP set -journal=enable,on,before,file=$filemumps -reg DEFAULT" >>& jnl_on.log
	$MUPIP set -journal=enable,on,before,file=$filemumps -reg DEFAULT  >>& jnl_on.log
	sleep 10
	echo "Crash ..."
	$gtm_tst/com/get_dse_df.csh "BEFORE_CRASH" "" "-all"
	$gtm_tst/com/gtm_crash.csh
	if ($?test_debug) then
		$gtm_tst/com/backup_dbjnl.csh save_${count} "*.dat *.mj*"
	endif
	echo "Recover..."
	# From V44002 we have journal idompotency. So we can reuse journals"
	# From V43000 since_time = 0:0:0 by default
	echo "$MUPIP journal -recover -backward * -since=<gtm_test_since_time>"
	$MUPIP journal -recover -backward "*" -since=\"$gtm_test_since_time\"  >>& recover_${count}.log
	set stat1 = $status
	$grep "successful" recover_${count}.log
	set stat2 = $status
	if ($stat1 != 0 || $stat2 != 0) then
		echo "crash_rec_back1 TEST FAILED on iteration $count"
		cat  recover_${count}.log
		exit 1
	endif
	echo "$MUPIP journal -recover -backward * -since=<gtm_test_since_time>"
	echo "$MUPIP journal -recover -backward * -since=$gtm_test_since_time"  >>& recover_${count}.log
	$MUPIP journal -recover -backward "*" -since=\"$gtm_test_since_time\"  >>& recover_${count}.log
	if ($status) then
		echo "crash_rec_back1 TEST FAILED on iteration $count"
		exit 2
	endif
	cat *.mje*
	if ($count != $iteration) then
		$gtm_tst/com/dbcheck_filter.csh -nosprgde
	else
		$gtm_tst/com/dbcheck_filter.csh
	endif
	$gtm_tst/com/checkdb.csh
	echo "End Iteration $count"
end
$gtm_tst/$tst/u_inref/check_prev.csh
echo "crash_rec_back1 TEST PASSED"
