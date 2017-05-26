	;;; mrbackup.m
a(jobcnt,cmd)	;
	Set ^mubackup=0
	; Wait for at least one job to start
	Set jobsInitd=0
	For I=1:1 Do  Quit:jobsInitd
	. Set jobsSetup=0
	. For J=1:1:jobcnt Do  
	. . Set jobsSetup=jobsSetup+$Get(^JOBSETUP(J))
	. If jobsSetup=jobcnt Set jobsInitd=1 Quit
	. Hang 1
	;
	h 30
	zsy cmd
	Set ^mubackup=1
	q
