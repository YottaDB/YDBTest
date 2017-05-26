#!/usr/local/bin/tcsh

set looptime = $1
set pidsrc = $2
# if the value of looptime is between 0 and 10 get one lsof iteration so lsof2_loop.txt has one
# entry between lsof1.txt and lsof2.txt.
# Previously this value was never less than 15 but can now be as low as 0
while ($looptime >= 0)
	date >>& lsof2_loop.txt
	$lsof -p $pidsrc >>& lsof2_loop.txt
	if ($looptime > 10) then
		sleep 10
		@ looptime = $looptime - 10
	else
		set looptime = -1
	endif
end
