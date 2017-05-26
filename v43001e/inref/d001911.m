d001911	;
	; create the database using
	;	dbcreate mumps 0 500 512 -1 64
	; tmp.com is as follows
	; 	change -segment DEFAULT -file=mumps.dat
	; 	change -segment DEFAULT -block_size=512
	; 	change -segment DEFAULT -global_buffer_count=64
	; 	change -region DEFAULT -record_size=500
	;
	view "NOISOLATION":"+^a,^b,^c"
	set ^stop=0
	;
	; num needs to be at least twice number of global buffers (this is to test C9D12-002468)
	;
	set num=200
	; 
	set intp=0
	do set("a")
	do set("b")
	for  quit:^stop=1  do
	.	do kill("a")
	.	do set("c")
	.	do kill("b")
	.	do set("a")
	.	do kill("c")
	.	do set("b")
	quit
start	;
	set jmaxwait=0
	do ^job("d001911",numjobs,"""""")
	quit
stop	;
	set ^stop=1	; signal GT.M processes to stop
	do wait^job	; wait for all jobs (spawned in start^d001911 above) to die
	quit
set(ch)	;
	for i=1:1:num   do 
	.	if $random(2)=0  set intp=1  tstart ():serial
	.	set xstr="set ^"_ch_"($j,i)=$j(i,400)"
	.	xecute xstr
	.	if intp=1  tcommit  set intp=0
	quit
kill(ch);
	if $random(2)=0  set intp=1  tstart ():serial
	set xstr="kill ^"_ch_"($j)"
	xecute xstr
	if intp=1  tcommit  set intp=0
	quit
