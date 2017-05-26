per2607f ; ; ; do transaction big enough to trigger a garbage collect
	;
	tstart ():serial
	f i=1,3,2 s ^a(i_$j(i,240))="foo"_$j(i,240)
	f j=1:1:100 s ^a(i_$j(i,240))=$j(j,240)
	tcommit
	q
