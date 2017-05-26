per0335	; ; ; per0335 - Strings in the form of out of range exponential numbers cause 0 subscripts
	;
	i $zv["VMS" n $zt s $zt="zm 12" ; trigger process dump
	s c=0,m=""
	f j=1:1:15 s m=m_$e(j,$l(j)),l=35-j f e=-l:1:l d test
	w !,$s(c:"BAD result",1:"OK")," from test of simple E subcripts"
	q
test	k ^ar
	s x=m_"E"_e,^ar(+x)=x
	s y=$o(^ar(""))
	i y'=+x s c=c+1 w !,"numeric key ",x," transmuted to ",y
	k ar
	q
	s ^ar(x)=x
	s y=$o(^ar(""))
	i y'=x s c=c+1 w !,"string key ",x," transmuted to ",y
	q
