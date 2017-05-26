V1DO3	;DO COMMAND (LOCAL BRANCHING) -3-;KO-TS,V1DO,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1DO3 : TEST OF DO COMMAND (LOCAL BRANCHING) -3-"
	W !!,"DO label+intexpr",!
	G 240
	S V=V_"AAA " Q  ;V1DO3+6
	S V=V_"BBB " Q
	S V=V_"CCC " Q
00000000	S V=V_"00000000 " Q
240	W !,"I-240  intexpr is positive integer"
	S ITEM="I-240  ",V=""
	DO 1+1
	S VCOMP=V,VCORR="01 " D EXAMINER
	;
241	W !,"I-241  intexpr is zero"
	S ITEM="I-241  ",V=""
	D 00000000+0 S VCOMP=V,VCORR="00000000 " D EXAMINER
	;
242	W !,"I-242  intexpr is non-integer numlit"
	S ITEM="I-242  ",V=""
	D 012+01.99999
	S VCOMP=V,VCORR="ZXY987A0 " D EXAMINER
	;
243	W !,"I-243  intexpr is function"
	S ITEM="I-243  ",V=""
	D %2345678+$L(0.23000)
	S VCOMP=V,VCORR="%A1 " D EXAMINER
	;
244	W !,"I-244  intexpr is gvn"
	S ITEM="I-244  ",V=""
	S ^V1DO3=7 D V1DO3+^V1DO3
	S VCOMP=V,VCORR="BBB " D EXAMINER
	;
245	W !,"I-245  intexpr contains binary operator"
	S ITEM="I-245.1  + operator",V=""
	D 12+-15+"17A"
	S VCOMP=V,VCORR="100 " D EXAMINER
	;
	S ITEM="I-245.2  _ operator",V=""
	DO IF+("0"_2)
	S VCOMP=V,VCORR="Z012A " D EXAMINER
	;
	S ITEM="I-245.3  combination binary operators",V=""
	S A=1 DO V1DO3+A+A*2+A+A+A+A+A+A+A+A+A+A-A-A-A-"1A"=10+8-1
	S VCOMP=V,VCORR="CCC " D EXAMINER
	;
246	W !,"I-246  intexpr contains unary operator"
	S ITEM="I-246  ",V=""
	D 12+++-"-.037E+2"
	S VCOMP=V,VCORR="IF " D EXAMINER
	;
247	W !,"I-247  intexpr contains gvn as expratom"
	S ITEM="I-247  ",V=""
	S ^V1A(2)=9765,^V1A(3)=9733
	D %0A1B2C3+^V1A(2)-^(3)/10
	S VCOMP=V,VCORR="10 " D EXAMINER
	;
832	W !,"I-832  argument list label without postcondition"
	S ITEM="I-832  ",V=""
	D %,%0A1B2C3,DO,012
	S VCOMP=V,VCORR="% %0A1B2C3 DO 012 " D EXAMINER
	;
833	W !,"I-833  argument list label+intexpr without postcondition"
	S ITEM="I-833  ",V=""
	S ^V1A(2)=9765,^V1A(3)=9733
	D %0A1B2C3+^V1A(2)-^(3)/10,%2345678+$L(0.23000),Z,1+1
	S VCOMP=V,VCORR="10 %A1 Z 01 " D EXAMINER
	;
END	W !!,"END OF V1DO3",!
	S ROUTINE="V1DO3",TESTS=12,AUTO=12,VISUAL=0 D ^VREPORT
	K  K ^V1DO3,^V1A Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
	;
012	S V=V_"012 " QUIT
	S V=V_"ZXY987A0 " Q
Z	S V=V_"Z " Q
%	S V=V_"% " Q
%2345678	S V=V_"%2345678 " Q
	S V=V_"%A1B2C3D " Q
	S V=V_"Q " Q
	S V=V_"%A1 " Q
DO	S V=V_"DO "
	QUIT
12	S V=V_"12 " Q
	S V=V_"%A " Q
	S V=V_"100 " Q
IF	S V=V_"IF " Q
	S V=V_"%0 " Q
	S V=V_"Z012A " Q
ABCDEFGH	S V=V_"ABCDEFGH " Q
0	S V=V_"0 " Q
	QUIT
1	S V=V_"1 " Q
	S V=V_"01 " QUIT
%0A1B2C3	S V=V_"%0A1B2C3 " Q
	S V=V_"%90 " Q
	S V=V_"0012 " Q
	S V=V_"10 " Q
