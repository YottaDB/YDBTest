testit	;
	w "(in testit) First some Set's and Write's to see everything is all right:",!
	s ^A=1
	s ^B=2
	s ^C=3
	s ^X=4
	w "The values of ^A,^B,^C,^X are:",^A,^B,^C,^X,!
	w !,"Testing locks..."
	d ^lkebas
	w !,"Testing z(de)allocate and locks..."
	d ^zalloc
	w !
	q
