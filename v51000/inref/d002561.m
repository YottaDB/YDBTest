d002561	;
	; D9F07-002561 Use heartbeat timer to check and close open older generation journal files
	;
	quit

startjob;
        set jmaxwait=0
        set ^stop=0
	set ^signal=0
	set ^numjobs=15
	set ^varcnt=0
	set ^variable(^numjobs)=0
        do ^job("child^d002561",^numjobs,"""""")
        quit

waitjob ;
        set ^stop=1
        do wait^job
        quit

child	;
	; The last thread will wait for a signal from the parent script to open the latest generation journal file
	if jobindex=^numjobs  for i=1:1  quit:^signal=1  hang 1
	if jobindex'=^numjobs hang 1+$random(^numjobs)
	set ^variable(jobindex)=1
	tstart ():serial  set ^varcnt=^varcnt+1  tcommit
	for i=1:1  quit:^stop=1  hang 1 
	set ^final(jobindex)=1
	quit	

waitallbutone;
	for i=1:1  quit:^varcnt=(^numjobs-1)  hang 1
	quit

waitlast;
	; wait for last thread to have come to the stage where it set ^variable(jobindex)=1
	for i=1:1  quit:^variable(^numjobs)=1  hang 1
	quit

sendsignal;
	set ^signal=1
	quit
