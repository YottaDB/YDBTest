actundef	;test undef in actuallist
	;
	n  n $zt s $zt="g err",zl=$zl
	d a(.a)
fail	d a(b)
	q
err	w !,$s($zl'=zl:"BAD",$p($p($zs,"^"),",",2)="fail":"OK",1:"BAD")," from actundef.m",!
	q
a(x)
	s x=1
	q
