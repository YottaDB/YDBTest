ztp;;;
	s unix=$zv'["VMS"
	H 2
	if unix zsy "$gtm_tst/com/abs_time.csh time1.txt"
	else  zsy "pipe write sys$output f$time() > time1.txt"
	ZTS
	FOR i=1:1:10 SET ^a(i)=i
	ZTC
	H 2
	if unix zsy "$gtm_tst/com/abs_time.csh time2.txt"
	else  zsy "pipe write sys$output f$time() > time2.txt"
	H 2
	SET ^x("dummy")=123
	ZTS
	FOR i=1:1:10 SET ^a(i)=i*10
	H 2
	;no ZTC
	Q
