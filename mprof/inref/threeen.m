; This script tests various functionality of MPROF, including implicit tracing 
; with and without saving to db, absolute time fields (UNIX only), and cumulative
; process's and subprocesses' (UNIX only) CPU information, and so on. It is used
; by D9L03002804 and D9L06002815 subtests.
threeen(fin,opt,gbl)
	; Find the maximum cycle length for the 3n+1 problem for all integers through two input integers.
	; See http://online-judge.uva.es/p/v1/100.html for more detail.
	;
	; Options:
	;  1 - Runs with tracing; the total CPU time is saved in the calling script to the specified file
	;  2 - Runs with tracing; the total absolute time is saved in the calling script to the specified file
	;  3 - Runs without tracing
	;  4 - Runs with tracing
	;  5 - Runs without tracing and either zwrites the specified global into the specified file (UNIX) or 
	;      checks the total CPU time with that recorded by OS (VMS)
	;  6 - Runs with tracing and either zwrites the specified global into the specified file (UNIX) or
	;      checks the total CPU time with that recorded by OS (VMS)
	;  7 - Runs with tracing and saves the storage allocation difference in the specified file
	;  8 - Runs without tracing but attempts to save the data into some global
	;
	set unix=$zv'["VMS"
	new start,finish,file,option,iterations,global,hor1,hor2
	read input
	if unix do
	.	set start=$piece(input," ",1)		; lower bound
        .	set finish=$piece(input," ",2)		; upper bound
        .	set file=$piece(input," ",3)		; file where to save the results
	.	set option=$piece(input," ",4)		; operation mode (explained above)
	.	set iterations=$piece(input," ",5)	; number of iterations
	.	set global=$piece(input," ",6)		; name of global where tracing is stored
	else  do
	.	set start=1
	.	set finish=fin
	.	set option=opt
	.	set global=gbl
	kill ^trc
	if (option=2) do
	.	set ^ready=0
	.	lock ^a
	.	job lockjob^threeen($job)
	.	for  quit:^ready  hang 1
	if (option=1)!(option=2)!(option=4)  do
	.	view "TRACE":1:"^trc"
	.	set hor1=$horolog
	.	kill cycle set max=$$docycle(start,finish,"cycle")
	.	kill ^cycle set max=$$docycle(start,finish,"^cycle")
	.	set hor2=$horolog
	.	set ^hor=hor1_" - "_hor2
	.	view "TRACE":0:"^trc"
	else  if (option=3)!(option=5)  do
	.	kill cycle set max=$$docycle(start,finish,"cycle")
	.	kill ^cycle set max=$$docycle(start,finish,"^cycle")
	else  if (option=6)  do
	.	view "TRACE":1:""_global
	.	kill cycle set max=$$docycle(start,finish,"cycle")
	.	kill ^cycle set max=$$docycle(start,finish,"^cycle")
	else  if (option=8)  do
	.	kill cycle set max=$$docycle(start,finish,"cycle")
	.	kill ^cycle set max=$$docycle(start,finish,"^cycle")
	.	view "TRACE":0:""_global
	else  if (option=7) do
	.	set storage1=$zrealstor
	.	set storage2=storage1
	.	; "priming the pump"
	.	for k=1:1:5  do
	.	.	view "TRACE":1:"^trc"
	.	.	kill cycle set max=$$docycle(start,finish,"cycle")
	.	.	kill ^cycle set max=$$docycle(start,finish,"^cycle")
	.	.	view "TRACE":0:"^trc"
	.	.	kill ^trc
	.	; actual testing
	.	set storage1=$zrealstor
	.	for k=1:1:iterations  do
	.	.	view "TRACE":1:"^trc"
	.	.	kill cycle set max=$$docycle(start,finish,"cycle")
	.	.	kill ^cycle set max=$$docycle(start,finish,"^cycle")
	.	.	view "TRACE":0:"^trc"
	.	.	kill ^trc
	.	set storage2=$zrealstor
	; print approximate total MPROF time or storage difference,
	; depending on the option specified
	if option=8  do
        .	set value=@(global_"(""threeen"",""docycle"")")
	.	if value'="" write "saved to "_global,!
	.	else  write "saving to "_global_" failed!",!
	else  if (option=5)!(option=6)  do
	.	view "TRACE":0:""_global
	.	if unix do
	.	.	open file:writeonly  
	.	.	use file
	.	.	zwrite @global
	.	.	close file
	.	else  do
	.	.	set oscpu=$zgetjpi("","cputim")
	.	.	set mprofcpu=$piece(@global@("*RUN"),":",1)
	.	.	set disc=(oscpu-mprofcpu)/mprofcpu
	.	.	if disc<0.3  do
	.	.	.	write "discrepancy is tolerable",!
	.	.	else  do
	.	.	.	write "discrepancy ",disc," exceeds threshold of 0.3",!
	else  if option=7  do
	.	open file:writeonly  
	.	use file
	.	write (storage2-storage1)
	.	close file
	quit
	;
docycle(first,last,var)
	new i,currpath,current,maxcycle,n
	set maxcycle=1
	for current=first:1:last do cyclehelper
	quit maxcycle
	;
cyclehelper
	set n=current
	kill currpath
	for i=0:1 quit:$data(@var@(n))!(1=n)  do
	.	set currpath(i)=n
	.	do iterate
	if 0<i do	; if 0=i we already have an answer for n
	.	if 1=n set i=i+1
	.	else  set i=i+@var@(n)
	.	do updatemax
	.	set n="" for  set n=$order(currpath(n)) quit:""=n  set @var@(currpath(n))=i-n
	quit
	;
iterate
	if 0=(n#2) set n=n/2
	else  set n=3*n+1
	quit
	;
updatemax
	set:i>maxcycle maxcycle=i
	quit
	;
lockjob(pid)
	set pidfile="pids.outx"
	open pidfile:writeonly
	use pidfile
	write $job,!,"PID is printed"
	close pidfile
	; the parent process will wait until ^ready is set before proceeding
	set ^ready=1
	; try to obtain the lock held by the parent process until it releases it
	lock ^a
	; keep checking whether the parent process has terminated before quitting;
	; this is analogous to doing kill -0
	for  quit:$zsigproc(pid,0)  hang 5
	quit
