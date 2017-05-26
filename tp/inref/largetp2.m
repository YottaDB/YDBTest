LARGETP2 ; ; ; Create a transaction which uses up many global buffers
	;
; this worked and should continue to so do
	n (act)
	i '$d(act) n act s act="w ""^A("",i,"") = "",$g(^A(i),""**UNDEF**""),!"
	s cnt=0
	v "gdscert":1
	s X="1234567890"
	s X100=X_X_X_X_X_X_X_X_X_X
	s X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s X1900=X1000_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s nelem=90
	s max=15
	s rbcount=0
	f i=1:1:nelem s ^A(i)="A"_i_" "_X1900
	f j=1:1:10 Do
	. ts ()
	. if $TRESTART>0 s rbcount=rbcount+1
	. f i=1:1:12 s Y=^A(i)
	. ts
	. f i=13:1:max s Y=^A(i)
	. tc
	. if rbcount<4 s max=max+1 trestart
	. tc
	f i=1:1:nelem/3 d
	. s cmp="A"_i_" "_X1900
	. i ^A(i)'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
