locktst4	;test an assortment of locks
	;
	set $zt="g error"
	l  zd  s cnt=0
	f i=65:1:90 s n="^"_$c(i) l @n d
	. zsh "l":l s l=$o(l("L",0)) i l="" d error q
	. i $p(l("L",l)," ")'="LOCK" d error
	. i $p(l("L",l)," ",2)'=n d error
	. i $l($o(l("L",l))) d error
	l  k l zsh "l":l i $l($o(l("L",0))) d error
	f i=65:1:90 s n="+^"_$c(i) d
	. f lev=1:1:3 l @n d inctst
	. s n="-^"_$c(i)
	. f lev=2,1 l @n d inctst
	l  k l zsh "l":l i $l($o(l("L",0))) d error
	f i=65:1:90 s n="^"_$c(i) za @n d
	. zsh "l":l s l=""
	. f j=65:1 s l=$zp(l("L",l)) q:+l=0  s t=j i $p(l("L",l)," ",2)'=("^"_$c(j)) d error
	. i i'=t d error
	. i $p(l("L",1)," ")'="ZAL" d error
	f i=65:1:90 s n="^"_$c(i) zd @n d
	. k l zsh "l":l s l=0,t=0
	. f j=90:-1 s l=$o(l("L",l)) q:l=""  s t=j i $p(l("L",l)," ",2)'=("^"_$c(j)) d error
	. i t,$p(l("L",91-t)," ",2)[n d error
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
inctst	zsh "l":l s l=""
	f j=65:1 s l=$zp(l("L",l)) q:+l=0  s t=j i $p(l("L",l)," ",2)'=("^"_$c(j)) d error
	i i'=t d error
	i $p(l("L",1),"=",2)'=lev d error b
	q
error	;
	write "locktst4 FAILED",!
	zshow "*"
	halt
