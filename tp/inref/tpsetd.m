TPSETd	; ; ; go through various set patterns in tp to check chain maintenance
	; should use a blocksize of 2048, recordsize of 2040 and keysize of 255
	n (act)
	i '$d(act) n act s act="w ! zsh ""*"""
	k ^a
	s cnt=0
	view "GDSCERT":1
	f i=1:2:200 f j=1:1:20 s ^a(i,j)=$j(i,200+j)
	f i=200:-1:1 i '$d(^a(i)) d
	. tstart ()
	. i $trestart trollback  s cnt=cnt+1 x act q
	. i '$d(^a(i)) f j=1:1:20 s ^a(i,j)=$j(i,200+j)
	. tc
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
