gext	;
	;
	w $$f1(1)
	x "w $$f1(2)"
	w $$f1^gext(3)
	x "w $$f1^gext(4)"
	w $$f2(5)
	x "w $$f2(6)"
	w $$f2^gext(7)
	x "w $$f2^gext(8)"
	w $$f3(9)
	x "w $$f3(8)"
	w $$f3^gext(7)
	x "w $$f3^gext(6)"
	w $$f4(5)
	x "w $$f4(4)"
	w $$f4^gext(3)
	x "w $$f4^gext(2)"
	q
f1(a)	
	d lab1
	q a
	;
f2(a)	
	d lab1^gext
	q a
	;
f3(a)	
	g lab2
	;
f4(a)	
	g lab2^gext
	;
lab1	s a=a*10
	q
lab2	q 2*a
	;
