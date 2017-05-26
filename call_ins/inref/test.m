main ;
	w "begin(main)",!	
	do sub1
	w "end(main)",!
	quit

mtoc	; ; ; external call to c
	;TSTART
	w "begin(mtoc)",!
	s $et="errh",$zt="do errh",zzz=0
	w 1/zzz,!
	w "before xcall: stack = ",$stack($stack,"MCODE"),!
	s status=$&xcall.callc(10,20,.z)
	w "after xcall: stack = ",$stack($stack,"MCODE"),!
	w "z = ",z,!
	quit

sub1	;
	w !,"begin(sub1)",!	
	do mtoc
	w "end(sub1)",!
	q

entry2(p,q,r,s,t)	;
	w !,"begin(entry2)",!
	;w "et = ",$et," zt= ",$zt,!
	s $zt="do errh"
	w p," ",q,!
	w s," ",t,!
	k zzz
	w zzz,!
	do sub3(p,q,.r)
	w r,!
	w "end(entry2)",!
	w "after entry2: stack = ",$stack($stack,"MCODE"),!
	;TRESTART
	q

sub3(a,b,c)	;
	w !,"begin(sub3)",!	
	s c=a+b
	;zgoto 0;
	w "end(sub3)",!	
	q

errh	;
	set zzz=1
	q

err	;
	w "err called",!
	zshow
	q
