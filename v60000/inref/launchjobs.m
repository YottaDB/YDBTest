singleproc(update)
	write "PID=",$JOB,!
	set go=0
	set $zinterrupt="set go=1"
	if 1=update if $increment(^upcount) set ^y=$random(100)
	for  quit:go=1  hang 0.1
	write $data(^y)
	quit

run(numjob,update)
	set jmaxwait=0
	set jdetach=1
	if 0=update set jmjoname="pidone"
	do ^job("singleproc^launchjobs",numjob,update)
	quit

wait(numproc)
	for i=1:1:300 quit:$get(^upcount,0)=numproc  hang 1
	if $get(^upcount)'=numproc do
	.  write "TEST-F-FAIL Processes could not launch within given timeout.",!
	.  write "Check singleproc_launchjobs.mjo  singleproc_launchjobs.mje files.",!
	quit
