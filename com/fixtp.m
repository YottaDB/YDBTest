fixtp	; Infinite loop single process TP fill program
	; fixtp does not use gtm_test_dbfillid
	set jmaxwait=0		; Child process will continue in background. So do not wait, just return.
	set jobid=+$ZTRNLNM("gtm_test_jobid")
	; Grab the key and record size from DSE
	do get^datinfo("^%fixtp")
	; test for triggers
	set ^%fixtp("trigger")=0
	do ^job("fill^fixtp",1,"""""")
	quit
	;
fill;
	SET $ZT="SET $ZT="""" g ERROR^fixtp"
	w "Start Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
        W "PID: ",$J,!,"In hex: ",$$FUNC^%DH($j),!
	SET ^endloop=0
	SET maxrep=10000000
	SET bot=10000
	SET maxrange=1200
	SET top=bot+maxrange
	SET ^begi=bot
	SET ^lasti=0
	; Node Spanning Blocks - BEGIN
	set keysize=^%fixtp("key_size")
	set recsize=^%fixtp("record_size")
	; Node Spanning Blocks - END
	; TRIGGERS - BEGIN
	SET trigger=^%fixtp("trigger")
	; TRIGGERS -  END
	w "PID",$j,!
	F repeat=1:1:maxrep DO  q:^endloop=1
	.  W "Fill Iteration=",repeat,!
	.  F I=bot:1:top D  q:^endloop=1
	.  . TStart ():(serial:transaction="BA")
	.  . IF $TRESTART W "TREST=",$TRESTART,!
	.  . set val=$justify(I,recsize)
	.  . set key=$justify(I,keysize)
	.  . SET ^a(key)=val
	.  . if 'trigger do
	.  .  . SET ^b(key)=val
	.  .  . SET ^c(key)=val
	.  .  . SET ^d(key)=val
	.  .  . SET ^e(key)=val
	.  .  . SET ^f(key)=val
	.  . SET ^g(key)=val
	.  . SET ^h(key)=val
	.  . SET ^i(key)=val
        .  . TCommit 
	SET ^lasti=I
	w "End   Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	Q		
ERROR	SET $ZT=""
	IF $TLEVEL TROLLBACK
	ZSHOW "*"
	ZM +$ZS
	Q
