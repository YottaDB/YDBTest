test15;
t1;
	F i=1:1:5 DO
	. ZTSTART
	. S ^a(i)=i
	. S ^b(i)="B"_i
	. S ^c(i)="C"_i
	. ZTCOMMIT
	Q
t2;
	F i=1:1:5 DO
	. ZTSTART
	. S ^a(i)=i*i
	. S ^b(i)=i
	. S ^c(i)=i
	. ZTCOMMIT
	. H 1
	Q
t3;	
	F i=1:1:5 DO
	. ZTSTART
	. S ^c(i)=i*i
	. S ^d(i)=i
	. S ^e(i)=i
	. ZTCOMMIT
	Q
	
