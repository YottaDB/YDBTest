tptestx	; ; ; test after effecs of tp rollback
	;
	n (act,play,qrseed) s cnt=0
	v "gdscert":1
	i '$d(act) n act s act="w ! zp @$zpos"
	i '$d(play) n play s play=-1
	i '$d(qrseed) n qrseed s qrseed=32512345;5974958
	s file="tptestx.log"
	i 'play o file:newversion
	e  i play>0 o file:readonly
	f iter=1:1:100 d
	. s glb="^%"
	. k @glb
	. f  s glb=$o(@glb) q:glb=""  k @glb
	. s setaprx=$$random(151),kilaprx=$$random(47),maxkey=$$random(35)+20
	. w !!,"initial tstart:"
	. tstart ():serial
	. d garbage(.setaprx,kilaprx)
	. d test(setaprx)
	. i '$trestart w !!,"restart:" trestart
	. w !!,"trollback"
	. trollback
	. ;d test(0)
	. w !!,"non-tp work follows:"
	. d garbage(.setaprx,kilaprx)
	. d test(setaprx)
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
garbage(max,kil)
	s (count,globals,kills)=0
	i play'<0 u file
	i play'>0 d
	. s x="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	. f j=1:1 s glob="^",(sub1,sub2)="" d  i max'>count w:'play ! q
	. . f i=1:1:($$random(7)+1) s glob=glob_$e(x,$$random(52)+1) 
   	. . f i=1:1:($$random(60)+1) s sub1=sub1_$e(x,$$random(52)+1)
	. . f i=1:1:($$random(60)+1) s sub2=sub2_$e(x,$$random(52)+1)
	. . i $l(glob)+$l(sub1)+$l(sub2)>maxkey q
	. . i '$d(@glob) s globals=globals+1
	. . s count=count+'$d(@glob@(sub1,sub2)),^(sub2)=$tr($j("",$$random(60)+1)," ",$e(x,$$random(52)+1))
	. . w:'play "set ",glob,"(""",sub1,""",""",sub2,""")=""",^(sub2),"""",!
	. . i kills<kil,'$$random(3) s count=count-1,kills=kills+1 k ^(sub2) s:'$d(@glob) globals=globals-1
	. . i  w:'play "kill ",glob,"(""",sub1,""",""",sub2,""")",!
	e  f  r x q:x=""  d  q:max'>count
	. s glob=$e(x)
	. i glob="s" d
	. . s glob=$p($p(x,"=")," ",2)
	. . i '$d(@glob) s count=count+1 s glob=$p(glob,"(") s:'$d(@glob) globals=globals+1
	. e  s kills=kills+1,count=count-1,glob=$p($p(x,"(")," ",2)
	. x x
	. e  s:'$d(glob) globals=globals-1
	e  s max=count
	u $p
	w !,"globals created: ",globals
	w !,"records created: ",count
	w !,"kills in build:  ",kills
	q
random(range)
	;q $r(range)
	if qrseed=-1 q $r(range)
	i range<1,$r(0)
	i '$d(qrszqrs) s qrszqrs=qrseed
	q +$p(range*$&RAND(.qrszqrs),".")
