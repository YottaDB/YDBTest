;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dollarxy
	; write a file with 1000 characters to be read back in 100 char chunks with each chunk split into 2 # reads
	; totalling 100 chars.  Show $X, $Y, and $length of read after each read
	write !,"mode = ",$zchset,!
	write !,"DISK TEST",!!
	set a="dfilefixed.out"
	open a:newversion
	use a
	if "M"=$zchset set string=":23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789",recsize=100
	; if not M mode then add a multi-byte char at the end to verify $X, $Y, and $length in this case
	if "M"'=$zchset set string=":2345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678"_$CHAR(1351),recsize=101
	for i=0:1:9 write i,string
	set $X=0
	close a
	open a:(fixed:recordsize=recsize)
	; do it with nowrap
	do readwrite(a,"nowrap")

	open a:(fixed:recordsize=recsize)
	; do it with wrap
	do readwrite(a,"wrap")

	; now do the same for a fifo
	write !,"FIFO TEST",!!
	set fif="fifo1"
	open fif:(fifo:newversion:fixed:recordsize=recsize)
	zsystem "cat ./dfilefixed.out > fifo1"
	; do it with nowrap
	do readwrite(fif,"nowrap")

	open fif:(fifo:newversion:fixed:recordsize=recsize)
	zsystem "cat ./dfilefixed.out > fifo1"
	; do it with wrap
	do readwrite(fif,"wrap")

	; now do the same for a pipe
	write !,"PIPE TEST",!!
	set p="pipe1"
	open p:(command="cat ./dfilefixed.out":readonly:fixed:recordsize=recsize)::"pipe"
	; do it with nowrap
	do readwrite(p,"nowrap")

	open p:(command="cat ./dfilefixed.out":readonly:fixed:recordsize=recsize)::"pipe"
	; do it with wrap
	do readwrite(p,"wrap")

	quit

readwrite(a,wrapvar)
	; break read up into 2 pieces starting with 10 and 90 the add 5 to piece1 and subtract 5 from piece2 in
	; each of the 10 iterations
	kill p1in,p2in,piece1,piece2,xp1,xp2
	set comm="a:(width=100:"_wrapvar_")"
	use @comm
	for i=0:1:9 do
	. set piece1(i)=i*5+10
	. set piece2(i)=100-piece1(i)
	. read p1in(i)#piece1(i)
	. set xp1(i)=$X
	. set yp1(i)=$Y
	. if i<9 read p2in(i)#piece2(i)
	. ;show normal read length limited by width-$X
	. if i=9 read p2in(i)
	. set xp2(i)=$X
	. set yp2(i)=$Y
	use $p
	for i=0:1:9 do
	. write p1in(i)," $X = ",xp1(i)," $Y = ",yp1(i)," len = ",$length(p1in(i))," piece1 = ",piece1(i),!
	. write p2in(i)," $X = ",xp2(i)," $Y = ",yp2(i)," len = ",$length(p2in(i))," piece2 = ",piece2(i),!
	zshow "d":show
	write show("D",3),!!
	close a
