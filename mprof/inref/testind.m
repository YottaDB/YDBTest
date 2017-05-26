testind	s dummy=1
	s i=0
	do lab
	q
lab	w !,"Processing External routine",!
	s indirect="lab1^exr"
	f i=1:1:10  do @indirect
	w !,"Processing Internal routine",!
	s indirect="lab1"
	f i=1:1:10  do @indirect
	q
lab1	f j=1:1:100 set j=j
	q 
