c002003	;
	; C9B10-001765 $Order() can give bad result if 2nd arg is an extrinsic that manipulates 1st arg
	;
	set istp=$random(2)
	set ^istp=istp	; for debugging purposes in case test fails
	do ordlocal
	do ordglobal
	do getlocal
	do getglobal
	quit
	;
ordlocal;
	write !,"Test $Order() gives correct result if 2nd arg is an extrinsic that manipulates LOCAL 1st arg",!
	kill V
	set a=$order(V(2,-1),$$ordlcl)
	write "$order(V(2,-1),$$ordlcl) (Expected=2) is = ",a,!
	quit
	;
ordlcl()	;
	set V(2,2)=1
	quit 1
	;
ordglobal	;
	write !,"Test $Order() gives correct result if 2nd arg is an extrinsic that manipulates GLOBAL 1st arg",!
	kill ^V
	tstart:istp ():serial
	set a=$order(^V(2,-1),$$ordgbl)
	tcommit:istp
	write "$order(^V(2,-1),$$ordgbl) (Expected=2) is = ",a,!
	write "$reference (Expected=^V(2,2)) is = ",$reference,!
	quit
	;
ordgbl()	;
	set ^V(2,2)=1
	quit 1
getlocal;
	; The following two tests check that $GET works as well as $ORDER above.
	write !,"Test $Get() gives correct result if 2nd arg is an extrinsic that manipulates LOCAL 1st arg",!
	kill V
	set a=$get(V(2,2),$$getlcl)
	write "$get(V(2,2),$$getlcl) (Expected=""bar"") is = ",a,!
	quit
	;
getlcl()	;
	set V(2,2)="foo"
	quit "bar"
	;
getglobal	;
	write !,"Test $Get() gives correct result if 2nd arg is an extrinsic that manipulates GLOBAL 1st arg",!
	kill ^V,^bar
	tstart:istp ():serial
	set ^bar="^bar"
	set a=$get(^V(2,2),$$getgbl)
	tcommit:istp
	write "$get(^V(2,2),$$getgbl) (Expected=""^bar"") is = ",a,!
	write "$reference (Expected=^bar) is = ",$reference,!
	quit
	;
getgbl()	;
	set ^V(2,2)="^foo"
	quit ^bar
