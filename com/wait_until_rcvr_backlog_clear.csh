#!/usr/local/bin/tcsh -f
set timeout = $1
if ("" == "$timeout") set timeout = 300
set sleepinc = 5
while ($timeout > 0)
	$gtm_tst/com/is_rcvr_backlog_clear.csh
	if (! $status) exit 0
	sleep $sleepinc
	@ timeout = $timeout - $sleepinc
end
exit 1
