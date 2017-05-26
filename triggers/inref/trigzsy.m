	;Testing zsystem from inside triggers, technically this is a no no
	;see the trigzsyxplode test for more information
trigzsy
	do ^echoline
	do basic
	do ^echoline
	do nest
	do ^echoline
	do chain
	do ^echoline
	quit

basic	write "Test zsystem from inside a trigger",!
	set x=$ztrigger("item","+^a -command=S -xecute=""w ?10,$r,$c(61),$ztva,! zsy $ztva """)
	set x=$ztrigger("item","+^b -command=S -xecute=""w ?10,$r,$c(61),$ztva,! zsy $ztva """)
	set (^a,^b)="date"
	quit

nest
	write !
	write "Testing zsystem inside nested triggers",!
	set x=$ztrigger("item","+^c -command=S -xecute=""w ?10,$r,$c(61),$ztva,! zsy $ztva s ^a=^b""")
	set ^c="date +%Y%m%d_%H%M"
	quit

chain
	write !
	write "Testing zsystem inside chained and nested triggers",!
	set x=$ztrigger("item","+^c -command=S -xecute=""w ?10,$r,$c(61),$ztva,! zsy $ztva s ^b=^a""")
	set ^c="date +%D_%H:%M"
	quit

