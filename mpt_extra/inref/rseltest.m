rseltest;
	w "HERE IN RSELTEST",!
	i $D(^%RSET) k ^%RSET
	d ^%RSEL
	zwr
	if ($D(^%RSET)) zwr ^%RSET
	d CALL^%RSEL		; a second time
	zwr
	if ($D(^%RSET)) zwr ^%RSET
	q
ZRSET	w "HERE"
	k ^%RSET
	s %ZRSET=1
	d rseltest
	q
