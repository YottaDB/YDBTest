per0369	;per0369 - open of an undefined variable doesn't give undef
	;
	k
	s c=0
	s zt=$zt,$zt="s next=$zpos,$p(next,""+"",2)=$p(next,""+"",2)+1 w !,$zs g @next"
	o x s c=c+1 w !,"open failed to detect undefined variable"
	u x s c=c+1 w !,"use failed to detect undefined variable"
	c x s c=c+1 w !,"close failed to detect undefined variable"
	s $zt=zt
	w !,$s(c:"BAD result",1:"OK")," from test of open/use/close detecting UNDEF"
	q
