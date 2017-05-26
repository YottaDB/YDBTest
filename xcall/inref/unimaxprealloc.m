unimaxprealloc ;
	;
	Set achrpp="Initial string"
	Do &allocerr(.achrpp)
	Write "After alloc1mb: Now length is : ",$L(achrpp),!
	Do verify(achrpp)
	q

verify(str)
	set tmpstr=""
	f i=1:1:$L(str)/2 s tmpstr=tmpstr_"β"
	if str=tmpstr w "Passed",!
	else  w "Failed",!
	q
