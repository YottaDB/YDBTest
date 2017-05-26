mrgclnup;
	;C9C01-001886 Assert failure in op_merge.c line 112  
	NEW $ZTRAP
	SET $ZTRAP="GOTO errcont^errcont" 
	s a(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18)=1 
	m ^b(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18)=a 
	m ^b(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18)=a
	s newc("",1)="58807,40083" 
	zwr newc
	s ^a("")=1   
	m ^a("")=newc     
	m ^a("")=newc   
	q
