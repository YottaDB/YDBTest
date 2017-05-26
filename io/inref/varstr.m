varstr	; VARIABLE vs STREAM records
	write !,";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;",!
	set sd="foovar1.txt"
	write "VARIABLE, $X",!
	do open^io(sd,"NEWVERSION:RECORDSIZE=20:VARIABLE")
	do wrt(1)
	close sd
	write !,";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;",!
	write "STREAM, $X",!
	set sd="foostream1.txt"
	do open^io(sd,"NEWVERSION:RECORDSIZE=20:STREAM")
	do wrt(1)
	close sd
	write !,";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;",!
	set sd="foovar2.txt"
	write "VARIABLE, $X, no !",!
	do open^io(sd,"NEWVERSION:RECORDSIZE=20:VARIABLE")
	do wrt(2)
	close sd
	write !,";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;",!
	write "STREAM, $X, no !",!
	set sd="foostream2.txt"
	do open^io(sd,"NEWVERSION:RECORDSIZE=20:STREAM")
	do wrt(2)
	close sd
	write !,";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;",!
	write "STREAM, abc, no !",!
	set sd="foostream3.txt"
	do open^io(sd,"NEWVERSION:RECORDSIZE=20:STREAM")
	do wrt(3)
	close sd
	write !,";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;",!
	write "STREAM, abc, seperate write",!
	set sd="foostream4.txt"
	do open^io(sd,"NEWVERSION:RECORDSIZE=20:STREAM")
	do wrt(4)
	close sd
	quit
wrt(no)	;
	do use^io(sd,"WIDTH=20:NOWRAP")
	if 1=no for i=1:1:10 write " the quick brown fox jumped over the lazy dog ",$x,!
	if 2=no for i=1:1:10 write " the quick brown fox jumped over the lazy dog ",$x
	if 3=no for i=1:1:10 write " the quick brown fox jumped over the lazy dog ","abc"
	if 4=no for i=1:1:10 write " the quick brown fox jumped over the lazy dog " write "abc"
	use sd:(REWIND:WIDTH=100)
	for i=1:1 use sd read x quit:$zeof  use $P write !,i,?5,x
	close sd
	quit

