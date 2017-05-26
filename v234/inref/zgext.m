zgext	;
	;
	s zl=$zl
	s i=0
lab	w $$f1
	w $$f2
	w $$f3
	w $$f4
	x "w $$f4"
	w $$f5
	w !,"OK from ZGEXT"
	q
f1()	
	s i=i+1
	zg zl:lab+i
	;
f2()	
	q $$f1
	;
f3()	
	q $$@("f2")
	;
f4()
	x "w $$f3"
	q
f5()
	s i=i+1
	x "zg zl:lab+i"
	;
