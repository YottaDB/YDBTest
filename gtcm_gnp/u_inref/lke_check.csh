#!/usr/local/bin/tcsh -f
# $1 : gtm_tst
# $2 SEC_DIR_GTCM_x
# $3 hostnumber
# $4 name to check
# $5 waitforlog yes or no
setenv gtm_tst $1
setenv SEC_DIR_GTCM_x $2
setenv hostnumber $3
setenv lockname $4
unsetenv waitforlog
if ("yes" == $5) setenv waitforlog $5

cd $SEC_DIR_GTCM_x

source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_x

if ($?waitforlog) then
	$gtm_tst/com/wait_for_log.csh -log lock${lockname}.out -message "ZAllocated at:" -duration 600 -waitcreation
endif

set x = 20
while ($x)
	$gtm_exe/lke show all >& lock${lockname}.out_$x
	$grep -q -E "\^${lockname}.*existing process" lock${lockname}.out_$x
	if !($status) then
		echo "Lock status from remote host ${hostnumber}:"
		sed s'/PID= [0-9]*/PID= <PID>/' lock${lockname}.out_$x
		exit 0
	else
		@ x = $x - 1
		sleep 5
	endif
end
exit 3
