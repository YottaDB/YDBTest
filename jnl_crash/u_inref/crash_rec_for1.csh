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
if ( "TRUE" == $gtm_test_unicode_support ) then
	if ($?gtm_chset) then
		setenv save_chset $gtm_chset
	endif
endif
setenv gtm_test_jobcnt 5
setenv gtm_test_dbfill "IMPTP"
set iteration = 3
$gtm_tst/com/dbcreate.csh mumps 9 125 1000 8192 2048 512 1000
$MUPIP set -journal=enable,on,nobefore -reg "*" |& sort -f
@ count = 0
while ($count < $iteration)
	@ count = $count + 1
	echo "GTM Process starts in background..."
	setenv gtm_test_jobid $count
	$gtm_tst/com/imptp.csh >>&! imptp.out
	source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
	sleep 60
	$gtm_tst/com/get_dse_df.csh "BEFORE_CRASH" "" "-all"
	echo "Crash ..."
	$gtm_tst/com/gtm_crash.csh
	$gtm_tst/com/imptp_handle_crash_asserts_cores.csh
	$gtm_tst/com/backup_dbjnl.csh save_${count} "*.dat *.mj*"
	\rm -f *.dat
	$MUPIP create |& sort -f
	source $gtm_tst/com/mupip_set_version.csh # re-do the mupip_set_version
	source $gtm_tst/com/change_current_tn.csh # re-change the cur tn
	echo "Recover..."
	echo "$MUPIP journal -recover -forward a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,h.mjl,mumps.mjl"
	set num=`$gtm_exe/mumps -run rand 3`
	if ( "TRUE" == $gtm_test_unicode_support ) then
		if ($num == 1) $switch_chset M  >>&  for1_${count}.log
		if ($num == 2) $switch_chset UTF-8  >>&  for1_${count}.log
	endif
	$MUPIP journal -recover -forward a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,h.mjl,mumps.mjl >>&  for1_${count}.log
        set stat1 = $status
	$grep "successful" for1_${count}.log
        set stat2 = $status
	ls *.mjl_forw_phase >& /dev/null
	set stat3 = $status
        cat *.mje*
	if ( "TRUE" == $gtm_test_unicode_support ) then
		if ($?save_chset) then
			$switch_chset $save_chset  >>&  for1_${count}.log
		else
			$switch_chset M  >>&  for1_${count}.log
		endif
	endif
	\rm -f *.o >>& for1_${count}.log
	if ($count != $iteration) then
        	$gtm_tst/com/dbcheck.csh -nosprgde
	else
        	$gtm_tst/com/dbcheck.csh
	endif
	$gtm_tst/com/checkdb.csh
	if ($stat1 != 0 || $stat2 != 0 || $stat3 == 0) then
                echo "crash_rec_for1 TEST FAILED on iteration $count"
                cat  for1_${count}.log
                exit 1
        endif
end
$gtm_tst/$tst/u_inref/check_prev.csh
echo "crash_rec_for1 TEST FINISHED"
