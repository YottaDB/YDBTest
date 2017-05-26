#!/usr/local/bin/tcsh -f
set ppid = `cat dse_parent.pid`
set retry=3
while ($retry > 0)
        echo "====================================" >> ps_out
	ps -fu $user >> ps_out	#BYPASSOK $ps format might change in future. Since the test expects ppid to be in 3rd column use standard ps output
	set dsepid = `$tst_awk '$3 == '$ppid' {print $2 ; exit}' ps_out`
	if ("" != `echo $dsepid | $tst_awk '/^[0-9]*$/'`) break
	sleep 1
	@ retry = $retry - 1
end
if (0 == $retry) then
	echo "DSE pid not found" >>& dse.pid
	exit 1
endif
echo $dsepid >>& dse.pid
exit 0

