	;;; checka.m
	;
	w !,"came into checka.m",!
	lock ^semaphore
	s ^semaphore=^semaphore+1
	lock
	for i=1:1:1000 q:^fflag="freezed"  w "i = ",i," : waiting still -- fflag",! h 1
	w !,i," seconds passed waiting for the freezed signal",!
	;
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; wait for some more time so that seta has started setting ^a 
	; and is waiting while you can proceed
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	h 1 
	;
	;
	w !,^a,!
	for j=1:1:1000 q:^fflag="unfreezed"  w "j = ",j," : waiting still -- fflag",! h 1
	w !,j," seconds passed waiting for the unfreezed signal",!
	for j=1:1:1000 q:^signaltochecka=1  w "j = ",j," : waiting still -- signal_to_checka",! h 1
	w !,^a,!
	lock ^flagflag
	i $d(^flagflag)  s ^flagflag=^flagflag-1  
	lock
	h
