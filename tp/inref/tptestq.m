TPTESTQ	; ; ; middle index split with chain to the left and right
	;
	n (act)
	i '$d(act) n act s act="zp @$zpos"
	s cnt=0
	v "gdscert":1
	f i=9:-1:3 s ^a(i_$j(i,150))=$j(i,240)
	d test(7)
	;f i=8,9  s ^a(i_$j(i,150))=$j(i,240)
	;d test(9)
	;f i=8,9 k ^a(i_$j(i,150))
	;d test(7)
	tstart ():serial
	f i=2,1 s ^a(i_$j(i,150))=$j(i,240)
	tcommit
	d test(9)
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
	s glb="^%",i=0
	f  s (glb,x)=$o(@glb) q:glb=""  d
	. f  s x=$q(@x) q:x=""  s i=i+1
	i i'=e s cnt=cnt+1 x act
	q
