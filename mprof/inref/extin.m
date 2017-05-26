extin	;
	w !,"Testing external and internal extrinsic functions...",!
	VIEW "TRACE":1:"^TRACE(""ZMPROF1"")"
	d ^testei
	VIEW "TRACE":0
	;zwr ^TRACE("ZMPROF1",*)
	q
