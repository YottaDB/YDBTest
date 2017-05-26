per0394	;per0394 - ZATtach doesn't detect an undefined argument
	;
	s c=0
	s zt=$zt,$zt="s next=$zpos,$p(next,""+"",2)=$p(next,""+"",2)+1 w !,$zs g @next"
	zat x s c=c+1 w !,"ZATtach ignores undefined argument"
	s $zt=zt
	w !,$s(c:"BAD result",1:"OK")," from test of ZATtach detecting UNDEF"
	q
