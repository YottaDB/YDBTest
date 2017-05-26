V1DO1	;DO COMMAND (LOCAL BRANCHING) -1-;KO-TS,V1DO,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0,VCORR="START"
	GOTO START
A	S V=V_"A " Q
	S V="A ERROR"
	QUIT
A1	S V=V_"A1 " Q
SET	S V=V_"SET " Q
START	;
	W !!,"V1DO1 : TEST OF DO COMMAND (LOCAL BRANCHING) -1-"
	W !!,"DO label",!
238	;
239	W !,"I-238/239  label is a ""%"" followed by alpha and/or digit"
	S ITEM="I-238/239.1  label is a %",V=""
	DO % S VCOMP=V,VCORR="% "
	D EXAMINER
	;
	S ITEM="I-238/239.2  label is a % followed by an alpha",V=""
	DO %A S VCOMP=V,VCORR="%A " D EXAMINER
	;
	S ITEM="I-238/239.3  label is a % followed by 7 alphas",V=""
	D %ABCDEFG
	S VCOMP=V,VCORR="%ABCDEFG " D EXAMINER
	;
	S ITEM="I-238/239.4  label is a % followed by a digit",V=""
	DO %0 S VCOMP=V,VCORR="%0 " D EXAMINER
	;
	S ITEM="I-238/239.5  label is a % followed by 2 digits",V=""
	D %90
	S VCOMP=V,VCORR="%90 " D EXAMINER
	;
	S ITEM="I-238/239.6  label is a % followed by 7 digits",V=""
	D %0000000 S VCOMP=V,VCORR="%0000000 " D EXAMINER
	;
	S ITEM="I-238/239.7  label is a % followed by another 7 digits",V=""
	DO %2345678 SET VCOMP=V,VCORR="%2345678 " D EXAMINER
	;
	S ITEM="I-238/239.8  label is a % followed by combination of an alpha and a digit",V=""
	DO %A1 S VCOMP=V,VCORR="%A1 " D EXAMINER
	;
	S ITEM="I-238/239.9  label is a % followed by combination of alphas and digits",V=""
	D %A1B2C3D S VCOMP=V,VCORR="%A1B2C3D " D EXAMINER
	;
	S ITEM="I-238/239.10  label is a % followed by combination of digits and alphas",V=""
	D %0A1B2C3 S VCOMP=V,VCORR="%0A1B2C3 " D EXAMINER
	;
END	W !!,"END OF V1DO1",!
	S ROUTINE="V1DO1",TESTS=10,AUTO=10,VISUAL=0 D ^VREPORT
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
