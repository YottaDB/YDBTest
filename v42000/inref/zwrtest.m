zwrtest(top);
	for i=1:1:top if aaa(i)'=(i*123.456789)  w "aaa("_i_") is not correct. FAIL",! zshow "v" Q
	for i=1:1:top if bbb(i)'=(i*1234.56789)  w "bbb("_i_") is not correct. FAIL",! zshow "v" Q
	for i=1:1:top if ccc(i)'=(i*12345.6789)  w "ccc("_i_") is not correct. FAIL",! zshow "v" Q
	for i=1:1:top if x("A","B",aaa(i),bbb(i),ccc(i),"DDD",i)='i w "x is not correct for index ",i,". FAIL",!   zshow "v"  Q
	q
	
