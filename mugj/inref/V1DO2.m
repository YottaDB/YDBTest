V1DO2	;DO COMMAND (LOCAL BRANCHING) -2-;KO-TS,V1DO,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0,VCORR="START"
	GOTO START
A	S V=V_"A " Q
	S V="A ERROR"
	QUIT
A1	S V=V_"A1 " Q
SET	S V=V_"SET " Q
START	;
	W !!,"V1DO2 : TEST OF DO COMMAND (LOCAL BRANCHING) -2-",!
236	W !,"I-236  label is an alpha followed by alpha and/or digit"
	S ITEM="I-236.1  label is an alpha",V=""
	DO A S VCOMP=V,VCORR="A " D EXAMINER
	;
	S ITEM="I-236.2  label is a different alpha",V=""
	D Q S VCOMP=V,VCORR="Q " D EXAMINER
	;
	S ITEM="I-236.3  label is a different alpha",V=""
	D Z S VCOMP=V,VCORR="Z " D EXAMINER
	;
	S ITEM="I-236.4  label is 2 alphas",V=""
	DO DO S VCOMP=V,VCORR="DO " D EXAMINER
	;
	S ITEM="I-236.5  label is another 2 alphas",V=""
	DO IF S VCOMP=V,VCORR="IF " D EXAMINER
	;
	S ITEM="I-236.6  label is 4 alphas",V=""
	D QUIT S VCOMP=V,VCORR="QUIT " D EXAMINER
	;
	S ITEM="I-236.7  label is 3 alphas",V=""
	DO SET S VCOMP=V,VCORR="SET " D EXAMINER
	;
	S ITEM="I-236.8  label is 8 alphas",V=""
	D ABCDEFGH S VCOMP=V,VCORR="ABCDEFGH " D EXAMINER
	;
	S ITEM="I-236.9  label is an alpha followed by combination of an alpha and a digit",V=""
	D A1 S VCOMP=V,VCORR="A1 " D EXAMINER
	;
	S ITEM="I-236.10  label is an alpha followed by combination of digits and an alpha",V=""
	D Z012A S VCOMP=V,VCORR="Z012A " D EXAMINER
	;
	S ITEM="I-236.11  label is an alpha followed by combination of alphas and digits",V=""
	D ZXY987A0 S VCOMP=V,VCORR="ZXY987A0 " D EXAMINER
	;
237	W !,"I-237  label is intlit"
	S ITEM="I-237.1  label is 0",V="" DO 0 S VCOMP=V,VCORR="0 " D EXAMINER
	S ITEM="I-237.2  label is 1",V="" D 1 S VCOMP=V,VCORR="1 " D EXAMINER
	S ITEM="I-237.3  label is 01",V="" D 01 S VCOMP=V,VCORR="01 " D EXAMINER
	S ITEM="I-237.4  label is 10",V=""
	D 10 S VCOMP=V,VCORR="10 " D EXAMINER
	S ITEM="I-237.5  label is 12",V="" D 12 S VCOMP=V,VCORR="12 " D EXAMINER
	S ITEM="I-237.6  label is 100",V="" D 100 S VCOMP=V,VCORR="100 " D EXAMINER
	S ITEM="I-237.7  label is 012",V="" D 012 S VCOMP=V,VCORR="012 " D EXAMINER
	S ITEM="I-237.8  label is 0012",V="" D 0012 S VCOMP=V,VCORR="0012 " D EXAMINER
	S ITEM="I-237.9  label is 92345678; 8 digits",V=""
	D 92345678 S VCOMP=V,VCORR="92345678 " D EXAMINER
	S ITEM="I-237.10  label is 00000000; 8 digits",V=""
	D 00000000 S VCOMP=V,VCORR="00000000 " D EXAMINER
	;
END	W !!,"END OF V1DO2",!
	S ROUTINE="V1DO2",TESTS=21,AUTO=21,VISUAL=0 D ^VREPORT
	K  Q
	;
Z	S V=V_"Z " Q
%	S V=V_"% " Q
%ABCDEFG	S V=V_"%ABCDEFG " Q
%0000000	S V=V_"%0000000 " Q
12	S V=V_"12 " Q
%A	S V=V_"%A " Q
100	S V=V_"100 " Q
%2345678	S V=V_"%2345678 " Q
%A1B2C3D	S V=V_"%A1B2C3D " Q
Q	S V=V_"Q " Q
%A1	S V=V_"%A1 " Q
DO	S V=V_"DO "
	QUIT
ABCDEFGH	S V=V_"ABCDEFGH " Q
0	S V=V_"0 " Q
1	S V=V_"1 " Q
01	S V=V_"01 " QUIT
%0A1B2C3	S V=V_"%0A1B2C3 " Q
IF	S V=V_"IF " Q
%0	S V=V_"%0 " Q
Z012A	S V=V_"Z012A " Q
%90	S V=V_"%90 " Q
0012	S V=V_"0012 " Q
10	S V=V_"10 " Q
012	S V=V_"012 " QUIT
00000000	S V=V_"00000000 " Q
ZXY987A0	S V=V_"ZXY987A0 "
	QUIT  ;
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
92345678	S V=V_"92345678 " Q
QUIT	S V=V_"QUIT " ;IMPLICIT QUIT
