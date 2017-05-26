TPKILL1	; ; ; kill in the middle
	; this worked and should continue to do so
	n (act)
	i '$d(act) n act s act="w $zpos,!"
	s cnt=0
	v "gdscert":1
	s X="1234567890"
	s X100=X_X_X_X_X_X_X_X_X_X
	s X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s X1900=X1000_X100_X100_X100_X100_X100_X100_X100_X100_X100
	f i=1:1:10 s ^A(i)="A"_i_" "_X1900
	tstart ():serial
	d test(10)
	k ^A(5)
	k ^A(6)
	i '$trestart trestart
	d test(8)
	tcommit
	d test(8)
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
test(exp)
	d order(exp)
	d zprev(exp)
	d query(exp)
	q
order(e)
	s (sub1,sub2)=""
	f dir=1,-1 s glb4567890123456789012345678901=$p("^zzzzzzzz||^%","|",dir+2),i=0 d
	. set glb4567890="^unknownGlobal"
	. d:$d(@glb4567890123456789012345678901)  f  s glb4567890123456789012345678901=$o(@glb4567890123456789012345678901,dir) q:glb4567890123456789012345678901=""  d
	.. f  s sub1=$o(@glb4567890123456789012345678901@(sub1),dir) q:sub1=""  s i=i+1
	. i i'=e s cnt=cnt+1 x act
	q
zprev(e)
	s glb4567890123456789012345678901="^zzzzzzzz",(sub1,sub2)="",i=0
	set glb4567890="^unknownGlobal"
	d:$d(@glb4567890123456789012345678901)  f  s glb4567890123456789012345678901=$zp(@glb4567890123456789012345678901) q:glb4567890123456789012345678901=""  d
	. f  s sub1=$zp(@glb4567890123456789012345678901@(sub1)) q:sub1=""  s i=i+1
	i i'=e s cnt=cnt+1 x act
	q
query(e)
	s (x,glb4567890123456789012345678901)="^%",i=0
	d:$d(@glb4567890123456789012345678901)  f  s (glb4567890123456789012345678901,x)=$o(@glb4567890123456789012345678901) q:glb4567890123456789012345678901=""  d
	. f  s x=$q(@x) q:x=""  s i=i+1
	i i'=e s cnt=cnt+1 x act
	q
