#!/usr/local/bin/tcsh -f
# usage:
# deadlock_check_wait.csh <count_of_done_files_to_wait_for>
setenv echoline 'echo ###################################################################'
# we will wait for up to 10 min for this to complete on the primary, and 5 min on the secondaries.
if (3 == $1) then
	set waitcnt = 600
else
	set waitcnt = 300
endif
set cnt = 0
hostname >>! wait.log
pwd >> wait.log
while  ($cnt < $waitcnt)
	$echoline >> wait.log
	date >> wait.log
	ls -l done_*.out >& /dev/null
	if (! $status) then
		set count_of_done_files = `ls -l done_*.out | wc -l`
	else
		set count_of_done_files = 0
	endif
	ls -l donex_*.out >& /dev/null
	if (! $status) then
		set count_of_donex_files = `ls -l donex_*.out | wc -l`
	else
		set count_of_donex_files = 0
	endif
	if ($count_of_done_files) then
		echo 'count of done_*.out files: ' $count_of_done_files >> wait.log
	endif
	if ($1 <= $count_of_done_files) then
		echo "cnt was $cnt at the end of the wait" >> wait.log
		break
	endif
	if ($count_of_done_files && (1 < $1)) then	# i.e. on the primary side, that is checking multiple scripts
		$grep -E ".-E-" done*.out >& /dev/null
		if (! $status) then	#there was some error, tell everyone to stop
			foreach isec (2 3 4)
				echo "TEST-E-ERRORDETECTED" >>! donex_$isec.out
			end
		endif
	endif
	echo "cnt = " $cnt >> wait.log
	sleep 1
	@ cnt = $cnt + 1
end
if ($waitcnt == $cnt) then
	echo "TEST-I-BACKLOG, did not sync" > BACKLOG.out
endif
