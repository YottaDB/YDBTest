#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2009, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Pass name of the subtest to the driver script as the parameter
# dbcreate.csh called by createdb_start_updates.csh.
if ("HOST_LINUX_IX86" == "$gtm_test_os_machtype") then
	# The test can end up creating large databases (in the order of 500 MiB) and when run with MM, it might hit the per-process
	# limit on 32-bit Linux platforms causing the test to fail with GBLOFLOW/MMREGNOACCESS (which is not expected by the test).
	# So, on 32-bit Linux, force BG access method to avoid sporadic failures.
	source $gtm_tst/com/gtm_test_setbgaccess.csh
endif
set init_time = 90
setenv upd_time $init_time
set bkup_stop = 0
set change_permission = 0
if ($1 == "mu_bkup_stop") then
	set bkup_stop = 1
else if($1 == "mu_bkup_change_permission") then
	set change_permission = 1
     endif
else
	echo "TEST-E-ERROR Only mu_bkup_stop or mu_bkup_change_permission accepted as a paramter"
	exit
endif
@ round_no=1
while ($round_no < 4)
	setenv save_io 1
	if ($bkup_stop) then
		source $gtm_tst/$tst/u_inref/try_stop.csh >>& try_{$1}_{$round_no}.logx
		set exit_stat = $status
	else
		source $gtm_tst/$tst/u_inref/try_error.csh  >>& try_{$1}_{$round_no}.logx
		set exit_stat = $status
	endif
	if !($exit_stat) then
		cat try_{$1}_{$round_no}.logx
		if ($bkup_stop) then
			echo "Successful in stopping the backup process"
			source $gtm_tst/$tst/u_inref/successful_run.csh
		else
			echo "Successful in generating the error"
			stopfindfile
			source $gtm_tst/$tst/u_inref/final_run.csh
		endif
		exit
	else if ($round_no != 3) then
		if ($change_permission) then
			stopfindfile
		endif
		set back_dir = $GTM_BAKTMPDIR
		stopsubtest >>& stoptest_{$round_no}.log
		$gtm_tst/com/backup_dbjnl.csh round{$round_no} "*.dat *.gld *.mjl* *.log* *.txt time* *csh *.repl* *.out"
		mv *online1 $back_dir round{$round_no}		# backup_dbjnl.csh only works on regular files
		@ init_time = $init_time * 2
		setenv upd_time $init_time
	else #Final try over
		if ($bkup_stop) then
			echo "TEST-E-NOT_STOPPED All three tries to stop the backup failed. See try_stop* for details"
		else
			echo "TEST-E-ERROR,BACKUP was successful inspite of changing temp files permisssions. See try_error* for details"
			stopfindfile
		endif
	endif
	@ round_no = $round_no + 1
end
stopsubtest
$gtm_tst/com/dbcheck.csh
