updates	;
	; we are checking for elapsed time after every update instead of jobbing off this process because it has to strace'ed
	; and if the check is done after a bunch of updates say 1000 updates, sometimes due to load the 1000 updates might take longer than 2-3 seconds
	; which would make a 5 sec update run for longer time and would not give correct # of fsync counts
	set h1=$horolog
	set dif=0
	set maxdif=$ztrnlnm("gtm_time")
	for i=1:1  do  quit:dif>maxdif
	.	set h2=$horolog
	.	set dif=$$^difftime(h2,h1)
	.	if dif>maxdif  quit
	.	set j=i#1000000
	.	set ^x(j)=$justify($job,200)
	quit
