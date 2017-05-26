V1PRSET	;-PR- SET, KILL AND UNSUBSCRIPTED LOCAL VARIABLE;YS-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	; changed all occurences (4) of "three" to "two"
	W !!,"V1PRSET: PRELIMINARY TEST OF SET AND KILL COMMAND AND UNSUBSCRIPTED LOCAL VAR",! W:$Y>55 #
734	W !,"I-734  SET local variables without subscript  (visual)"
	W !,"       following two lines should be identical"
	W !,"1A"
	S A=1 W !,A
	S X="A" W X
	W:$Y>55 #
	;
735	W !!,"I-735  setargument list  (visual)"
	W !,"       following two lines should be identical"
	W !,"234BCD",!
	S A=2,B=3,C=4 W A,B,C
	S Y="B",Z="C",V="D" W Y,Z,V
	W:$Y>55 #
	;
736	W !!,"I-736  reassignment  (visual)"
	W !,"       following two lines should be identical"
	S W=A,A=B,B=C,C=X,X=Y,Y=Z,Z=V,V=W
	W !,"34ABCD22"
	W !,A,B,C,X,Y,Z,V,W
	W:$Y>55 #
	;
737	W !!,"I-737  KILL local variables all  (visual)"
	W !,"       following two lines should be identical"
	W !,"KILL LOCAL VARIABLES ALL IS ACCEPTED"
KILL	KILL  W !,"KILL LOCAL VARIABLES ALL IS ACCEPTED"
	W:$Y>55 #
	;
END	W !!,"END OF V1PRSET",! W:$Y>55 #
	S ROUTINE="V1PRSET",TESTS=4,AUTO=0,VISUAL=4 D ^VREPORT
	K  Q
