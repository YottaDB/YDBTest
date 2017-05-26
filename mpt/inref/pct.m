PCT	W !,"Test of differentiation between % and regular routines",!
	s ERR=0
	D %LAB1,EXAM("local label with %",VCOMP,"%LAB1^pct")
	D ^%pct1,EXAM("%routine, first line",VCOMP,"^%pct1")
	D ^pct1,EXAM("first line in regular routine",VCOMP,"^pct1")
	D LAB2^pct1,EXAM("global label ",VCOMP,"LAB2^pct1")
	D LAB2^%pct1,EXAM("global label in % routine ",VCOMP,"LAB2^%pct1")
	D %LAB2^pct1,EXAM("global label in %label ",VCOMP,"%LAB2^pct1")
	D %LAB2^%pct1,EXAM("global label in %label, %routine",VCOMP,"%LAB2^%pct1")
	D %LAB2+1^pct1,EXAM("global label in %label+1",VCOMP,"%LAB2+1^pct1")
	D LAB2+1^%pct1,EXAM("global label in label+1, %routine",VCOMP,"LAB2+1^%pct1")
	i ERR=0 w "d  PASS",!
	Q

%LAB1	s VCOMP="%LAB1^pct" q

%LAB2	s VCOMP="%LAB2^pct" q 

LAB2	s VCOMP="LAB2^pct" q

LAB5	s VCOMP="LAB5^pct" q

EXAM(LAB,VCOMP,VCORR)
	i VCOMP=VCORR q
	s ERR=ERR+1
	w " ** FAIL in ",LAB,!
	w ?10,"CORRECT  =",VCORR,!
	w ?10,"COMPUTED =",VCOMP,!
	q

