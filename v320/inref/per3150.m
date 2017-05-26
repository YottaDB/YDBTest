per3150	; ; ; boolean should not disrupt naked into external reference
	;
	n (act)
	i '$d(act) n act s act="s zp=$zpos"
      	n $zt s $zt="s cnt=cnt+1 x act zg "_$zl_":exit"
	s cnt=0
	k ^x,^|"per3150"|x
	s ^x(1)=1
	s ^|"per3150"|x(2)=2
	i ^x(1)&^|"per3150"|x(2) s ^(3)=3
	i $d(^x(3)) s cnt=cnt+1 x act
	i '$d(^|"per3150"|x(3)) s cnt=cnt+1 x act
exit	w !,$s(cnt:"BAD",1:"OK")," from ",$t(+0)
	q
