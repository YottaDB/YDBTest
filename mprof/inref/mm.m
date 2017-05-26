multilvl; 
	VIEW "TRACE":1:"^TRACE(""ZMPROF6"")"
	s a=$$^pow(3,2)
	d lvls
	VIEW "TRACE":0:"^TRACE(""ZMPROF6"")"
	zwr ^TRACE("ZMPROF6",*)
	q
