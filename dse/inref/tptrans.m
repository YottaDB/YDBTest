tptrans ;
	; write pid to jobid.txt, so that kill_tptrans.csh can kill tptrans 
	set file="jobid.txt"
	set setflag=1
	f i=1:1:1000000 do
		. tstart ():(serial:transaction="ONLINE")
		. s ^a(i)=$j(i,100)
		. s ^b(i)=$j(i,100)
		. if ((setflag=1)&(i=100)) do ; make sure few transaction are done before creating jobid.txt
		. . open file use file write $JOB close file	
		. . set setflag=0	
		. tcommit
