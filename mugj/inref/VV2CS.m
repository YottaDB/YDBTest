VV2CS	;COMMAND SPACE;KO-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1984
	S PASS=0,FAIL=0
	W !!,"VV2CS: TEST OF COMMAND SPACES",!
1	W !,"II-1  cs between ls and comment"
	S ITEM="II-1",VCOMP=1
	;S VCOMP="ERROR"
	S VCORR="1" D EXAMINER
	;
2	W !,"II-2  cs between command and command"
	S ITEM="II-2"
	S VCOMP=1             S VCOMP=VCOMP_2                                                          S VCOMP=VCOMP_3
	S VCORR=123 D EXAMINER
	;
3	W !,"II-3  cs of IF command"
	S ITEM="II-3",VCOMP=""
	I 1         I           S VCOMP=VCOMP_4 S:0 VCOMP=VCOMP_1
	I                       S VCOMP=VCOMP_5
	S VCORR=45 D EXAMINER
	;
4	W !,"II-4  cs of ELSE command"
	S ITEM="II-4",VCOMP=""
	I .1    S VCOMP=VCOMP_"1"
	E      S VCOMP="ELSE-cs --ERROR"
	I 0    S VCOMP=VCOMP_" IF 0 "
	E      S VCOMP=VCOMP_5
	S VCORR="15" D EXAMINER
	;
5	W !,"II-5  cs of FOR - QUIT - DO command"
	S ITEM="II-5",VCOMP=""
	F I=6:1:8         Q:I=10       D:1 A:I>0      ;
	F I=9:1:15        QUIT:I=11       DO A       ;
	S VCORR="678910" D EXAMINER
	;
6	W !,"II-6  cs between ls and comment in XECUTE command"
	S ITEM="II-6",VCOMP=""
	S A="           ; S VCOMP=""ls-cs-comment in XECUTE -- ERROR """ X A
	S VCORR="" D EXAMINER
	;
7	W !,"II-7  cs between commands in XECUTE command"
	S ITEM="II-7",VCOMP=""
	S A="   S VCOMP=11               S VCOMP=VCOMP_12     ;COMMENT"   X A    ;
	S VCORR="1112" D EXAMINER
	;
8	W !,"II-8  cs between commands with indirection argument"
	S ITEM="II-8",VCOMP="",A="B",B=13,C="D=14",E="E1",E1=15
	S VCOMP=@A    S @C      S VCOMP=VCOMP_D,F=@E       SET VCOMP=VCOMP_F    ;
	S VCORR="131415" D EXAMINER
	;
END	W !!,"END OF VV2CS",!
	S ROUTINE="VV2CS",TESTS=8,AUTO=8,VISUAL=0 D ^VREPORT
	K    Q    ;
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
A	S VCOMP=VCOMP_I      Q     ;
