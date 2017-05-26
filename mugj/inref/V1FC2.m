V1FC2	;FORMAT CONTROL CHARACTERS -2-;YS-TS,V1FC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	I $Y>50 W #
	W !!,"V1FC2: TEST FORMAT CHARACTERS !,?,# -2-"
257	I $Y>50 W #
	W !!!,"I-257  intexpr is non-integer numeric literal  (visual)"
	S ITEM="I-257  "
	W !,"       following three lines should be identical"
	W !,"          1         2         3         4         5         6"
	W !,?10.0,1,?20.1,2,?30.4,3,?40.550,4,?50.9,5,?60.99999,6
	W !,"  ",?10.00,"1",?2.0E1,1+1,?305E-1,"3",?409E-01
	W "4",?000050.19,"5",?0060.990000,"6"
	;
258	I $Y>50 W #
	W !!!,"I-258  intexpr contains binary operator  (visual)"
	S ITEM="I-258  "
	W !,"       following two lines should be identical"
	W !,"-12345    -12345    -12345    -12345    -12345    -12345    -12345"
	W !?-3,-12345,?10.9,-12345,?1='0+19,-12345,?"30A",-12345,?4E1,-12345
	W ?1=1>0*50,-12345,?-40+"100",-12345
	;
259	I $Y>50 W #
	W !!!,"I-259  intexpr contains unary operator  (visual)"
	S ITEM="I-259  "
	W !,"       following two lines should be identical"
	W !,"          A         B         C         D         E         F"
	W !?+10,"A",?++"20","B",?+"30ABC","C",?-"-40QWE","D",?"5E1AKLS"
	W "E",?--"6000E-2 1234","F"
	;
260	I $Y>50 W #
	W !!!,"I-260  intexpr is function  (visual)"
	S ITEM="I-260  "
	W !,"       following two lines should be identical"
	W !,"ABCDEFGH  ABCDEFGH  ABCDEFGH  ABCDEFGH  ABCDEFGH  ABCDEFGH  ABCDEFGH"
	W !,"ABCDEFGH",?$E(20301040,5,6),"ABCDEFGH",?2_0,"ABCDEFGH"
	W ?$P("10^20^30^40","^",3),"ABCDEFGH",?$F("ABCDEF","C")_0
	W "ABCDEFGH",?50,"ABCDEFGH",?$A("<"),"ABCDEFGH"
	;
261	I $Y>50 W #
	W !!!,"I-261  intexpr is variable name  (visual)"
	S ITEM="I-261  "
	W !,"       following two lines should be identical"
	W !,"BBBBBBBB  BBBBBBBB  BBBBBBBB  BBBBBBBB  BBBBBBBB  BBBBBBBB  BBBBBBBB"
	S A="#",B="BBBBBBBB",C=10,D=20.5,E="30",A(4)=40
	W !,?A,B,?C,B,?D,B,?E,B,?A(4),B,?A(4)+10,B,?A+A(4)+D,B
	;
262	I $Y>50 W #
	W !!!,"I-262  intexpr is greater than $X  (visual)"
	S ITEM="I-262  "
	W !,"       following two lines should be identical"
	W !,"ABC       ABC       ABC       ABC       ABC       ABC       ABC"
	W !,"ABC       AB",?10,"C       ABC       A",?20,"BC",?30,"       A",?40,"BC",?50,"ABC",?60,"ABC"
	;
END	W !!!,"END OF V1FC2",!
	S ROUTINE="V1FC2",TESTS=6,AUTO=0,VISUAL=6 D ^VREPORT
	K  Q
