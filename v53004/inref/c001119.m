c001119	;
	; --------------------------------------------------------------------------------------------------
	; Test that GT.M properly handles the situation where a TP transaction references a global variable
	; for the first time with a nonzero out-of-date clue when it is already in its final retry.
	; --------------------------------------------------------------------------------------------------
	;
	set jmaxwait=0
	set ^stop=0
	set ^numjobs=9
	set ^subs=0
	do ^job("child^c001119",^numjobs,"""""")
	hang 15+$r(60)	; Run the test randomly from 15 seconds to 75 seconds
	set ^stop=1
	do wait^job
	quit
child	;
	set numupd=100	; number of continuous updates per global 
	set numjobs=^numjobs
	set subs=^subs
	set xstrset="set ^dummy"_jobindex_"=$j(subs,200)"
	set xstrget="set dummy"_jobindex_"=$get(^dummy"_jobindex_")"
	xecute xstrset	; this will make sure we have a nonzero clue for ^dummyX at start
	;
	; The purpose of the first 8 jobs (1 to 8) is to do real updates on ^real and
	; occasionally reference ^dummyX (job1 references ^dummy1, job2 references ^dummy2 etc.).
	; It is ^dummyX which is referenced in the TP transaction ONLY if we are in the final retry
	; and it is that whose clue is expected to be out of date because we ensure at least "numupd"
	; updates happen (from this process; note there are other jobs doing updates concurrently)
	; between two successive references of this global. 
	;
	; The purpose of the 9th job is to ensure that ^dummyX is not cleaned out from the global buffer cache.
	; even though lots of other updates happen concurrently. This will ensure the clue that jobs 1 to 8 have
	; for ^dummyX will not trigger a cdb_sc_lostcr situation but will trigger a cdb_sc_losthist situation.
	;
	if jobindex'=9  do
	.	set cnt=0
	.	for  quit:^stop=1  do
	.	.	set subs=$incr(^subs)
	.	.	for j=1:1:numupd quit:^stop=1  do
	.	.	.	for k=1:1:10  set ^real(subs,k)=$j(k,20)
	.	.	tstart ():(serial:transaction="BA")	; in case used with journaling, we dont want to slow down TP
	.	.	for k=1:1:10  do
	.	.	.	set ^real(subs,k)=$j(k,20)
	.	.	if ($trestart>2) xecute xstrget set cnt=cnt+1  write cnt,": Reached INTERESTING point ",!
	.	.	tcommit
	if jobindex=numjobs  do
	.	for i=1:1:numjobs-1 set xstrget(i)="set dummy"_i_"=$get(^dummy"_i_")"
	.	for  quit:^stop=1  for i=1:1:numjobs-1  xecute xstrget(i)
	quit
