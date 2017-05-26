d002578	;
	; D9F11-002578 MUPIP SET -FLUSH=xxx does not work
	; 	This assumes a 4 region database AREG, BREG, CREG, DEFAULT
	;	Ensure there is one GT.M process that touches globals in BREG and DEFAULT.
	;	This way MUPIP SET -FILE can work only with AREG and CREG.
	;	MUPIP SET -REG though can work with all regions.
	;
	quit

startjob;
	set jmaxwait=0
	set ^stop=0
	do ^job("child^d002578",1,"""""")
	for i=1:1:600 quit:$data(^d)  hang 0.1
	if (600=i) write "TEST-E-TIMEOUT waiting for the job to set ^d global",!
	quit

waitjob	;
	set ^stop=1
	do wait^job
	quit

child	;
	for i=1:1  quit:^stop=1  set ^b(i)=i,^d(i)=i  hang 0.1
	quit
