tprlbk2 ; ; ; Test of random transaction interference
	;
	set output="tprlbk2.mjo0",error="tprlbk2.mje0"
        open output:newversion,error:newversion
        use output
        write "PID: ",$j
        close output
	;
	new (act)
	if '$data(act) new act set act="zshow"
	set ^endloop=0
	set $ztrap="set $ztrap="""" goto ERROR^tprlbk2"
	;
	set ITEM="TPROLLBACK Test",ERR=0,unix=$zv'["VMS"
	write ITEM,!
	;
	do ^job("job^tprlbk2",6,"""""")
	quit

job	;
	set iterate=10
	; the do ^job done above will set the local variable "jobindex" to 1, 2, ... depending on the job number
	set xstr="do job"_jobindex_"("_iterate_")"
	set $ztrap="goto ERROR^tprlbk2"
	write "PID: ",$J,!
	xecute xstr	; invoke the appropriate job1, job2 etc. routine
	quit

; job1 no result
job1(iterate);
	new loop
	for loop=1:1:iterate DO  q:^endloop=1
	. write "Loop:",loop,!
        . tstart ():serial
	. set ^lasti(1)=loop
	. do in1^pfill1("set",loop#10+1,loop)
        . tstart ():serial
	. do in1^pfill1("kill",loop+1#10+1,loop)
        . tstart ():serial
	. do in1^pfill1("set",loop+2#10+1,loop)
        . tstart ():serial
	. do in1^pfill1("kill",loop+3#10+1,loop)
        . trollback
	quit

; job2 No effect
job2(iterate);
	new loop
	for loop=1:1:iterate DO  q:^endloop=1
	. write "Loop:",loop,!
        . tstart ():serial
	. set ^lasti(2)=loop
	. do in1^pfill1("kill",loop#10+1,loop)
        . tstart ():serial
	. do in1^pfill1("set",loop+1#10+1,loop)
        . tstart ():serial
	. do in1^pfill1("set",loop+2#10+1,loop)
        . tstart ():serial
	. do in1^pfill1("kill",loop+3#10+1,loop)
        . trollback
	quit

; job3 sets at index iterate+loop
job3(iterate);
	new loop
	for loop=1:1:iterate DO  q:^endloop=1
	. write "Loop:",loop,!
        . tstart ():serial
	. set ^lasti(3)=loop
	. do in1^pfill1("set",loop+1#10+1,loop+iterate)
        . tstart ():serial
	. do in1^pfill1("kill",loop+1#10+1,loop+iterate)
        . trollback -1
	. tcommit
	quit

; job4 kills at index iterate+loop
job4(iterate);
	new loop
	for loop=1:1:iterate DO  q:^endloop=1
	. write "Loop:",loop,!
        . tstart ():serial
	. set ^lasti(4)=loop
	. do in1^pfill1("kill",loop+1#10+1,loop+iterate)
        . tstart ():serial
	. do in1^pfill1("set",loop+1#10+1,loop+iterate)
        . tstart ():serial
	. do in1^pfill1("set",loop+1#10+1,loop+iterate+1)
        . tstart ():serial
	. do in1^pfill1("kill",loop+1#10+1,loop+iterate+1)
        . trollback -3
	. tcommit
	quit

; job5 does TP updates
job5(iterate)	;
	new loop
	for loop=1:1:iterate DO  q:^endloop=1
	. write "Loop:",loop,!
        . tstart ():serial
	. set ^lasti(5)=loop
	. do in1^pfill1("set",loop#10+1,loop)
        . tstart ():serial
	. do in1^pfill1("kill",loop+4#10+1,loop)
	. do in1^pfill1("set",loop#10+1,loop)
        . trollback -1
	. tcommit
	quit

; job6 does TP updates
job6(iterate)	;
	new loop
	for loop=1:1:iterate DO  q:^endloop=1
	. write "Loop:",loop,!
        . tstart ():serial
	. set ^lasti(6)=loop
	. do in1^pfill1("set",loop+2#5+1,loop)
        . tstart ():serial
	. do in1^pfill1("kill",loop+1#10+1,loop)
	. do in1^pfill1("set",loop+2#5+1,loop)
        . trollback -1
	. tcommit
	quit

job7(iterate)	;
	new loop
	for loop=1:1:iterate DO  q:^endloop=1
	. write "Loop:",loop,!
        . do in1^pfill1("kill",(loop#10)+1,loop)
        . do in1^pfill1("set",(loop#10)+1,loop)
	. set ^lasti(7)=loop
	quit

ERROR   SET $ZT=""
        IF $TLEVEL trollback
        ZSHOW "*"
        ZM +$ZS
