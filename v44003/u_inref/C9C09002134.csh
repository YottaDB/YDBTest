#!/usr/local/bin/tcsh
# c9c09002134 - tests that 8 concurrent (mostly TP) processes can run in a healthy fashion
# the output will go to C9C09002134a_*.out, and the test system will check for any errors in them.

$gtm_tst/com/dbcreate.csh . 8
echo "Will spawn background processes..."
# Set the maximum time each of the below background jobs should be running
setenv c002134_runtime 90 # Run c002134 for 90 seconds
foreach i (1 2 3 4 5 6 7 8)
	($gtm_tst/$tst/u_inref/C9C09002134a.csh $i >& C9C09002134a_$i.out &  ) >&! bg.out
end
echo "Will now wait for them to complete..."
set count=0
# The background job calls a mumps routine continuously in a loop for $c002134_runtime seconds.
# So it is safe to sleep for $c002134_runtime seconds before starting to look for completion of the background jobs
sleep $c002134_runtime
# Wait for background jobs to finish. In case of heavily loaded situations, they could take longer so wait for max of 1 hour
@ maxwait = 3600	# max number of seconds to wait
set wait_count = 1
while (8 != $count)
	set count = `find . -name "done*" | wc -l`
	@ wait_count = $wait_count + 1
	if ($maxwait == $wait_count) then
		echo "TEST-E-TIMEOUT Background processes did not finish on time. Make sure they've completed."
		echo "Time - `date` : Expecting 8 done.x files but found only $count"
		break
	endif
	sleep 1
end
$gtm_tst/com/dbcheck.csh
echo "Individual outputs in C9C09002134*.out"
echo "Done."
