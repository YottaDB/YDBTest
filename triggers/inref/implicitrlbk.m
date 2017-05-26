	; test the implicit rollback of an implicit transaction on halt
	; meaning if code in a trigger HALTs, then all the updates will
	; not be applied to the DB.
implicitrlbk
	do ^echoline
	write "Test ",$increment(^test),!
	do validate
	set ^a(99)="99 red ballons"
	do validate
	do ^echoline
	quit

setup
	do text^dollarztrigger("tfile^implicitrlbk","implicitrlbk.trg")
	do file^dollarztrigger("implicitrlbk.trg",1)
	quit

validate
	do ^echoline
	write "Validate data ",^test,!
	if $data(^a) write $char(9) zwrite ^a
	if $data(^b) write $char(9) zwrite ^b
	if $data(^c) write $char(9) zwrite ^c
	do ^echoline
	quit

test
	zshow "s":stack
	write $char(9),stack("S",2)
	write $char(9),"$reference=",$reference
	write !
	quit

halt
	write "Updates before implicit ROLLBACK",!
	do validate
	halt

tfile
	;+^a(lvn=:) -command=S -xecute="do test^implicitrlbk set (^b(lvn*10),^c(lvn))=$ztvalue do test^implicitrlbk"
	;+^b(lvn=:) -command=S -xecute="do test^implicitrlbk" -name=b4
	;+^c(:)     -command=S -xecute="do test^implicitrlbk do:^test<2 halt^implicitrlbk" -name=halter
