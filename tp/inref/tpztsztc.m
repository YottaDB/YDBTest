tpztsztc	;this m routine tests the ztstart and ztcommit functionality.
	;
	;
	W "Main task started",!
	;
	do ^job("thread^tpztsztc",4,"""""")
	;
        W "Main task ended",!
	quit

thread	;
	if jobindex=1 do tran1(1)
	if jobindex=2 do tran1(2)
	if jobindex=3 do tran2(1)
	if jobindex=4 do tran2(2)
	quit

tran1(no)	
	W $ZDate($H,"24:60:SS")," job ",no," started",!
	for k=1:1:1000 do
	. ztstart
        . for j=1:1:2 do
	. . set ^x(no,j,k,1)=j
	. if $view("JNLTRANSACTION")'=1  w "TEST FAILED",!
	. ztcommit
	. if $view("JNLTRANSACTION")'=0  w "TEST FAILED",!
	W $ZDate($H,"24:60:SS")," job ",no," ended",!
	quit

tran2(no)
	W $ZDate($H,"24:60:SS")," Test ",no," started",!
	set $ZT="g ERROR"
	for k=1:1:10 do
	. ztstart
	. ztstart
	. ztstart
        . for j=1:1:50 do
	. .  set ^x(no,j,k,2)=j
	. if $view("JNLTRANSACTION") ztcommit 0
	. else  w "TEST FAILED in nested ztc",!
	. if $view("JNLTRANSACTION")'=0  w "TEST FAILED",! 
	W $ZDate($H,"24:60:SS")," Test ",no," ended",!
	quit

ERROR   SET $ZT=""
        IF $TLEVEL TROLLBACK
        ZSHOW "*"
        ZM +$ZS

