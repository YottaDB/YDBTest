zlextgo1	;test zlink during an external goto within an extrinsic
	;
	w !,$$lab1(60000)
	w !,$$lab2(60000)
	q
	;
lab1(b)	
	d lab3
	q $g(r)
lab2(b)	
	d lab4
	q $g(r)
	;
lab3	g lab5^zlextgo1
	;
lab4	g lab5^zlextgo2
	;
lab5	s r=$zd(b)
	q
