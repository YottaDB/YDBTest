d002164a;
	set ^stop=0
	set jmaxwait=0	; signals d ^job() to job off processes and return right away
	do ^job("d002164",10,"""""")
	hang 100		; wait for jobbed off processes to do activity
	set ^stop=1	; signals all jobbed of processes running d002164.m to stop
	do wait^job	; waits for all jobbed off processes to die
	quit
