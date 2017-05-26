TPSET5	; ; ; go through various set patterns in tp to check chain maintenance
	; should use a blocksize of 512, recordsize of 500 and keysize of 255
	n (act)
	i '$d(act) n act s act="w ! zsh ""*"""
	k ^a
	s cnt=0
	view "GDSCERT":1
	tstart () d
	. i $trestart trollback  s cnt=cnt+1 x act q
	. f i=1:3:50,50:-2:1,1:1:50 s sub=$j(i,i)_$j(i,200),(^a(sub),a(sub))=$j(i,240)
	. tcommit
	s j=""
	f i=0:1 s j=$o(^a(j)) q:j=""  i $g(^a(j))'=$g(a(j)) s cnt=cnt+1 x act
	i i'=50 s cnt=cnt+1 x act
	w $s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
