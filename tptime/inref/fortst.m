fortst(timeout,longwait);
	d ^init(timeout,longwait)
	set passed=0
	tstart ():serial 
	set tbegtp=$h
	f i=1:1 set now=$h  set passed=$piece(now,",",2)-$piece(tbegtp,",",2)  set ^dummy(i#10)=$j(i*i/3.14,200) hang .001 DO  q:passed>^longwait
	W "Loop finished at i=",i,!
	w "Message inside TP:TP Timeout does not work at all. Did not trap to the $ztrap routine!!!",!    
	tcommit
	w "Message after TC: TP Timeout does not work at all. Did not trap to the $ztrap routine!!!",!   
	d ^finish
	q
