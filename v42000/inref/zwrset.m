zwrset(top);
	for i=1:1:top s aaa(i)=i*123.456789
	for i=1:1:top s bbb(i)=i*1234.56789
	for i=1:1:top s ccc(i)=i*12345.6789
	for i=1:1:top s x("A","B",aaa(i),bbb(i),ccc(i),"DDD",i)=i
	;zwr x("A","B",*)
	q
	
