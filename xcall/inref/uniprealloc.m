prealloc ;
	;
	Set achrpp="Initial string"
	Do &prealloc^correct(.achrpp)
	Write "Value returned from prealloc = """,achrpp,"""",!!
	Do &alloc32k(.achrpp)
	Write "After alloc32: Now length is : ",$ZL(achrpp),!
	Do verify(achrpp,"β")
	Do &alloc64k(.achrpp)
	Write "After alloc64: Now length is : ",$ZL(achrpp),!
	Do verify(achrpp,"私")
	Do &alloc75k(.achrpp)
	Write "After alloc75: Now length is : ",$ZL(achrpp),!
	Do verify(achrpp,"は")
	Do &alloc1mb(.achrpp)
	Write "After alloc1mb: Now length is : ",$ZL(achrpp),!
	Do verify(achrpp,"𠞉")
	q

verify(str,uchar)
	set tmpstr=""
	f i=1:1:$L(str) s tmpstr=tmpstr_uchar
	if str=tmpstr w "Passed",!
	else  w "Failed",!
	q
