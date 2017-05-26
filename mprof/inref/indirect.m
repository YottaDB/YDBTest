indirect;
	w !,"Testing indirection...",!
	VIEW "TRACE":1:"^TRACE(""ZMPROF2"")"
	d ^testind
	VIEW "TRACE":0:"^TRACE(""ZMPROF2"")"
	;zwr ^TRACE("ZMPROF2",*)
	q
