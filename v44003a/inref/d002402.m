c002455	;
	; D9D12-002402 TID in the journal extract seems to be from innermost TSTART not outermost
	;
	; we test only upto 3 nesting levels of TP.
	;
	do tp
	do tp1("")
	do tp1("a")
	do tp1("abcdefghij")
	do tp2("","")
	do tp2("","abc")
	;
	; try a numeric example also
	set num=1.5
	set num2=num*5
	do tp2(num2,"")
	;
	do tp2("efgh","IJKLM")
	do tp2("NOPQRS","tuvwxyz")
	do tp3("","a","bc")
	do tp3("def","","gh")
	do tp3("ijklm","nopq","")
	quit

tp	;
	set moduleid="tp"
	tstart ():serial
	s ^x=moduleid
	tcommit
	quit

tp1(tid);
	set moduleid="tp1"
	tstart ():(serial:transaction=tid)
	set ^x(1)=moduleid_tid
	tcommit
	quit

tp2(tid1,tid2)	;
	set moduleid="tp2"
	tstart ():(serial:transaction=tid1)
	set ^x(1)=moduleid_tid1
	do
	.	tstart ():(serial:transaction=tid2)
	.	set ^x(2)=moduleid_tid2
	.	tcommit
	tcommit
	quit

tp3(tid1,tid2,tid3);
	set moduleid="tp3"
	tstart ():(serial:transaction=tid1)
	set ^x(1)=moduleid_tid1
	do
	.	tstart ():(serial:transaction=tid2)
	.	set ^x(2)=moduleid_tid2
	.	do
	.	.	tstart ():(serial:transaction=tid3)
	.	.	set ^x(3)=moduleid_tid3
	.	.	tcommit
	.	tcommit
	tcommit
	quit

