sym1	;variations on paramter passing and gotos
	;
	s a=1 d lab1(a) w a
	s a=2 d lab2(a) w a
	s a=3 d lab3(a) w a
	s a=4 d lab4(a) w a
	s a=5 d lab5(a) w a
	s a=6 d lab6(a) w a
	s a=7 d lab7(a) w a
	s a=8 d lab8(a) w a
	s a=9 d lab9(a) w a
	q
lab1(a)
	n
	q
lab2(a)
	g quit
lab3(a)
	g set
lab4(a)
	g kill
lab5(a)
	g new
lab6(a)
	g quit^sym1
lab7(a)
	g set^sym1
lab8(a)
	g kill^sym1
lab9(a)
	g new^sym1
quit	q
set	s a=a+100
	q
kill	k a
	q
new	n
	q
