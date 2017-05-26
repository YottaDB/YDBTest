per0260	;per0260 - Implement ZATtach
	;
	s c=0
	s mbx="zattstmbx" o mbx:tmpmbx 
	u mbx w $zprocess u ""
	zsy "run per0260a"
	w !,"attached per0260"
	u mbx r:10 p u "" i '$t s c=c+1 w !,"no answer from other prosess"
	c mbx
	i 'c zat p
	w !,$s(c:"BAD result",1:"OK")," from test simple zattach"
	q
