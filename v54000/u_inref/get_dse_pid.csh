#!/usr/local/bin/tcsh -f
set test_number = $1
set ppid = `cat dse_parent.pid_$test_number`
set retry=3
while ($retry > 0)
	echo "====================================" >> ps_out_$test_number
	ps -fu $user >> ps_out_$test_number	##BYPASOK ps - $ps arguments might change in future. Since the test expects 3rd column to be ppid, use plain ps
	set dsepid = `$tst_awk '$3 == '$ppid' {print $2 ; exit}' ps_out_$test_number`
	if ("" != `echo $dsepid | $tst_awk '/^[0-9]*$/'`) break
	sleep 1
	@ retry = $retry - 1
end
if (0 == $retry) then
	echo "DSE pid not found" >>& dse.pid_$test_number
	exit 1
endif
echo $dsepid >>& dse.pid_$test_number
exit 0
