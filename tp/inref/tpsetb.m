TPSETb	; ; ; go through various set patterns in tp to check chain maintenance
	; should use a blocksize of 512, recordsize of 500 and keysize of 255
	n (act)
	i '$d(act) n act s act="w ! zsh ""*"""
	k ^a
	f i=1:1:35 s sub=i_$j(i,i*2+20),(^a(sub),a(sub))=$j(i,200)
	s cnt=0
	view "GDSCERT":1
	tstart () d
	. i $trestart trollback  s cnt=cnt+1 x act q
	. f i=1:7:110 s sub=i_$j(i,i*2+20),(^a(sub),a(sub))=$j(i,240)
	. tcommit
	s j=""
	f i=0:1 s j=$o(^a(j)) q:j=""  i $g(^a(j))'=$g(a(j)) s cnt=cnt+1 x act
	i i'=46 s cnt=cnt+1 x act
	w $s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
