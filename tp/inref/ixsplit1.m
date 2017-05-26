IXSPLIT1 ; ; ; test for cert_blk failure
	;
; Split an index-level block
; this once failed certification and damaged the database
	n (act)
	i '$d(act) n act s act="w ""^A("",i,"") = "",^A(i),!"
	s cnt=0
	s X="1234567890"
	s X100=X_X_X_X_X_X_X_X_X_X
	s X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s X1900=X1000_X100_X100_X100_X100_X100_X100_X100_X100_X100
	f i=1:1:184 s ^A(i)="A"_i_" "_X1900
	view "GDSCERT":1
	ts ():serial
	s ^A(90.5)="A90.5 "_X1900
	i $TRESTART<1 trestart
	tc
	f i=1:1:184,90.5 d
	. s cmp="A"_i_" "_X1900 
	. i ^A(i)'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
