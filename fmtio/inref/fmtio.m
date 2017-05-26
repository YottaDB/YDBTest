	; aaa.m
try(act,ctlchar)
	n i,j,ref	
	s j=1
	i ctlchar="a"  f i=0:1:255  d 
	. i act="set0"   s ^a(i,j)=0
	. i act="setd"   s ^a(i,j)=$ZChar(i)_$ZChar(j)
	. i act="check"  i ^a(i,j)'=($ZChar(i)_$ZChar(j))  w "Wrong at ",i," ",j,!  q
	s ref="hello"
	i ctlchar="b"  f i=0:1:255  d
	. i act="set0"   s ^b(i)=0
	. i act="setd"   s ^b(i)="hello"
	. i act="check"  i ^b(i)'=ref  w "Wrong at ",i,!  q
	w "FINISHED",!
	q
aaa	;
	w "d ^fmtio(""setd"",""a"")",!   d ^fmtio("setd","a")
	w "d ^fmtio(""setd"",""b"")",!    d ^fmtio("setd","b")
	w "d ^fmtio(""check"",""a"")",!  d ^fmtio("check","a")
	w "d ^fmtio(""check"",""b"")",!   d ^fmtio("check","b")
	quit
ddd	;
	w "d ^fmtio(""set0"",""a"")",!   d ^fmtio("set0","a")
	quit
eee	;
	w "d ^fmtio(""check"",""a"")",!	 d ^fmtio("check","a")
	w "d ^fmtio(""set0"",""a"")",!   d ^fmtio("set0","a")
	quit
fff	;
	w "d ^fmtio(""check"",""a"")",!	 d ^fmtio("check","a")
	w "d ^fmtio(""set0"",""b"")",!   d ^fmtio("set0","b")
	quit
ggg	;
	w "d ^fmtio(""check"",""b"")",!	 d ^fmtio("check","b")
	w "d ^fmtio(""set0"",""b"")",!   d ^fmtio("set0","b")
	quit
hhh	;
	w "d ^fmtio(""check"",""b"")",!	 d ^fmtio("check","b")
	w "d ^fmtio(""set0"",""b"")",!   d ^fmtio("set0","b")
	quit
iii	;
	w "d ^fmtio(""check"",""b"")",!	 d ^fmtio("check","b")
	w "d ^fmtio(""set0"",""b"")",!   d ^fmtio("set0","b")
	quit
jjj	;
	w "d ^fmtio(""check"",""b"")",!	 d ^fmtio("check","b")
	quit
