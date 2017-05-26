unidata;	;
	write !,$t(+0)," test Started",!,!
	set unidata(1)="লায়েক"
	set unidata(2)="ＡＤＩＲ"
	set unidata(3)="αβγδε"
	set unidata(4)="我能吞下玻璃而不伤身体"
	;
	set fn(1)="gtmchset1"
	set chset(1)="M"
	set fn(2)="gtmchset2"
	set chset(2)="UTF-8"
	set fn(3)="gtmchset3"
	set chset(3)=chset(2)
	;
	for fcnt=1:1:3 do
	. set fname=fn(fcnt)_".m"
	. open fname:(NewVersion:ochset=chset(fcnt))
	. if fcnt=3 do
	. . set unidata(1)=unidata(1)_$char(128)
	. . set unidata(2)=unidata(2)_$char(255)
	. . set unidata(3)=unidata(3)_$char(129)
	. . set unidata(4)=unidata(4)_$char(97)
	. do createfile(fname,.unidata)
	. close fname
	;
	use $PRINCIPAL
	for fcnt=1:1:3 do
	. set fname="^"_fn(fcnt)
	. write "do ",fname,!  do @fname
	write !,$t(+0)," test Ended",!,!
	quit

createfile(fn,unidata);
	use fn
	write "unidata;       ",!
	for i=1:1:4 do
	. write "       write """,unidata(i),""",!","        ;",unidata(i),!
	write "       quit",!
	quit
