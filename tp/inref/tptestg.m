tptestg	; ; ; test various tp operations
	;
	n (%act,%play,%qrseed) s %cnt=0
	v "gdscert":1
	i '$d(%act) n %act s %act="w ! zp @$zpos"
	i '$d(%play) n %play s %play=-1
	i '$d(%qrseed) n %qrseed s %qrseed=-1
	s %file="tptestg.log"
	i '%play o %file:newversion
	e  i %play>0 o %file:readonly
	f %iter=1:1:100 d
	. s %lvn="A"
	. k @%lvn
	. f  s %lvn=$o(@%lvn) q:%lvn=""  k @%lvn
	. s %saprx=$$random(151)+1,%kaprx=$$random(47)+1,%maxkey=$$random(35)+20
	. tstart *:serial
	. d test(0)
	. i '$trestart trestart
	. d test(0)
	. tcommit
	. d test(0)
	. tstart *:serial
	. d test(0)
	. d garbage(.%saprx,%kaprx)
	. d test(%saprx)
	. i '$trestart trestart
	. trollback
	. d test(%saprx)
	. s %lvn="A"
	. k @%lvn
	. f  s %lvn=$o(@%lvn) q:%lvn=""  k @%lvn
	. tstart *:serial
	. d test(0)
	. d garbage(.%saprx,%kaprx)
	. d test(%saprx)
	. i '$trestart trestart
	. tcommit
	. d test(%saprx)
	w !,$s(%cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
test(%exp)
	d order(%exp)
	d zprev(%exp)
	d query(%exp)
	q
order(%corr)
	s (%sub1,%sub2)=""
	f %dir=1,-1 s %lnam=$p("zzzzzzzz||A","|",%dir+2),%ci=0 d
	. d:$d(@%lnam)  f  s %lnam=$o(@%lnam,%dir) q:"A"]]%lnam!'$l(%lnam)  d
	.. f  s %sub1=$o(@%lnam@(%sub1),%dir) q:%sub1=""  d
	... f  s %sub2=$o(@%lnam@(%sub1,%sub2),%dir) q:%sub2=""  s %ci=%ci+1
	. i %ci'=%corr s %cnt=%cnt+1 x %act
	q
zprev(%corr)
	s %lnam="zzzzzzzz",(%sub1,%sub2)="",%ci=0
	d:$d(@%lnam)  f  s %lnam=$zp(@%lnam) q:"A"]]%lnam!'$l(%lnam)  d
	. f  s %sub1=$zp(@%lnam@(%sub1)) q:%sub1=""  d
	.. f  s %sub2=$zp(@%lnam@(%sub1,%sub2)) q:%sub2=""  s %ci=%ci+1
	i %ci'=%corr s %cnt=%cnt+1 x %act
	q
query(%corr)
	s (%lnam,%lvn)="A",%ci=0
	d:$d(@%lnam)  f  s (%lnam,%lvn)=$o(@%lnam) q:%lnam=""  d
	. f  s %lvn=$q(@%lvn) q:%lvn=""  s %ci=%ci+1
	i %ci'=%corr s %cnt=%cnt+1 x %act
	q
garbage(%max,%kil)
	s (%count,%locals,%kills)=0
	i %play'<0 u %file
	i %play'>0 d
	. s %str="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	. f  s (%lnam,%sub1,%sub2)="" d  i %max'>%count w:'%play ! q
	. . f %ln=1:1:($$random(7)+1) s %lnam=%lnam_$e(%str,$$random(52)+1) 
   	. . f %ln=1:1:($$random(%maxkey*.8+1)+1) s %sub1=%sub1_$e(%str,$$random(52)+1)
	. . f %ln=1:1:($$random(%maxkey-$l(%lnam)-$l(%sub1)+8)+1) s %sub2=%sub2_$e(%str,$$random(52)+1)
	. . i $l(%lnam)+$l(%sub1)+$l(%sub2)>%maxkey q
	. . i '$d(@%lnam) s %locals=%locals+1
	. . s %count=%count+'$d(@%lnam@(%sub1,%sub2)),@%lnam@(%sub1,%sub2)=$tr($j("",$$random(60)+1)," ",$e(%str,$$random(52)+1))
	. . w:'%play "set ",%lnam,"(""",%sub1,""",""",%sub2,""")=""",@%lnam@(%sub1,%sub2),"""",!
	. . i %kills<%kil,'$$random(3) s %count=%count-1,%kills=%kills+1 k @%lnam@(%sub1,%sub2) s:'$d(@%lnam) %locals=%locals-1
	. . i  w:'%play "kill ",%lnam,"(""",%sub1,""",""",%sub2,""")",!
	e  f  r %str q:%str=""  d  ;q:%max'>%count
	. s %lnam=$e(%str)
	. i %lnam="s" d
	. . s %lnam=$p($p(%str,"=")," ",2)
	. . i '$d(@%lnam) s %count=%count+1 s %lnam=$p(%lnam,"(") s:'$d(@%lnam) %locals=%locals+1
	. e  s %kills=%kills+1,%count=%count-1,%lnam=$p($p(%str,"(")," ",2)
	. x %str
	e  s:'$d(%lnam) %locals=%locals-1
	e  s %max=%count
	u $p
	w !,"locals created: ",%locals
	w !,"records created: ",%count
	w !,"kills in build:  ",%kills
	q
random(%range)
	if %qrseed=-1 q $r(%range)
	i %range<1,$r(0)
	i '$d(%qrszqrs) s %qrszqrs=%qrseed
	q +$p(%range*$&RAND(.%qrszqrs),".")
