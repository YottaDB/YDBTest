pertstmd	;pertstmd - test driver for mumps PER tests
	;
	s %zdrive=$p($zpos,"^",2),$zt="w !,$zs zg "_$zl_":err^"_%zdrive
err	k (%zdrive)
	f  s %ztst=$zsearch("per*.m",1) q:%ztst=""  d filt
	q
filt	s %ztst=$zparse(%ztst,"NAME")
	i %ztst=%zdrive q
	i $l(%ztst)>7 q
	i $zsearch(%ztst_".obj",2)'="" q
	w !,%ztst
	d new
	k (%zdrive)
	q
new	n (%ztst)
	d @("^"_%ztst) 
	q
