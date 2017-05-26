	;;; seta.m
	; 
	w !,"came into seta.m",!
	s ^signaltochecka=0
	lock ^semaphore
	s ^semaphore=^semaphore+1
	lock
	for i=1:1:1000 q:^fflag="freezed"  w "i = ",i," : waiting still -- fflag",! h 1
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;  the intention of the following h 1 is to have the mupip freeze started out.
	;  this assumes that the freeze takes more than 1 second to complete
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	h 1
	w !,i," seconds passed waiting for the freezed signal",!
	set ^a="new"
	set ^signaltochecka=1
	lock ^flagflag
	i $d(^flagflag)  s ^flagflag=^flagflag-1  
	lock
	h
