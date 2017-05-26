TPTEST4	; ; ; test after effects of tp rollback
	;
	n act s cnt=0,maxgnlen=8
	v "gdscert":1
	i '$d(act) n act s act="w !,$zpos b"
	f iter=65,90 d
	. s glb="^%"
	. k @glb
	. f  s glb=$o(@glb) q:glb=""  k @glb
	. d test(0)
	. f i=65 f j=1 f k=97:1:iter+32 d
	.. s b=$tr($j("",maxgnlen)," ",$c(i)),gbl="^"_$e(b,1,j-1)_$c(k)_$e(b,8,j)
	.. s @gbl@(i_$j(i,70),k_$j(k,70))=j_$j(j,140)
	. ;f j=64+iter:1:70+iter s glb="^abcdefg"_$c(j) f k=1,199 s @glb@(j_$j(j,70),k_$j(k,70))=$j(k,140)
	. ;d test(14)
	. tstart ():serial
	. s glb="^%"
	. k @glb
	. f  s glb=$o(@glb) q:glb=""  k @glb
	. d test(0)
	. trollback
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
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
	.. f  s sub1=$o(@glb@(sub1),dir) q:sub1=""  d
	... f  s sub2=$o(@glb@(sub1,sub2),dir) q:sub2=""  s i=i+1
	. i i'=e s cnt=cnt+1 x act
	q
zprev(e)
	s glb="^zzzzzzzz",(sub1,sub2)="",i=0
	d:$d(@glb)  f  s glb=$zp(@glb) q:glb=""  d
	. f  s sub1=$zp(@glb@(sub1)) q:sub1=""  d
	.. f  s sub2=$zp(@glb@(sub1,sub2)) q:sub2=""  s i=i+1
	i i'=e s cnt=cnt+1 x act
	q
query(e)
	s (x,glb)="^%",i=0
	d:$d(@glb)  f  s (glb,x)=$o(@glb) q:glb=""  d
	. f  s x=$q(@x) q:x=""  s i=i+1
	i i'=e s cnt=cnt+1 x act
	q
