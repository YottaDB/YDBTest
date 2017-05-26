#!/usr/local/bin/tcsh -f
#
# the script is called to ensure "onlnread" mumps process is started at the background
# If the process for some reason cannot get started for more than the time specified we exit
# Argument $1 specifies the seconds to wait
# This avoids possible hang scenario in certain unexpected scenarios
#
if ( 0 == $#argv ) then
	echo "Pls. specify the time to wait"
	echo "usage: $gtm_tst/$tst/u_inref/wait_for_onlnread_to_start.csh <seconds to wait>"
	exit
endif
@ timer = 0
while (1)
	ls concurrent_job.out >&! /dev/null
	if ( 0 == $? ) then
		break
	else if ( $1 == $timer ) then
		echo "TEST-E-ERROR.Waited for too long.Background mumps process not started at all exiting...."
		exit
	else
		sleep 1
		@ timer = $timer + 1
	endif
end
