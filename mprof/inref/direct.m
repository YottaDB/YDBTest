direct	;
	w !,"Testing direct routine calls...",!
	VIEW "TRACE":1:"^TRACE(""ZMPROF13"")"
	d ^testdir
	VIEW "TRACE":0:"^TRACE(""ZMPROF13"")"
	;zwr ^TRACE("ZMPROF13",*)
	q
