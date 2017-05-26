REPORT	;
INIT	s hdr="HEADER TEXT"
	f i=1:1:200 s ^ACCT(i)="DATA"_i
	s ^ACCT("a")=$$^longstr(240)
	;
	SET sd="temp.dat",acct=""
	OPEN sd:newversion U sd:width=132
	FOR  SET acct=$O(^ACCT(acct)) QUIT:acct=""  DO
	. SET rec=$$FORMAT(acct)
	. WRITE:$Y>55 #,hdr W !,rec," "
	CLOSE sd
	QUIT
FORMAT(X) ;
	q $J("#"_X_" -> "_^ACCT(X)_"#",20)
