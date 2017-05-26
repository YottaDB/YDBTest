IXSPLIT2 ; ; ; Split an index-level block
	;
	n (act)
	i '$d(act) n act s act="w ""^A("",i,"") = "",^A(i),!"
	s cnt=0
	view "GDSCERT":1
	s X="1234567890"
	s X100=X_X_X_X_X_X_X_X_X_X
	s X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s X1900=X1000_X100_X100_X100_X100_X100_X100_X100_X100_X100
	f i=1:1:183 s ^A(i)="A"_i_" "_X1900
	ts ():serial
	s ^A(90.8)="90.8 "_X1900
	s ^A(90.5)="90.5 "_X1900
	i $TRESTART<1 trestart
	tc
	f i=1:1:183,90.5,90.8 d
	. s cmp=$s($p(i,".",2):"",1:"A")_i_" "_X1900 
	. i ^A(i)'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
