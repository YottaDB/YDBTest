	; this is a special one-off test case where a ztrigger'ed trigger
	; peeked down the stack to see what called it.  On the primary side
	; this was OK, +4^trigreplstack, but on the secondary side it showed
	; running^UTIL.BASE.FRAME which causes the test to fail during an
	; extract comparison.
trigreplstack
	do ^echoline
	do text^dollarztrigger("tfile^trigreplstack","trigreplstack.trg")
	do file^dollarztrigger("trigreplstack.trg",1)
	ztrigger ^stackbuster
	do ^echoline
	quit

tfile
	;+^stackbuster -commands=ZTR -xecute=<<
	;	zshow "s":stack
	;	write "My name is ",$ZTNAme,!
	;	write stack("S",1),!
	;	set x=$increment(^fired(stack("S",1)))
	;
	;	write "Who called me?",!
	;	write stack("S",2),!
	;	set x=$increment(^fired(stack("S",2)))
	;	quit
	;>>
