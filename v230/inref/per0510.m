per0510	;per0510 - error recovery after a ZLink incorrect
	;
	s c=0,zt=$zt,zl=$zl,$zt="w !,$zs zg zl:lab^"_$p($zpos,"^",2)
	x "d ^per0510a"
lab	s $zt=zt
	w !,"OK from test of error recovery after zlink"
