IXSPLIT	; ; ; Split an index-level block
	; This at one time produced an assert fail in tp_clean_up
	n (act)
	i '$d(act) n act s act="w ""^A("",i,"") = "",$g(^A(i),""**UNDEF**""),!"
	s cnt=0
	s X="1234567890"
	s X100=X_X_X_X_X_X_X_X_X_X
	s X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s X1900=X1000_X100_X100_X100_X100_X100_X100_X100_X100_X100
	ts
	if $TRESTART>0 w "$TRESTART=",$TRESTART,!
	f i=1:1:202 s ^A(i)="A"_i_" "_X1900
	view "GDSCERT":1
	f i=203:1:250 s ^A(i)="A"_i_" "_X1900
	tc
	f i=1:1:250 d
	. s cmp="A"_i_" "_X1900 
	. i ^A(i)'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
