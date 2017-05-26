per0465	;per0465 - solve the new version rms problem
	; delete rms io descriptors on close
	s c=0
	o "per0465.dat":newv
	c "per0465.dat"
	o "per0465.dat":read
	c "per0465.dat"
	o "per0465.dat":newv
	c "per0465.dat"
	f i=2,1,"" s x=$zsearch("per0465.dat.*"),v=$p(x,";",2) i i'=v s c=c+1 w !,"Expected version: ",i,!,"Found version: ",v
	w !,$s(c:"BAD result",1:"OK")," from test of io descriptors deleted on a close"
	q
