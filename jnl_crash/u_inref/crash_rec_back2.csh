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
# TEST GTM CRASH AND RECOVER
#
# HP gives problem, if multiple job compliles a module at the same time
if ( "TRUE" == $gtm_test_unicode_support ) then
	if ($?gtm_chset != 0) then
		setenv save_chset $gtm_chset
	endif
endif
$gtm_exe/mumps $gtm_tst/com/npfill.m
set iteration = 3
setenv gtm_test_maxdim 15
setenv gtm_test_parms "1,7"
setenv gtm_test_dbfill "IMPRTP"
$gtm_tst/com/dbcreate.csh mumps 6 125 1000 1024 500 8192 500
$MUPIP set -journal=enable,on,before -reg "*" |& sort -f
@ count = 0
while ($count < $iteration )
# Just to make sure we have enough PBLK records initially
# Note that imptp.m commits a few transactions only
	$GTM  << \xyz  >>& imptp.out
	w $J,!
	for kk=1:1:10 do in3^npfill("set",1,1)
	for kk=1:1:10 do in3^npfill("kill",1,1)
	h
\xyz
	@ count = $count + 1
	echo "GTM Process starts in background..."
	setenv gtm_test_jobid $count
	$gtm_tst/com/imptp.csh >>&! imptp.out
	source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
	sleep 90
	$gtm_tst/com/get_dse_df.csh "BEFORE_CRASH" "" "-all"
	cat *.mje*
	echo "Crash..."
	$gtm_tst/com/gtm_crash.csh
	if ($?test_debug) then
		$gtm_tst/com/backup_dbjnl.csh save_${count} "*.dat *.mj*"
	endif
	# From V43FT03 we have journal idempotency. So we do not have journal switch and can reuse journals"
	echo "Recover..."
	echo "$MUPIP journal -recover -backward *"
	set num=`$gtm_exe/mumps -run rand 3`
	if ( "TRUE" == $gtm_test_unicode_support ) then
		if ($num == 1) $switch_chset M  >>&  rec2_${count}.log
		if ($num == 2) $switch_chset UTF-8  >>&  rec2_${count}.log
	endif
	$MUPIP journal -recover -backward "*" >>&  rec2_${count}.log
	set stat1 = $status
	$grep "successful" rec2_${count}.log
	set stat2 = $status
	ls *.mjl_forw_phase >& /dev/null
	set stat3 = $status
	cat *.mje*
	if ( "TRUE" == $gtm_test_unicode_support ) then
		if ($?save_chset) then
			$switch_chset $save_chset  >>&  rec2_${count}.log
		else
			$switch_chset M  >>&  rec2_${count}.log
		endif
	endif
	if ($count != $iteration) then
		$gtm_tst/com/dbcheck_filter.csh -nosprgde
	else
		$gtm_tst/com/dbcheck_filter.csh
	endif
	$gtm_tst/com/checkdb.csh
	if ($stat1 != 0 || $stat2 != 0 || $stat3 == 0) then
		echo "crash_rec_back2 TEST FAILED on iteration $count"
		cat  rec2_${count}.log
		exit 1
	endif
end
$gtm_tst/$tst/u_inref/check_prev.csh
echo "crash_rec_back2 TEST PASSED"
