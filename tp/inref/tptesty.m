TPTESTY	; ; ; test 2 regions
	;
	n (act)
	i '$d(act) n act s act="b"
	s cnt=0
	v "gdscert":1
	f i=1:1:1 s ^b(i_$j(i,140))=$j(i,140)
	tstart ():serial
	d test(1)
	f i=1:4:1 d
	. s ^a(i_$j(i,140))=^b(i_$j(i,140))
	d test(2)
	i $trestart<2 trestart
	i $trestart<10 tcommit  s i=2
	e  trollback  s i=1
	d test(i)
exit	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
test(exp)
	d data(exp)
	d order(exp)
	d zprev(exp)
	d query(exp)
	q
data(e)
	f j=1:1:1 i ^b(j_$j(j,140))'=$j(j,140) s cnt=cnt+1 x act
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
	s glb="^%",i=0
	f  s (glb,x)=$o(@glb) q:glb=""  d
	. f  s x=$q(@x) q:x=""  s i=i+1
	i i'=e s cnt=cnt+1 x act
	q

