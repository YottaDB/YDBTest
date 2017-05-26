TPSET9	; ; ; go through various set patterns in tp to check chain maintenance
	; should use a blocksize of 512, recordsize of 500 and keysize of 255
	n (act)
	i '$d(act) n act s act="w ! zsh ""*"""
	k ^a
	;f i=1:1:15,30:1:51 s sub=i_$j(i,i*2+$s(i#3=0:50,1:100)),(^a(sub),a(sub))=$j(i,240)
	s cnt=0
	view "GDSCERT":1
	tstart () d
	. i $trestart trollback  s cnt=cnt+1 x act q
	. f i=51:-1:1 s sub=i_$j(i,i*2+$s(i#2:10,1:100)),(^a(sub),a(sub))=$j(i,240)
	. tcommit
	s j=""
	f i=0:1 s j=$o(^a(j)) q:j=""  i $g(^a(j))'=$g(a(j)) s cnt=cnt+1 x act
	i i'=51 s cnt=cnt+1 x act
	w $s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
