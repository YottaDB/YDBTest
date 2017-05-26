per3050	; ; ; look for tp problem with local arrays
	;
	n (act)
	i '$d(act) n act s act="s zp=$zpos"
	s cnt=0
	f c=29,30 d
	. s %a=1
	. f i=1:1:c s %a(i)=$c(i+96),%b(i)=i,%c(i)=$c(i+96)
	. f op="set","kill" f i=1:1:c+1 d test(op,i)
	k %a
	s c=3,%a=1
	s %a(1)="a",%a(234567890.123)="b",%a("C")="c",%a("C",1455)="d"
	s %b(1)=1,%b(2)=234567890.123,%b(3)="C"
 	s %c(1)="a",%c(2)="b",%c(2)="c"
	f op="set","kill" f i=1,234567890.123,"C","bar" d test(op,i)
	w $s(cnt:"BAD",1:"OK")," from ",$t(+0)
	q
test(opr,sub)
	tstart (%a) 
	d check
	i $trestart=2 trollback
	e  d
	. i opr="set" s %a(sub)=sub
	. i opr="kill" k %a(sub)
	. ;d show
	. trestart
	d check
	q   
check	i %a'=1 s cnt=cnt+1 x act
	s x=""
	f j=1:1 s x=$o(%a(x)) q:'$l(x)  i x'=%b(j),%a(x)'=%c(j) s cnt=cnt+1 x act q
	i j-1'=c s cnt=cnt+1 x act
	q
show	w !,$trestart,!
	zwr %a
	q
