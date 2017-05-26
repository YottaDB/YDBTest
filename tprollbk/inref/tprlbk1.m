tprlbk1	; ; ; Test of random transaction interference
	;
	set output="tprlbk1.mjo0",error="tprlbk1.mje0"
        open output:newversion,error:newversion
        use output
        write "PID: ",$j
        close output
	;
	new (act)
	if '$data(act) new act set act="zshow"
	set ^endloop=0
	set $ztrap="set $ztrap="""" goto ERROR^tprlbk1"
	;
	set ITEM="TPROLLBACK Test",ERR=0,unix=$zv'["VMS"
	write ITEM,!
	;
	do ^job("job^tprlbk1",1,"""""")
	quit

job	;
	set iterate=10
	; the do ^job done above will set the local variable "jobindex" to 1, 2, ... depending on the job number
	set xstr="do job"_jobindex_"("_iterate_")"
	set $ztrap="goto ERROR^tprlbk1"
	write "PID: ",$J,!
	xecute xstr	; invoke the appropriate job1, job2 etc. routine
	quit

; job1 sets at index loop+iterate
job1(iterate);
	new loop
	for loop=1:1:iterate do  quit:^endloop=1
	. write "Loop:",loop,!
        . tstart ():serial
	. set ^lasti(4)=loop
	. do in1^pfill1("set",loop+1#10+1,loop+iterate)
        . tstart ():serial
	. do in1^pfill1("set",loop+1#10+1,loop+iterate)
        . tstart ():serial
	. do in1^pfill1("set",loop+1#10+1,loop+iterate+1)
        . tstart ():serial
	. do in1^pfill1("kill",loop+1#10+1,loop+iterate+1)
        . trollback -3
	. tcommit
	for loop=1:1:iterate do  quit:^endloop=1
	. write "verifying...",!
	. do in1^pfill1("ver",loop+1#10+1,loop+iterate)
	for iter=1:1:100 do
	. if $data(^a(iter,loop+iterate+1))'=0 write "unexpected data present",!
	quit
; grep for FAIL in *.mjo*

ERROR   set $zt=""
        if $tlevel trollback
        zshow "*"
        zmessage +$zstatus
