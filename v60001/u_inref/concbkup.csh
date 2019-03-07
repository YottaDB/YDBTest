#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# The test verifies that the backup started concurrently to the already running backup issues YDB-E-BKUPRUNNING error.
# The test starts backup processes one after another in the foreground as well as in the background expecting that
# at least in one of the cases out of 1000, the 'YDB-E-BKUPRUNNING' case will be hit.

$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run %XCMD 'for i=1:1:10000 set ^a(i)=$j(i,256)'
@ count = 1
$gtm_exe/mumps -run %XCMD 'set ^ready=0'
mkdir backup_fg
(source $gtm_tst/$tst/u_inref/concbkup_bg.csh & ; echo $! >&! concbkup_bg.pid) >&! concbkup_bg.out
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 83
@ max_conc_bkups = 1000
while ( $count <= $max_conc_bkups )
	rm backup_fg/* >&! delete_fg.out
	$MUPIP backup "*" backup_fg/ >&! backup_fg_$count.out
	$grep -q "BKUPRUNNING" backup_fg_$count.out
	if ( 0 == $status ) then
		$gtm_exe/mumps -run %XCMD 'set ^ready=1'
		set errlog = "backup_fg_$count.out"
		break
	else
		@ ready = `$gtm_exe/mumps -run %XCMD 'w ^ready'`
		if ( 1 == $ready) then
			break
		endif
	if ( 1000 == $count ) then
		break
	endif
	@ count = $count + 1
end

set bgpid = `cat concbkup_bg.pid`
$gtm_tst/com/wait_for_proc_to_die.csh $bgpid

if (! $?errlog) then
	# The error should have occurred in the bg process
	set errlog = "concbkup_bg.out"
endif

$grep BKUPRUNNING $errlog |& sed 's/Process [0-9][0-9]* is/Process ##PID## is/'
$gtm_tst/com/knownerror.csh $errlog "BKUPRUNNING|MUNOFINISH"

$gtm_tst/com/dbcheck.csh
