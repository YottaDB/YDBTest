bool	; Test of Boolean operators
	w !,"Test of Boolean operators",!
	s X="1|-1|.001|-.009|-7|5E-6|-987654321|3.1459|32768|9E34|3E-34|17bcd|-1cde"
	s X=X_"|0| 999999|abc| 1|cba-32"
	s B="1|1|1|1|1|1|1|1|1|1|1|1|1|0|0|0|0|0"
	s ERR=0,ITEM="Constants "
	do EXAM(ITEM_"'0",'0,1),EXAM(ITEM_"'1",'1,0)
	do EXAM(ITEM_"0!0",0!0,0),EXAM(ITEM_"0!1",0!1,1)
	do EXAM(ITEM_"1!0",1!0,1),EXAM(ITEM_"1!1",1!1,1)
	do EXAM(ITEM_"0&0",0&0,0),EXAM(ITEM_"0&1",0&1,0)
	do EXAM(ITEM_"1&0",1&0,0),EXAM(ITEM_"1&1",1&1,1)
	i ERR=0  w "c  PASS",!
	i ERR'=0 q
	s ERR=0,ITEM="Unary Boolean operation "
	f k=1:1:18  s x=$p(X,"|",k),b=$p(B,"|",k)  do unary(x,b)
	i ERR=0  w "u  PASS",!
	s ERR=0,ITEM="Binary Boolean operation "
	f k=1:1:18  s x=$p(X,"|",k),b=$p(B,"|",k)  do
	.	f j=1:1:18 s y=$p(X,"|",j),c=$p(B,"|",j)  do binary(x,y,b,c)
	i ERR=0  w "b  PASS",!
	q

unary(P,E)
	do EXAM(ITEM_"'"_P,'P,'E)
	do EXAM(ITEM_"''"_P,''P,E)
	q

binary(P,Q,E,F)
	do EXAM(ITEM_P_"!"_Q,P!Q,E!F)
	do EXAM(ITEM_P_"&"_Q,P&Q,E&F)
	do EXAM(ITEM_"'("_P_"!"_Q_")",'(P!Q),('E)&('F))
	do EXAM(ITEM_"'("_P_"&"_Q_")",'(P&Q),('E)!('F))
	f i=9:1:18  s z=$p(X,"|",i),d=$p(B,"|",i)  do
	.	do EXAM(ITEM_z_"&("_P_"!"_Q_")",z&(P!Q),(d&E)!(d&F))
	.	do EXAM(ITEM_z_"!("_P_"&"_Q_")",z!(P&Q),(d!E)&(d!F))
	q

EXAM(LAB,VCOMP,VCORR)
	i VCOMP=VCORR q
	s ERR=ERR+1
	w " ** FAIL in ",LAB,!
	w ?10,"CORRECT  =",VCORR,!
	w ?10,"COMPUTED =",VCOMP,!
	q
