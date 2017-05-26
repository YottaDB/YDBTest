LARGETP	; ; ; Create a transaction which uses up many global buffers
	; in v3.1-6 this ACCVIOed
	n (act)
	i '$d(act) n act s act="w ""^A("",i,"") = "",$g(^A(i),""**UNDEF**""),!"
	n $zt s $zt="tro:$tl  s cnt=cnt+1 x act zg "_$zl_":exit"
	s cnt=0,bg=$ztrnlnm("MMTST")'="M"
	v "gdscert":1
	s X="1234567890"
	s X100=X_X_X_X_X_X_X_X_X_X
	s X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s X1900=X1000_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s nelem=90
	f i=nelem/3:1:nelem s ^A(i)="A"_i_" "_X1900
	i bg s $zt="tro:$tl  zg "_$zl_":exit"
	ts ()
	if $TRESTART>3 w "$TRESTART=",$TRESTART,! h 1
	f i=1:1:nelem/3 s ^A(i)="A"_i_" "_X1900 s Y=^A(i+(nelem/3)) s Z=^A(i+((2*nelem)/3))
	tc
	i bg s cnt=cnt+1 x act
	e  f i=1:1:nelem/3 d
	. s cmp="A"_i_" "_X1900
	. i ^A(i)'=cmp s cnt=cnt+1 x act
exit	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
