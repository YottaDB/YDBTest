TPKILL4	; ; ; test kill of global
	;in v3.1-6 this assert failed in gvcst_kill_blk
	n (act)
	i '$d(act) n act s act="zp @$zpos"
	s cnt=0
	v "gdscert":1
	f i=1:1:20 s ^a(i)=$j(i,1090)
	f i=1:1:17 k ^a(i)
	tstart ():serial
	d test(3)
	k ^a(18)
	k ^a
	d test(0)
	i '$trestart trestart
	tcommit
	d test(0)
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
