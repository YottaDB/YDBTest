zalloc	; test ZALLOCATE, ZDEALLOCATE, together with LOCK
	; use do lkeexam^lkebas(0,".",".",".",".",0)	, it is still valid
	s waittim=5
	Set fncnt=0
basic	w !,"z(de)alloc"
	if 1	; $truth is printed by the below do check command so set it to a definite value
	d check(1,"","") 
	do lkeexam^lkebas(1,".",".",".",".",0)
	za ^a:waittim
	d check(2,"","^a") 
	do lkeexam^lkebas(2,"^a",".",".",".",1)
	zd ^a
	d check(3,"","")
	do lkeexam^lkebas(3,".",".",".",".",0)
	za (^a,^b):waittim
	d check(4,"","^a,^b")
	do lkeexam^lkebas(4,"^a","^b",".",".",2)
	za (^a,^b):waittim
	d check(5,"","^a,^b")
	do lkeexam^lkebas(5,"^a","^b",".",".",2)
	za ^c:waittim
	d check(6,"","^a,^b,^c")
	do lkeexam^lkebas(6,"^a","^b","^c",".",3)
	za ^d:waittim
	d check(7,"","^a,^b,^c,^d")
	do lkeexam^lkebas(7,"^a","^b","^c","^d",4)
	zd ^b
	d check(8,"","^a,^c,^d")
	do lkeexam^lkebas(8,"^a",".","^c","^d",3)
	zd ^a,^b,^c,^d
	d check(9,"","")
	do lkeexam^lkebas(9,".",".",".",".",0)

local	w !,"local locks and z(de)alloc"
	za a:waittim
	d check(10,"","a")
	do lkeexam^lkebas(10,"a",".",".",".",1)
	za b:waittim
	d check(11,"","a,b")
	do lkeexam^lkebas(11,"a","b",".",".",2)
	za (a,b,c,d):waittim
	d check(12,"","a,b,c,d")
	do lkeexam^lkebas(12,"a","b","c","d",4)
	zd d
	d check(13,"","a,b,c")
	do lkeexam^lkebas(13,"a","b","c",".",3)
	l a:waittim ; l a causes a deadlock - vinu
	d check(14,"a","a,b,c")
	zd a
	do lkeexam^lkebas(14,"a","b","c",".",3)
	d check(15,"a","b,c")
	do lkeexam^lkebas(15,"a","b","c",".",3)
	l b:waittim ; l b causes a deadlock - vinu
	d check(16,"b","b,c")
	do lkeexam^lkebas(16,".","b","c",".",2)
	l
	zd b,c
	d check(17,"","")
	do lkeexam^lkebas(17,".",".",".",".",0)

mix	w !,"locks and z(de)alloc together"
	za ^c:waittim
	d check(18,"","^c")
	do lkeexam^lkebas(18,".",".","^c",".",1)
	l ^c:waittim
	d check(19,"^c","^c")
	do lkeexam^lkebas(19,".",".","^c",".",1)
	l +^b:waittim
	d check(20,"^b,^c","^c")
	do lkeexam^lkebas(20,".","^b","^c",".",2)
	za ^b:waittim
	d check(21,"^b,^c","^b,^c")
	do lkeexam^lkebas(21,".","^b","^c",".",2)
	za (^a,^d):waittim
	d check(22,"^b,^c","^a,^b,^c,^d")
	do lkeexam^lkebas(22,"^a","^b","^c","^d",4)
	l (^a,^d):waittim
	d check(23,"^a,^d","^a,^b,^c,^d")
	do lkeexam^lkebas(23,"^a","^b","^c","^d",4)
	l (^a,^b,^c,^d):waittim
	d check(24,"^a,^b,^c,^d","^a,^b,^c,^d")
	do lkeexam^lkebas(24,"^a","^b","^c","^d",4)
	zd ^a,^b,^c
	d check(25,"^a,^b,^c,^d","^d")
	do lkeexam^lkebas(25,"^a","^b","^c","^d",4)
	l
	d check(26,"","^d")
	do lkeexam^lkebas(26,".",".",".","^d",1)
	zd ^d
	d check(27,"","")
	do lkeexam^lkebas(27,".",".",".",".",0)
	q




check(k,locargs,zalargs) ;levels??
	w "check(",k,",",locargs,",",zalargs,") "
	w $T,!
	q
	k zal,loc,actual
	; check the results
	;prepare lock args
	s i0=1,i1=$F(locargs,",",i0)
	i i1=0 s i1=$L(locargs)+2
	f i=1:1:4 q:i0=0  d
	. s loc(i)=$E(locargs,i0,i1-2),loccnt=i
	. s i0=$F(locargs,",",i0),i1=$F(locargs,",",i0) 
	. i i1=0 s i1=$L(locargs)+2
	;zwr loc
	i loc(1)="" s loccnt=0
	s i0=1,i1=$F(zalargs,",",i0)
	i i1=0 s i1=$L(zalargs)+2
	f i=1:1:4 q:i0=0  d
	. s zal(i)=$E(zalargs,i0,i1-2),zalcnt=i
	. s i0=$F(zalargs,",",i0),i1=$F(zalargs,",",i0) 
	. i i1=0 s i1=$L(zalargs)+2
	;zwr zal
	i zal(1)="" s zalcnt=0
	zshow "l":actual
	s i=1,matchl=0,matchz=0,locstr="",zalstr="",locactcnt=0,zalactcnt=0
	f  q:$D(actual("L",i))'=1  d
	. s nowexam=actual("L",i)
	. if $E(nowexam,1,3)="LOC"  d
	. . s locactcnt=locactcnt+1
	. . s locstr=locstr_","_$E(nowexam,6,$F(nowexam,"LEVEL")-7)
	. . for j=1:1:loccnt  q:loc(j)=""  d
	. . . ;w nowexam," vs ","LOCK "_loc(j)_" LEVEL=1",!
	. . . s cmp="LOCK "_loc(j)_" LEVEL=1"
	. . . if nowexam=cmp s matchl=matchl+1
	. else  d
	. . s zalactcnt=zalactcnt+1
	. . s zalstr=zalstr_","_$E(nowexam,5,$L(nowexam))
	. . for j=1:1:zalcnt  d
	. . . q:zal(j)=""
	. . . s cmp="ZAL "_zal(j)
	. . . ;w nowexam," vs ",cmp
	. . . if nowexam=cmp s matchz=matchz+1
	. s i=i+1
	s faill=1,failz=1
	i loccnt=matchl,locactcnt=matchl s faill=0
	i zalcnt=matchz,zalactcnt=matchz s failz=0
	i faill=0,failz=0 w !,k,"   GTM MATCH"  q
	w !,k,"   GTM MISMATCH"
	;w "Z:",matchz," L:",matchl," zalcnt:",zalcnt," loccnt:",loccnt
	;w " locactcnt:",locactcnt," zalactcnt:",zalactcnt,!
	;w faill,"<=>",failz,!
	if faill d
	. w !,"        => LOCKS"
	. w !,"        was expecting: ",locargs
	. w !,"        actual:        ",locstr
	if failz d
	. w !,"        => ZAL",!
	. w !,"       was expecting: ",zalargs
	. w !,"       actual:        ",zalstr
	q
