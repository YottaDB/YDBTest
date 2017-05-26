#!/usr/local/bin/tcsh
# The following script sets the appropriate whitebox test case that causes the process to acquire a lock and then hold onto
# it for some seconds (hardcoded in the code).

set casenum = $1
set logfile = $2

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number $casenum

set dollar_sign = \$

if (49 == $casenum) then
	($gtm_exe/mumps -run %XCMD "set ^holder($casenum)=${dollar_sign}job" >&! $logfile & ; echo $! >! mumps_pid.log) >>&! bg_process.out
else
	# Backward recovery is the only process that holds onto the access control semaphore AND also does db_init
	# The whitebox test case 49 will cause the RECOVER process to sleep in db_init (while holding the access
	# control semaphore).
	($MUPIP journal -recov -back mumps.mjl >&! $logfile & ; echo $! >! mumps_pid.log) >>&! bg_process.out
endif
