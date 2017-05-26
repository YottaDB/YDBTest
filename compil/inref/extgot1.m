extgot1	; test to see that external goto doesn't disrupt NEWed variables
	; including $ZT
	s a=1,%zl=$zl
	d l1
	i a'=1 s cnt=cnt+1
	i $zt'="B" s cnt=cnt+1
exit	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
l1	n a,$zt s a=2,$zt="g err"
	g ext^extgot1
	;
ext	s cnt=0
	i a'=2 s cnt=cnt+1
	i $zt'="g err" s cnt=cnt+1
	q
err	s cnt=cnt+1
	zg %zl:exit
