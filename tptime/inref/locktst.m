locktst(timeout,longwait) ;
	SET unix=$zv'["VMS"
	s ^lockstart=0	; For Synchronization
	d ^init(timeout,longwait)
	if unix   set file=^modname_".logx" open file:append use file
	w "First a job'd routine will get the lock and hold it for longwait sec",!
	; Job to lock ^thelock, so that in tp it will have to wait 
        IF unix  DO
        . SET jobs="lockit^locktst(longwait):(output=""lockit.mjo"":error=""lockit.mje"")"
        Else  DO
        . SET jobs="lockit^locktst(longwait):(STARTUP=""STARTUP.COM"":output=""lockit.mjo"":error=""lockit.mje"")"
        J @jobs
	FOR  Q:^lockstart'=0
	;
	;
	w "The child job got ^thelock. Start TP with Time out of timeout sec to get ^thelock",!
	if unix   close file
	; Signal the jobbed off process to continue with writing to the log file. 
	; Absence of this synchronisation causes NOTTOEOFONPUT error
	set ^lockstart=2
	tstart ():serial
	s tbegtp=$h
	l ^thelock:longwait
	w "Message inside TS/TC block:TP Timeout does not work at all. Did not trap to the $ztrap routine!!!",!
	tcommit
	w "Message after TS/TC block: TP Timeout does not work at all. Did not trap to the $ztrap routine!!!",!
	w "do ^finish",!  do ^finish
	q

lockit(longwait) ;
	lock ^thelock
	SET ^lockstart=1
	SET unix=$zv'["VMS"
	for  quit:^lockstart=2
	if unix  set file=^modname_".logx" open file:append use file
	s t1=$h
	w "Process PID ",$j," will halt for ",longwait," sec",!
	h longwait
	s t2=$h
	s tdif=$$^difftime(t2,t1)
	w "The time the lock was kept by the job'd routine: ",tdif,!
	if unix  close file
	q
