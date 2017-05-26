cmptst	; Test of $FNUMBER function
;	File modified by Hallgarth on 30-APR-1986 11:02:50.88
	w 12*12/144,!,12*12/144-1,!
	s x=1234567.89,y="x",z="y"
	w $fn(x,"+T"),!,$fn(x,"+T",0),!,$fn(@y,"+T"),!,$fn(@y,"+T",0),!,$fn(@@z,"P"),!
	w $fn("-12"_@y,"P,",1),!,$fn("-"_@@z_"12","P,",3),!
