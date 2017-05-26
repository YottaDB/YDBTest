#!/usr/local/bin/tcsh
sleep 1 # give some time for second_process script to finish
set count = 240
while ($count)
	sleep 1
	@ count = $count - 1
	if (! $count) then
		echo "TEST-E-TIMEOUT Second process did not finish on time!"
	endif
	grep "End of second_process job" second_process.log >& /dev/null
	if (! $status) then
		set count = 0
	endif
end
echo "################ SECOND PROCESS OUTPUT ###################"
echo "Check second_process.log for the following output:"
$tail -n +5 second_process.log | $grep -vE "H = |date is:" 
echo "############ END SECOND PROCESS OUTPUT ###################"
echo "The date is: "`date` >! end_second_process.txt
