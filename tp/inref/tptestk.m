TPTESTK	; ; ; test a transaction updating more than half the buffers
	;
	n (act)
	i '$d(act) n act s act="zp @$zpos"
	n $zt s $zt="tro:$tl  s cnt=cnt+1 x act zg "_$zl_":exit"
	s cnt=0,bg=$ztrnlnm("MMTST")'="M"
	v "gdscert":1
	tstart ():serial
	f i=1:1:27 s ^a(i)=$j(i,990)
	tcommit
	i bg s $zt="tro:$tl  zg "_$zl_":exit"
	tstart ():serial
	f i=i:1:i+28 s ^a(i)=$j(i,990)
	tcommit
	i bg s cnt=cnt+1 x act
exit	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
