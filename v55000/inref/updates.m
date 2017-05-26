startone;
	set ^stop=0
	set jobid=1
	set jmaxwait=0
	do ^job("one^updates",1,"""""")
	quit
one	;
	f i=1:1  quit:^stop=1  set ^one(i)=$j(i,20)
	quit
