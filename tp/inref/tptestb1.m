tptesta	; ; ; test various tp operations
	;
	n (act) s cnt=0
	v "gdscert":1
	i '$d(act) n act s act="w ! zp @$zpos"
	s out="tptestb.log"
	o out:newversion
	s glb="^%"
	k @glb
	f  s glb=$o(@glb) q:glb=""  k @glb
	s setaprx=151,kilaprx=47,maxkey=55
	tstart ():serial
	d test(0)
	i '$trestart trestart
	d test(0)
	tcommit
	d test(0)
	tstart ():serial
	d garbage(setaprx,kilaprx),test(setaprx)
	i '$trestart trestart
	d test(setaprx)
	trollback
	d test(0)
	tstart ():serial
	d garbage(setaprx,kilaprx),test(setaprx)
	i '$trestart trestart
	d test(setaprx)
	tcommit
	d test(setaprx)
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
garbage(max,kil);
	u out
	s (count,globals,kills)=0
	s x="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	f j=1:1 s glob="^",(sub1,sub2)="" d  q:max'>count
	. f i=1:1:($R(7)+1) s glob=glob_$e(x,$r(52)+1) 
	. i '$d(@glob) s globals=globals+1
	. f i=1:1:($r(70)+1) s sub1=sub1_$e(x,$r(52)+1)
	. f i=1:1:($r(70)+1) s sub2=sub2_$e(x,$r(52)+1)
	. i $l(glob)+$l(sub1)+$l(sub2)>maxkey q
	. s count=count+'$d(@glob@(sub1,sub2)),^(sub2)=$tr($j("",$r(60)+1)," ",$e(x,$r(52)+1))
	. w "set ",glob,"(""",sub1,""",""",sub2,""")=""",^(sub2),"""",!
	. i kills<kil,'$r(3) s count=count-1,kills=kills+1 k ^(sub2) s:'$d(@glob) globals=globals-1
	. i  w "kill ",glob,"(""",sub1,""",""",sub2,""")",!
	. q
	w !
	u $p
	w !,"records created: ",count
	w !,"kills in build:  ",kills
	q
