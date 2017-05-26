#!/usr/local/bin/tcsh -f
#
date
@ cnt = 0
while (1)
	@ cnt = $cnt + 1
	if ($cnt > 180) then
		echo "TEST-E-Timeout for concurrent mupip processes. Waited for 30 minutes"
		exit 1
	endif
        \ls ./NOT_DONE.*
        if ($status != 0) then
                echo "All concurrent mupip processes has exited now"
                echo "Test can end now"
                break
        else
                echo waiting for concurrent mupip processes to exit
                sleep 10
        endif
end
date
