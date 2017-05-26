testei	s dummy=1
	s i=0
	do lab
	q
lab	w !,"Processing External extrinsic function ",!
	f i=1:1:10  do lab1^exf(i) 
	w !,"Processing Internal extrinsic function ",!
	f i=1:1:10  do lab1(i)
	q
lab1(m)	f j=1:1:100 set j=j
	q 
