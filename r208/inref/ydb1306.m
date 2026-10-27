;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test glvn pool slots used inside an indirect frame (XECUTE, $ETRAP, $ZTRAP, ZBREAK, $ZTIMEOUT, $ZINTERRUPT)
; are freed when that frame ends [YDB#1306], and do not replace the slot of a FOR in the frame it runs in [YDB#1318]
;
; Each leak check runs the code n times and compares $ZREALSTOR after n/10 and after n runs. A leak of a glvn
; pool slot per run makes $ZREALSTOR grow by several hundred bytes per run.
;
ydb1306	;
	quit

errxord	; an error inside XECUTE while $ORDER(@ref,-1) saves its indirect reference
	do leak("errxord",100000)
	quit

errxset	; an error inside XECUTE while SET @ref=... saves its indirect reference
	do leak("errxset",100000)
	quit

forxec	; a FOR over a subscripted control variable inside XECUTE
	do leak("forxec",100000)
	quit

foretrap	; a FOR over a subscripted control variable in $ETRAP
	do leak("foretrap",100000)
	quit

forztrap	; a FOR over a subscripted control variable in $ZTRAP
	do leak("forztrap",100000)
	quit

forzbrk	; a FOR over a subscripted control variable in a ZBREAK action
	zbreak zbrk^ydb1306:"for b(1)=1:1:2 set cnt=cnt+1"
	do leak("forzbrk",100000)
	quit

forztout	; a FOR over a subscripted control variable in the $ZTIMEOUT vector
	do leak("forztout",5000)
	quit

forzint	; a FOR over a subscripted control variable in $ZINTERRUPT
	do leak("forzint",5000)
	quit

leak(how,n)
	new i,cnt,ref,b,z,x,lvl,done,w,rc,base,grow
	set cnt=0,ref="x(undefv)"
	set $zinterrupt="set done=1 for b(1)=1:1:2 set cnt=cnt+1"
	for i=1:1:n do @(how_"1") set:i=(n\10) base=$zrealstor
	set grow=$zrealstor-base
	; 9n/10 runs that each leak a slot grow $ZREALSTOR by more than 50 bytes per run
	write $select(grow<(n*5):"PASS",1:"WRONG")," : ",how," : $ZREALSTOR grew by "
	write $select(grow<(n*5):"less than "_(n*5),1:grow)," bytes from run ",n\10," to run ",n,!
	; each how except errxord and errxset runs the FOR over b(1) twice per run
	if (how'["errx")&(cnt'=(2*n)) write "WRONG : ",how," : cnt is ",cnt,", expected ",2*n,!
	quit

errxord1	new $etrap set $etrap="set $ecode="""" quit:$quit """"  quit"
	xecute "set z=$order(@ref,-1)"
	quit

errxset1	new $etrap set $etrap="set $ecode="""" quit:$quit """"  quit"
	xecute "set @ref=1"
	quit

forxec1	xecute "for b(1)=1:1:2 set cnt=cnt+1"
	quit

foretrap1	new $etrap set $etrap="set $ecode="""" for b(1)=1:1:2 set cnt=cnt+1"
	set x=1/0
	quit

forztrap1	new $ztrap set lvl=$zlevel,$ztrap="for b(1)=1:1:2 set cnt=cnt+1 zgoto:b(1)=2 lvl:ztrapret^ydb1306"
	set x=1/0
ztrapret	quit

forzbrk1	do zbrk
	quit

zbrk	quit

forztout1	set done=0,$ztimeout="0.001:set done=1 for b(1)=1:1:2 set cnt=cnt+1"
	for w=1:1 quit:done!(w>10000)  hang:w>1000 0.001
	quit

forzint1	; signal 10 is SIGUSR1, which drives $ZINTERRUPT
	set done=0,rc=$zsigproc($job,10)
	for w=1:1 quit:done!(w>10000)  hang:w>1000 0.001
	quit

nestxec	; a FOR over a(1) whose body runs a FOR over b(1) inside XECUTE
	new a,b,cnt set cnt=0
	for a(1)=1:1:3 quit:cnt>20  xecute "for b(1)=1:1:2 set cnt=cnt+1"
	do nestchk("XECUTE",cnt,a(1))
	quit

nestind	; the same with indirect control variables
	new a,b,x,y,cnt set x="a",y="b",cnt=0
	for @x=1:1:3 quit:cnt>20  xecute "for @y=1:1:2 set cnt=cnt+1"
	do nestchk("XECUTE with indirect control variables",cnt,a)
	quit

nestztout	; a FOR over a(1) interrupted by the $ZTIMEOUT vector, which runs a FOR over b(1)
	new a,b,cnt,done,w set cnt=0
	for a(1)=1:1:3 quit:cnt>20  set done=0,$ztimeout="0.001:set done=1 for b(1)=1:1:2 set cnt=cnt+1" for w=1:1 quit:done!(w>10000)  hang:w>1000 0.001
	do nestchk("$ZTIMEOUT",cnt,a(1))
	quit

nestzint	; a FOR over a(1) interrupted by $ZINTERRUPT, which runs a FOR over b(1)
	new a,b,cnt,done,w,rc set cnt=0
	set $zinterrupt="set done=1 for b(1)=1:1:2 set cnt=cnt+1"
	for a(1)=1:1:3 quit:cnt>20  set done=0,rc=$zsigproc($job,10) for w=1:1 quit:done!(w>10000)  hang:w>1000 0.001
	do nestchk("$ZINTERRUPT",cnt,a(1))
	quit

nestchk(what,cnt,last)
	; The FOR over a(1) runs 3 times and the FOR over b(1) twice each time: 6 in all, ending with a(1)=3.
	; If the inner FOR takes over the slot of the outer one, the outer one steps b(1) instead, never ends,
	; and the "quit:cnt>20" ends it.
	write $select((6=cnt)&(3=last):"PASS",1:"WRONG")," : ",what," : the inner FOR ran ",cnt," times"
	write " (expected 6) and the outer control variable ended at ",last," (expected 3)",!
	quit
