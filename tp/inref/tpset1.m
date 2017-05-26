TPSET1	; ; ; go through various set patterns in tp to check chain maintenance
	; should use a blocksize of 512, recordsize of 500 and keysize of 255
	n (act)
	i '$d(act) n act s act="w ! zsh ""*"""
	k ^a
	s cnt=0
	view "GDSCERT":1
	tstart () d
	. i $trestart trollback  s cnt=cnt+1 x act q
	. f i=5,3,7,9 s ^a(i_$j(i,60))=$j(i,400)
	. tcommit
	s j=""
	f i=3,5,7,9,10 s j=$o(^a(j)) q:j=""  i i_$j(i,60)'=j s cnt=cnt+1 x act
	w $s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
