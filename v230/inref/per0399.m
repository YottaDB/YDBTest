per0399	;per0399 - $order(^%) gives RAB-NOT-FOUND and prevents rundown
	;
	s c=0
	s sd="per0399.go" o sd:(read:rew) u sd r y
	s x="^%" f  s x=$o(@x) q:x=""  r y,y i x'=y s c=c+1 u "" w !,"Expected: . . . .",y,!,"$Order returned: ",x u sd
	r y,y i '$zeof s c=c+1 u "" w !,"Items missing from $Order"
	c sd
	w !,$s(c:"BAD result",1:"OK")," from test of $Order on multiple segments"
	q
