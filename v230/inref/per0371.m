per0371	;per0371 - Non graphic characters cause confusing ZWRite
	;
	k
	s a=$c(10),c=0,sd="per0371.tmp"
	o sd u sd zwr
	u sd:rew r x c sd:delete
	i x'="a=$C(10)" s c=c+1 w !,"a=$C(10) ; zwrite produced: ",!,x
	w !,$s(c:"BAD result",1:"OK")," from test of zwrite of non graphic characters"
	q
