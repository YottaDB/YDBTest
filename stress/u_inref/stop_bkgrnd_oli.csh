#!/usr/local/bin/tcsh

if (! -e NOT_DONE.OLI) exit # means ONLINE INTEG never started before

date
echo "Stop ONLINE INTEG"

\touch OLI.STOP

set timeout = 1800
while ($timeout > 0)
	\ls ./NOT_DONE.OLI
	if ($status != 0) then
		echo "NOT_DONE.OLI does not exist"
		echo "All ONLINE INTEG processes have been completed. Test can end now"
		break
	else
		echo "Waiting for ONLINE INTEG processes to complete"
		sleep 5
	endif	
	@ timeout = $timeout - 5
end
if ($timeout <= 0) then
	echo "TEST-E-TIMEOUT waiting for NOT_DONE.OLI to be removed. Please check the ONLINE INTEG processes if it's hung"
endif	

