#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test needs to use backword recovery and hence before image journaling (check hold_onto_lock.csh for reason). So force BG access method
source $gtm_tst/com/gtm_test_setbgaccess.csh
setenv gtm_test_jnl "SETJNL"
setenv tst_jnl_str "-journal=enable,on,before"

echo "############################## FTOK SEMAPHORE TESTING ################################"
echo
set cnt = 1
set randomwait = `$gtm_exe/mumps -run %XCMD 'write $random(20)+1'`
set max_wait_vals = (0 $randomwait -1)
set max_wait_msg = ("immediate exit" "wait for atmost $randomwait seconds" "wait indefinitely")
echo ""
while (3 >= $cnt)
	echo "CASE $cnt : Testing gtm_db_startup_max_wait environment variable with value set to $max_wait_vals[$cnt] - $max_wait_msg[$cnt]"
	echo "---------------------------------------------------------------------------------------------------------------------"
	# Create fresh databases
	set bkupdir = "bkup`date +%H%M%S`"
	if (-f mumps.dat) then
		$gtm_tst/com/backup_dbjnl.csh $bkupdir "*.dat *.mj* mumps_pid.log" mv
	endif
	$gtm_tst/com/dbcreate.csh mumps 1
	# Touch the output file so that we can do wait_for_log with -message instead of first doing -waitcreation and then
	# doing -message
	touch hold_onto_ftok_$cnt.out
	# Start a background process that will hold onto the ftok lock
	echo "---> Start a GT.M process and let it hold onto FTOK lock"
	($gtm_tst/$tst/u_inref/hold_onto_lock.csh 49 hold_onto_ftok_$cnt.out &) >>&! bkgrnd_exec_$cnt.out
	$gtm_tst/com/wait_for_log.csh -log hold_onto_ftok_$cnt.out -message "Holding the ftok semaphore"
	# Set the appropriate wait time
	setenv gtm_db_startup_max_wait $max_wait_vals[$cnt]
	# Do a SET by contending for the ftok - currently held by the other process
	echo "---> Now that the process is holding onto the FTOK, start another process to cause FTOK contention"
	if (2 >= $cnt) then
		echo "---> This should cause SEMWT2LONG error"
	else
		echo "---> This is the indefinite wait case. The FTOK contender will get the semaphore eventually"
	endif
	$gtm_exe/mumps -run %XCMD 'write "FTOK contender = ",$job,!  set ^ftokcontender=$job' >&! ftokcontender_$cnt.out
	# Now that we got what we wanted, kill the background process and continue with the next iteration
	set bkgrnd_pid = `cat mumps_pid.log`
	if (2 >= $cnt) then
		# For no wait ($gtm_db_startup_max_wait) and non-negative wait, the background process will still exist after the
		# above foreground process error'ed out with either a CRITSEMFAIL or SEMWT2LONG error.
		$kill9 $bkgrnd_pid
		$MUPIP rundown -reg "*" >>&! mupip_rundown_$bkgrnd_pid.out
		$MUPIP rundown -relinkctl >&! mupip_rundown_ctl_$bkgrnd_pid.outx
		$gtm_tst/com/check_error_exist.csh ftokcontender_$cnt.out "GTM-E-DBFILERR" "GTM-E-SEMWT2LONG"
	else
		# For the indefinite wait ($gtm_db_startup_max_wait = -1), both the process will succeed eventually and hence at
		# this point we won't have the background process alive for killing it.
		$gtm_tst/com/wait_for_proc_to_die.csh $bkgrnd_pid 120 # Wait for the process to die (in case the system is loaded)
	endif
	# Since no wait and non-negative wait cases failed, the updates they did ^ftokcontender should not have made their
	# way into the database/journal. Extract the journal file and verify this. However, the indefinite wait case will
	# succeed and hence we should be able to see ^ftokcontender in that case
	$MUPIP journal -extract -noverify -detail -for -fences=none mumps.mjl
	$grep ftokcontender mumps.mjf | $tst_awk -F\\ '{print $NF}'
	@ cnt = $cnt + 1
	echo
end
echo
echo "############################## FTOK SEMAPHORE TESTING ENDS ################################"
echo
echo
echo "############################## ACCESS CONTROL SEMAPHORE TESTING ################################"
echo
set cnt = 1
set randomwait = `$gtm_exe/mumps -run %XCMD 'write $random(20)+1'` # The whitebox test case will wait for 30 seconds
set max_wait_vals = (0 $randomwait -1)
set max_wait_msg = ("immediate exit" "wait for atmost $randomwait seconds" "wait indefinitely")
echo
while (3 >= $cnt)
	echo "CASE $cnt : Testing gtm_db_startup_max_wait environment variable with value set to $max_wait_vals[$cnt] - $max_wait_msg[$cnt]"
	echo "---------------------------------------------------------------------------------------------------------------------"
	# Create fresh databases
	set bkupdir = "bkup`date +%H%M%S`"
	if (-f mumps.dat) then
		$gtm_tst/com/backup_dbjnl.csh $bkupdir "*.dat *.mj* mumps_pid.log" mv
	endif
	$gtm_tst/com/dbcreate.csh mumps 1
	# Touch the output file so that we can do wait_for_log with -message instead of first doing -waitcreation and then doing
	# -message
	touch hold_onto_access_$cnt.out
	# Start a background process that will hold onto the access lock
	echo "---> Start a MUPIP RECOVER process and let it hold onto access control lock"
	($gtm_tst/$tst/u_inref/hold_onto_lock.csh 50 hold_onto_access_$cnt.out &) >>&! bkgrnd_exec_$cnt.out
	$gtm_tst/com/wait_for_log.csh -log hold_onto_access_$cnt.out -message "Holding the access control semaphore"
	# Set the appropriate wait time
	setenv gtm_db_startup_max_wait $max_wait_vals[$cnt]
	# Do a SET by contending for the access - currently held by the other process
	echo "---> Now that the process is holding onto the ACCESS control lock, start another process to cause contention"
	if (2 >= $cnt) then
		echo "---> This should cause SEMWT2LONG error"
	else
		echo "---> This is the indefinite wait case. The ACCESS control lock contender will get the semaphore eventually"
	endif
	$gtm_exe/mumps -run %XCMD 'write "ACCESS SEM contender = ",$job,!  set ^accsemcontender=$job' >&! accsemcontender_$cnt.out
	# Now that we got what we wanted, kill the background process and continue with the next iteration
	set bkgrnd_pid = `cat mumps_pid.log`
	if (2 >= $cnt) then
		# For no wait ($gtm_db_startup_max_wait) and non-negative wait, the background process will still exist after the
		# above foreground process error'ed out with either a CRITSEMFAIL or SEMWT2LONG error.
		$kill9 $bkgrnd_pid
		$MUPIP rundown -reg "*" >>&! mupip_rundown_$bkgrnd_pid.out
		$MUPIP rundown -relinkctl >&! mupip_rundown_ctl_$bkgrnd_pid.outx
		$gtm_tst/com/check_error_exist.csh accsemcontender_$cnt.out "GTM-E-DBFILERR" "GTM-E-SEMWT2LONG"
	else
		# For the indefinite wait ($gtm_db_startup_max_wait = -1), both the process will succeed eventually and hence at
		# this point we won't have the background process alive for killing it.
		$gtm_tst/com/wait_for_proc_to_die.csh $bkgrnd_pid 120 # Wait for the process to die (in case the system is loaded)
	endif
	# Since no wait and non-negative wait cases failed, the updates they did ^accsemcontender should not have made their
	# way into the database/journal. Extract the journal file and verify this. However, the indefinite wait case will
	# succeed and hence we should be able to see ^accsemcontender in that case
	$MUPIP journal -extract -noverify -detail -for -fences=none mumps.mjl
	$grep accsemcontender mumps.mjf | $tst_awk -F\\ '{print $NF}'
	@ cnt = $cnt + 1
	echo
end
echo
echo "############################## ACCESS CONTROL SEMAPHORE TESTING ENDS ################################"

$gtm_tst/com/dbcheck.csh
