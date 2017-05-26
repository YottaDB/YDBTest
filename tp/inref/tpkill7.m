TPKILL7	; ; ; test kill right side of global after set in transaction
	; in v3.1=6 this got a GVDATAFAIL IIII
	n (act)
	i '$d(act) n act s act="zp @$zpos"
	s cnt=0
	v "gdscert":1
	s X="1234567890"
	s X100=X_X_X_X_X_X_X_X_X_X
	s X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s X1900=X1000_X100_X100_X100_X100_X100_X100_X100_X100_X100
	f i=1:1:1 s ^A(i)="A"_i_" "_X1900
	tstart ():serial
	d test(1)
	f i=2:1:4 s ^A(i)="A"_i_" "_X1900
	d test(4)
	k ^A(4)
	k ^A(3)
	d test(2)
	i '$trestart trestart
	tcommit
	d test(2)
exit	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
test(exp)
	d order(exp)
	d zprev(exp)
	d query(exp)
	q
order(e)
	s (sub1,sub2)=""
	f dir=1,-1 s glb=$p("^zzzzzzzz||^%","|",dir+2),i=0 d
	. d:$d(@glb)  f  s glb=$o(@glb,dir) q:glb=""  d
	.. f  s sub1=$o(@glb@(sub1),dir) q:sub1=""  s i=i+1
	. i i'=e s cnt=cnt+1 x act
	q
zprev(e)
	s glb="^zzzzzzzz",(sub1,sub2)="",i=0
	d:$d(@glb)  f  s glb=$zp(@glb) q:glb=""  d
	. f  s sub1=$zp(@glb@(sub1)) q:sub1=""  s i=i+1
	i i'=e s cnt=cnt+1 x act
	q
query(e)
	s (x,glb)="^%",i=0
	d:$d(@glb)  f  s (glb,x)=$o(@glb) q:glb=""  d
	. f  s x=$q(@x) q:x=""  s i=i+1
	i i'=e s cnt=cnt+1 x act
	q
