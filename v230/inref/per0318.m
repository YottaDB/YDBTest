per0318	;per0318 - Handle K @"" and N @""
	s ^c=0
	s zl=$zl,^zt=$zt,$zt="s next=$zpos,$p(next,""+"",2)=$p(next,""+"",2)+1,zl="_zl_" w !,$zs zg @(zl_"":""_next)"
	s a=1
	d litnew
	i '$d(a) s ^c=^c+1 w !,"variable missing on return from new"
	k @""
	i $d(a) s ^c=^c+1 w !,"variable not killed"
	s x="",a=1
	d varnew
	i '$d(a) s ^c=^c+1 w !,"variable missing on return from new"
	k @x
	i $d(a) s ^c=^c+1 w !,"variable not killed"
	s x="",a=1
	d newx
	x "k @x"
	i $d(a) s ^c=^c+1 w !,"variable not killed"
	k x
	k @x s ^c=^c+1 w !,"undefined argument not detected by an indirect kill"
	n @n s ^c=^c+1 w !,"undefined argument not detected by an indirect new"
	s $zt=^zt
	w !,$s(^c:"BAD result",1:"OK")," from test of kill and new indirect null arguments"
	q
litnew	n @"" 
	i $d(a) s ^c=^c+1 w !,"variable not newed"
	q
varnew	n @x 
	i $d(a) s ^c=^c+1 w !,"variable not newed"
	q
newx	x "n @x" 
	i '$d(a) s ^c=^c+1 w !,"variable missing on return from new"
	q
