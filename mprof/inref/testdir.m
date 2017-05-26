testdir	s dummy=1
	s i=0
	do lab
	q
lab	w !,"Processing External routine",!
	s direct="lab1^exr"
	f i=1:1:10  do lab1^exr
	w !,"Processing Internal routine",!
	s direct="lab1"
	f i=1:1:10  do lab1
	q
lab1	f j=1:1:100 set j=j
	q 
