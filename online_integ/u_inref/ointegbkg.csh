#!/usr/local/bin/tcsh -f
# This help script will run online integs in the background

@ num = 1
# This script is invoked from the profile test suite at a point where the source servers is not yet started and hence there isn't
# any mumps.repl file available. If $gtm_custom_errors is defined at this point, then the INTEG done below will issue FTOKERR/ENO2 # errors due to non-existence of mumps.repl file. Temporarily unsetenv gtm_repl_instance for this purpose.
unsetenv gtm_repl_instance
while ($num < 5)
	set mupip_log1 = "mupip_log1.log"
	($MUPIP integ $FASTINTEG -online -preserve -r "*" >>&! $mupip_log1 &; echo $! >! mupip_pid.log) >&! fork_integ.log
	set mupip_pid = `cat mupip_pid.log`
	$gtm_tst/com/wait_for_proc_to_die.csh $mupip_pid 1800 >>&! wait_for_integ_to_complete.out 
	sleep 180
	@ num = $num + 1
end

