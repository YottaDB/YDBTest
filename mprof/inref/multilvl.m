multilvl; 
	w !,"Testing multilevel m routines, internal and external, and various command/comment/local/global variations...",!
	VIEW "TRACE":1:"^TRACE(""ZMPROF6"")"
	s a=$$^pow(3,2)
	d lvl3
	d lvl3^lvls
	w "Nest 3 levels",!
	s i="" f  s i=$O(^gbl(i)) q:i=""  w i," "
	w !
	VIEW "TRACE":0:"^TRACE(""ZMPROF6"")"
	;zwr ^TRACE("ZMPROF6",*)
	q
lvl3	;
	s lcl(3)=3
	d lvl2
	d lvl2^lvls
	q
lvl2	;
	s lcl(2)=2
	d lvl1
	d lvl1^lvls
	q
lvl1	;
	s lcl(1)=1
	q

