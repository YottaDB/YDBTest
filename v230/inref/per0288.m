per0288	;per0288 - automatic reset of $ztrap
	;
	s zt=$zt,$zt="s next=$zpos,$p(next,""+"",2)=$p(next,""+"",2)+1 w !,$zs g @next"
	s x=4/0
	s x=4/0
	s $zt=zt
	w !,"OK from test of $ztrap retained"
	q
