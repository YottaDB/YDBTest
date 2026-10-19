;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
semcounter
	; Start 32800 processes. Stop starting processes, and report it, if the memory left falls below 4GiB, as the OOM
	; killer would otherwise kill processes at random, including those of the system and of other tests.
	new avail,first,stalled
	set avail=$$start(328,300,.first,.stalled)
	if stalled do
	.	write "TEST-E-STALLED : stopped after starting ",$order(^pids(""),-1)," processes, as only ",^jobcount," of them attached to the database within 600 seconds",!
	.	open "semcounter_stalled.txt":newversion close "semcounter_stalled.txt"
	else  if avail<(4*1024*1024) do
	.	write "TEST-E-MEMLOW : stopped after starting ",$order(^pids(""),-1)," processes, as only ",avail\1024,"MiB of memory and swap is left",!
	.	open "semcounter_memlow.txt":newversion close "semcounter_memlow.txt"
	quit

start(nbatch,interval,first,stalled)
	; Start nbatch batches of 100 processes, each checking ^stop every interval seconds, waiting for each batch to
	; attach to the database before starting the next. Log the time each batch took and the memory left after it to
	; semcounter_progress.txt. Stop if the memory left falls below 4GiB, or if a batch has not attached within 600 seconds,
	; as a process killed before it attaches (for example by the OOM killer) would otherwise leave this process waiting
	; forever and every process started so far running. Return the memory left (in kB), set first to the memory left
	; after the first batch, and set stalled to 1 if a batch did not attach, else 0.
	new i,j,index,file,start,secs,avail,shmem,slowreported
	set ^stop=0,^jobcount=0,file="semcounter_progress.txt",slowreported=0,avail=0,stalled=0
	open file:newversion
	use file write "# time, processes started, seconds for this batch, MemAvailable+SwapFree (kB), Shmem (kB)",!
	for i=1:1:nbatch do  quit:(avail<(4*1024*1024))!stalled
	.	set start=$zut
	.	for j=1:1:100 do
	.	.	set index=(i-1)*100+j
	.	.	job @("child^semcounter(index,interval):(output=""semcounter.mjo"_index_""":error=""semcounter.mje"_index_""")")
	.	.	set ^pids(index)=$zjob
	.	for  quit:^jobcount=(i*100)  set:($zut-start)>(600*1E6) stalled=1  quit:stalled  hang 0.1
	.	; Read /proc/meminfo before "use file", as $$meminfo leaves $principal as the current device
	.	set secs=($zut-start)/1E6,avail=$$meminfo("MemAvailable")+$$meminfo("SwapFree"),shmem=$$meminfo("Shmem")
	.	set:1=i first=avail
	.	use file write $zdate($horolog,"24:60:SS"),", ",i*100,", ",$fnumber(secs,"",1),", ",avail,", ",shmem,!
	.	use $principal
	.	; A batch normally starts in under 2 seconds. Report a slow start once, as at this rate the subtest takes hours.
	.	if (secs>30)&'slowreported do
	.	.	write "TEST-W-SLOWSTART : processes ",i*100-99," to ",i*100," took ",$fnumber(secs,"",1)," seconds to start. See ",file,!
	.	.	set slowreported=1
	close file
	quit avail

probe
	; Start 500 processes the way semcounter does, and estimate from the drop in MemAvailable plus SwapFree how much
	; memory semcounter needs for 32800. The drop includes the memory the kernel uses for each process, which the
	; process's own private memory and page tables leave out. Measure it from the end of the first batch of 100, as
	; that batch takes less memory per process than the rest. Write the details to memprobe.txt, and write "SKIP" if
	; that is more than 80% of the memory and swap available before the probe, or if the processes did not attach, else "RUN".
	new i,nproc,file,before,first,after,perproc,need,verdict,stalled
	set nproc=500
	set before=$$meminfo("MemAvailable")+$$meminfo("SwapFree")
	set after=$$start(nproc/100,1,.first,.stalled)
	set ^stop=1
	set perproc=(first-after)\(nproc-100),need=perproc*32800,verdict=$select(stalled:"SKIP",need>(before*0.8):"SKIP",1:"RUN")
	set file="memprobe.txt"
	open file:newversion use file
	write:stalled "Stalled : only ",^jobcount," of ",$order(^pids(""),-1)," processes attached to the database within 600 seconds",!
	write "Processes measured : ",nproc,!
	write "MemAvailable+SwapFree before the probe, after the first 100 and after all ",nproc," (kB) : ",before,", ",first,", ",after,!
	write "Drop per process after the first 100 (kB) : ",perproc,!
	write "Estimated need for 32800 processes (kB) : ",need,!
	write "80% of MemAvailable+SwapFree before (kB) : ",before*0.8\1,!
	write "Verdict : ",verdict,!
	close file
	for i=1:1:60 quit:0=$$nalive("")  hang 1
	write verdict,!
	quit

child(index,interval)
	if $increment(^jobcount)
	for  quit:^stop  hang interval
	; Record the exit, so that check^semcounter does not rely only on the pid, which can be reused after the process exits
	set ^exited(index)=1
	quit

meminfo(field)
	; Return the value (in kB) of the given field of /proc/meminfo
	new file,line,value
	set file="/proc/meminfo",value=0
	open file:readonly use file
	for  read line quit:$zeof  if $piece(line,":",1)=field set value=+$translate($piece(line,":",2)," ") quit
	close file
	quit value

stop
	; Set ^stop before anything else, so that the processes exit even if this process does not finish
	set ^stop=1
	; The processes check ^stop every 300 seconds. Any still alive at the end of the wait are reported by check^semcounter.
	for i=1:1:900 quit:0=$$nalive("")  hang 1
	quit

check
	; Verify that every process started by semcounter has exited. Write the pid of each one that has not to
	; semcounter_alive.txt, so that sem_counter.csh can stop it before it keeps the IPCs from being removed.
	new nalive,nproc,file
	set nproc=$order(^pids(""),-1),file="semcounter_alive.txt"
	set nalive=$$nalive(file)
	if 0=nalive write "# All ",nproc," processes exited : as expected",! quit
	write "TEST-E-ALIVE : ",nalive," of ",nproc," processes did not exit within 900 seconds of ^stop being set. Their pids are in ",file,!
	quit

nalive(file)
	; Return the number of processes that have not recorded their exit and whose pid is alive.
	; If file is not "", write the pid of each such process to it.
	new i,n
	set n=0
	for i=1:1:$order(^pids(""),-1) if '$data(^exited(i)),$$^isprcalv(^pids(i)) do
	.	set n=n+1
	.	quit:""=file
	.	open file:append use file write ^pids(i),! close file
	quit n

waitalive
	; Wait for the processes in semcounter_alive.txt to exit
	new file,pid,pids
	set file="semcounter_alive.txt"
	open file:readonly use file
	for  read pid quit:$zeof  set pids(pid)=pid
	close file
	do waitforalltodie^waitforproctodie(.pids,300)
	quit
