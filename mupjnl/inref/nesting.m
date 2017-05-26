nesting	; To test max TP and ZTP levels
lztp	s max=1000
	ZTS
	s ^ZTP=1
	f i=1:1:100 s ^ZTP(i)=i
	ZTC
	h 1 ; to make sure time stamp is different
	f i=1:1:max d
                . ztstart 
                . S ^za(i)="za"_i
ltp     s max=1000
	TS ():(serial:transaction="BA")
	s ^TP=1
	f i=1:1:100 s ^TP(i)=i*i
	TC
        h 1 ;to make sure time stamp is different
	view "JNLFLUSH"
	f i=1:1:max tstart ():(serial:transaction="BA") s ^a(i)="a"_i
        quit    
	;
	; verify the data
vertp	s fail=0
	i 0=$D(^TP) s fail=1 w "^TP DATA MISSING",!
	i 10>$D(^TP) s fail=1 w "^TP() DATA MISSING",!
	e  for i=1:1:100 i i*i'=^TP(i) s fail=1 w "^TP() DATA MISSING",!
	i 0'=$D(^a) s fail=1 w "^a DATA SHOULD NOT BE THERE",!
	d verend
	q
verztp	s fail=0
	i 0=$D(^ZTP) s fail=1 w "^ZTP DATA MISSING",!
	i 10>$D(^ZTP) s fail=1 w "^ZTP() DATA MISSING",!
	e  for i=1:1:100 i i'=^ZTP(i) s fail=1 w "^ZTP() DATA MISSING",!
	i 0'=$D(^za) s fail=1 w "^za DATA SHOULD NOT BE THERE",!
	d verend
	q
verend	i 1=fail w "FAILED VERIFICATION. Data is not complete.",!
	e  w "PASSED VERIFICATION",!
