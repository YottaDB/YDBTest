per0224	;per0224 - $text and zprint get stale code after a zlink
	;
	s c=0,sd="per0224.dat"
	o sd:newv u sd zp change^per0224a u ""
	s t=$t(change^per0224a)
	zsy "copy per0224c.m per0224a.m"
	zl "per0224a.m"
	i t=$t(change^per0224a) s c=c+1 w !,"$text got stale code after a zlink"
	u sd zp change^per0224a u ""
	u sd:rew r ozp,nzp u ""
	i ozp=nzp s c=c+1 w !,"zprint got stale code after a zlink"
	c sd:delete
	w !,$s(c:"BAD result",1:"OK")," from test of $t and zp after a ZLINK"
	q
