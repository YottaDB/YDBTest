d002703	;
	quit
start	;
	set jmaxwait=0
	set ^stop=0
	do ^job("child^d002703",1,"""""")
	quit
stop	;
	set ^stop=1
	do wait^job
	quit
child	;
	for i=1:1  quit:^stop=1  set ^x(i)=$j(i,200) h 0.1
	quit
smallupd;
	for i=1:1:100  set ^x($j,i)=$j(i,20)
	quit
	
