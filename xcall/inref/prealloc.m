prealloc ;
	;
	Set achrpp="C-style string"
	Do &prealloc^correct(.achrpp)
	Write "  value returned from prealloc = """,achrpp,"""",!!
	Do &alloc32k(.achrpp)
	Write "Now length is : ",$L(achrpp),!
	Do verify(achrpp)
	Do &alloc64k(.achrpp)
	Write "Now length is : ",$L(achrpp),!
	Do verify(achrpp)
	Do &alloc75k(.achrpp)
	Write "Now length is : ",$L(achrpp),!
	Do verify(achrpp)
	Do &alloc1mb(.achrpp)
	Write "Now length is : ",$L(achrpp),!
	Do verify(achrpp)
	Do &alloc32kstr(.achrpp)
	Write "Now length is : ",$L(achrpp),!
	Do verify(achrpp)
	Do &alloc64kstr(.achrpp)
	Write "Now length is : ",$L(achrpp),!
	Do verify(achrpp)
	Do &alloc75kstr(.achrpp)
	Write "Now length is : ",$L(achrpp),!
	Do verify(achrpp)
	Do &alloc1mbstr(.achrpp)
	Write "Now length is : ",$L(achrpp),!
	Do verify(achrpp)
	Write "Do &noprealloc(.outval)"
	Do &noprealloc(.outval)
	q

verify(str)
	set tmpstr=""
	f i=1:1:$L(str) s tmpstr=tmpstr_"A"
	if str=tmpstr w "Passed",!
	else  w "Failed",!
	q
