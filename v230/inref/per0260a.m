per0260a	;per0260 - Implement ZATtach
	;
	s c=0
	w !,"started per0260a"
	s mbx="zattstmbx" o mbx:tmpmbx 
	u mbx r:10 p u "" i '$t s c=c+1 w !,"no answer from other prosess"
	u mbx w $zprocess u ""
	c mbx
	i 'c zat p
	i 'c w !,"attached per0260a"
	q
