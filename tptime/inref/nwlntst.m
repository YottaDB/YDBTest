nwlntst(timeout,longwait);
	d ^init(timeout,longwait)
	set passed=0
	tstart ():serial 
	set tbegtp=$h
	f i=1:1 hang .001 DO  q:passed>^longwait
	.  set indx=$r(i)*$r(i)*$r(i)
	.  set indx=indx#10
	.  set dummy=$order(^dummy(indx-1))
	.  set ver1="^abc("_indx_",2)"
	.  set ver2="^abc("_indx_",3)"
	.  set ver3="^abc("_indx_",4)"
	.  set ver4="^abc("_indx_",5)"
	.  set ver5="^abc("_indx_",6)"
	.  set ^dummy(indx,2)=$order(^dummy(indx-1))
	.  set ^dummy(indx,3)=$get(^dummy(indx-1))
	.  set ^dummy(indx,4)=$data(^dummy(indx-1))
	.  set ^dummy(indx,5)=$order(^dummy(indx-1))
	.  set ^dummy(indx,6)=$order(^dummy(indx-1))
	.  set ^dummy(indx,7)=$order(^dummy(indx-1))
	.  set ^dummy(indx,8)=$order(^dummy(indx-1))
	.  set ^dummy(indx,9)=$order(^dummy(indx-1))
	.  set @ver1=^dummy(indx,2)
	.  set @ver2=^dummy(indx,3)
	.  set @ver3=^dummy(indx,4)
	.  set @ver4=^dummy(indx,5)
	.  set @ver5=^dummy(indx,6)
	.  set now=$h  
	.  set passed=$$^difftime(now,tbegtp)
	W "Loop finished at i=",i,!
	w "Message inside TP:TP Timeout does not work at all. Did not trap to the $ztrap routine!!!",!    
	tcommit
	w "Message after TC: TP Timeout does not work at all. Did not trap to the $ztrap routine!!!",!   
	d ^finish
	q
