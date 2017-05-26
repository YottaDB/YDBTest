ztptp;
t1;
	F i=1:1:5 DO
	.ZTS
	.TS ():Serial
	.S ^a(i)=i
	.TC
	.ZTC
	q
t2;
	F i=1:1:5 DO
	.TS ():Serial
	.ZTS
	.S ^b(i)=i*i
	.ZTC
	.TC
	q
t3;
	F i=1:1:5 DO
	.ZTS
	.S ^c(i)=i*i
	.TS ():Serial
	.S ^d(i)=i
	.TC
	.S ^e(i)=i
	.ZTC
	q
	
