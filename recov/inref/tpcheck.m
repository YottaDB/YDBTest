tpcheck;
	;	Checks the database, if database has correct data
	;	Check if nothing is lost or, nothing is duplicate
	;   This program for database fills using primitive root of a field. 
        ;   Say, w is the primitive root and we have 5 jobs
        ;   Job 1 : Sets index w^0, w^5, w^10 etc.
        ;   Job 2 : Sets index w^1, w^6, w^11 etc.
        ;   Job 3 : Sets index w^2, w^7, w^12 etc.
        ;   Job 4 : Sets index w^3, w^8, w^13 etc.
        ;   Job 5 : Sets index w^4, w^9, w^14 etc.
        ;   In above example nroot = w^5
        ;   In above example root =  w

	S maxerr=100
	S fail=0
	S jobcnt=$GET(^totaljob)
	if jobcnt=0 w "Cannot Check! Jobcnt=",jobcnt,! q
	;
	SET prime=$GET(^prime)
        SET root=$GET(^root)
	;
        SET nroot=1
        F J=1:1:jobcnt SET nroot=(nroot*root)#prime
	SET ival=1

	F K=1:1:jobcnt D
	. SET I=ival
	. F loop=1:1:$GET(^lasti(K)) D  q:(fail>maxerr)
	. . SET jvalaa=I_$J(I,70)
	. . SET jvalmm=I_$J(I,71)
	. . SET jvala=I_$J(I,80)
	. . SET jvalb=I_$J(I,79)
	. . SET jvalc=I_$J(I,78)
	. . SET jvald=I_$J(I,77)
	. . SET jvale=I_$J(I,76)
	. . SET jvalf=I_$J(I,75)
	. . SET jvalg=I_$J(I,74)
	. . SET jvalh=I_$J(I,73)
	. . SET jvali=I_$J(I,72)
	. . if $GET(^a(I))'=jvala w "Wrong TP: ^a(",I,")=",$GET(^a(I)),! S fail=fail+1
	. . if $GET(^b(I))'=jvalb w "Wrong TP: ^b(",I,")=",$GET(^b(I)),! S fail=fail+1
	. . if $GET(^c(I))'=jvalc w "Wrong TP: ^c(",I,")=",$GET(^c(I)),! S fail=fail+1
	. . if $GET(^d(I))'=jvald w "Wrong TP: ^d(",I,")=",$GET(^d(I)),! S fail=fail+1
	. . if $GET(^e(I))'=jvale w "Wrong TP: ^e(",I,")=",$GET(^e(I)),! S fail=fail+1
	. . if $GET(^f(I))'=jvalf w "Wrong TP: ^f(",I,")=",$GET(^f(I)),! S fail=fail+1
	. . if $GET(^g(I))'=jvalg w "Wrong TP: ^g(",I,")=",$GET(^g(I)),! S fail=fail+1
	. . if $GET(^h(I))'=jvalh w "Wrong TP: ^h(",I,")=",$GET(^h(I)),! S fail=fail+1
	. . if $GET(^i(I))'=jvali w "Wrong TP: ^i(",I,")=",$GET(^i(I)),! S fail=fail+1
	. . if $GET(^aa(I))'=jvalaa w "Wrong NON-TP: ^aa(",I,")=",$GET(^aa(I)),! S fail=fail+1
	. . if $GET(^mm(I))'=jvalmm w "Wrong NON-TP: ^mm(",I,")=",$GET(^mm(I)),! S fail=fail+1
	. . if $DATA(^zz(I))=0 D
	. . . if $data(^a(I,1)) w "Wrong TP: ^a(",I,",",1,")=",$GET(^a(I,1)),! S fail=fail+1
	. . . if $data(^b(I,1)) w "Wrong TP: ^b(",I,",",1,")=",$GET(^b(I,1)),! S fail=fail+1
	. . . if $data(^c(I,1)) w "Wrong TP: ^c(",I,",",1,")=",$GET(^c(I,1)),! S fail=fail+1
	. . . if $data(^d(I,1)) w "Wrong TP: ^d(",I,",",1,")=",$GET(^d(I,1)),! S fail=fail+1
	. . . if $data(^e(I,1)) w "Wrong TP: ^e(",I,",",1,")=",$GET(^e(I,1)),! S fail=fail+1
	. . . if $data(^f(I,1)) w "Wrong TP: ^f(",I,",",1,")=",$GET(^f(I,1)),! S fail=fail+1
	. . . if $data(^g(I,1)) w "Wrong TP: ^g(",I,",",1,")=",$GET(^g(I,1)),! S fail=fail+1
	. . . if $data(^h(I,1)) w "Wrong TP: ^h(",I,",",1,")=",$GET(^h(I,1)),! S fail=fail+1
	. . . if $data(^i(I,1)) w "Wrong TP: ^i(",I,",",1,")=",$GET(^i(I,1)),! S fail=fail+1
	. . . F J=2:1:jobcnt D 
	. . . . if $GET(^a(I,J))'=(jvala_J) w "Wrong TP: ^a(",I,",",J,")=",$GET(^a(I,J)),! S fail=fail+1
	. . . . if $GET(^b(I,J))'=(jvalb_J) w "Wrong TP: ^b(",I,",",J,")=",$GET(^b(I,J)),! S fail=fail+1
	. . . . if $GET(^c(I,J))'=(jvalc_J) w "Wrong TP: ^c(",I,",",J,")=",$GET(^c(I,J)),! S fail=fail+1
	. . . . if $GET(^d(I,J))'=(jvald_J) w "Wrong TP: ^d(",I,",",J,")=",$GET(^d(I,J)),! S fail=fail+1
	. . . . if $GET(^e(I,J))'=(jvale_J) w "Wrong TP: ^e(",I,",",J,")=",$GET(^e(I,J)),! S fail=fail+1
	. . . . if $GET(^f(I,J))'=(jvalf_J) w "Wrong TP: ^f(",I,",",J,")=",$GET(^f(I,J)),! S fail=fail+1
	. . . . if $GET(^g(I,J))'=(jvalg_J) w "Wrong TP: ^g(",I,",",J,")=",$GET(^g(I,J)),! S fail=fail+1
	. . . . if $GET(^h(I,J))'=(jvalh_J) w "Wrong TP: ^h(",I,",",J,")=",$GET(^h(I,J)),! S fail=fail+1
	. . . . if $GET(^i(I,J))'=(jvali_J) w "Wrong TP: ^i(",I,",",J,")=",$GET(^i(I,J)),! S fail=fail+1
	. . else  D
	. . . if ^zz(I)'=(I_$J(I,72)) w "Wrong Non-TP: ^zz(",I,")=",^zz(I,J),! S fail=fail+1
	. . if (fail>maxerr) w "Too many errors:",!
	. . SET I=(I*nroot)#prime
        . SET ival=(ival*root)#prime
	if fail=0 w "tpcheck PASSED.",!
	else  w "tpcheck FAILED.",!
	q
