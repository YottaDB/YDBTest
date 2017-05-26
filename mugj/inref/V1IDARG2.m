V1IDARG2	;ARGUMENT LEVEL INDIRECTION -2-;KO-MM-YS-TS,V1IDARG,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1IDARG2: TEST OF ARGUMENT LEVEL INDIRECTION -2-"
KILL	W !!,"KILL command",!
426	W !,"I-426  indirection of killargument" K ^V1A,^V1B
	S ITEM="I-426  ",VCOMP=""
	S (A,B,C,D,E,F)=1,A(1)=1,A(1,1)=11,^V1A(1)="^V1A",^V1B(9)=9
	S %1="D",%2="E,F" K @%1 K @%2 K @^V1A(1)
	S VCOMP=$D(A)_" "_$D(B)_" "_$D(C)_" "_$D(D)_" "_$D(E)_" "_$D(F)_" "_$D(^V1A)_" "_$D(^V1B)
	S VCORR="11 1 1 0 0 0 0 10" D EXAMINER
	;
427	W !,"I-427  indirection of killargument list" K (PASS,FAIL) K ^V1A,^V1B
	S ITEM="I-427  ",VCOMP=""
	S (A,B,C,D,E,F)=1,A(1)=1,A(1,1)=11,^V1A(1)="^V1A",^V1B(9)=9,B(7)=0
	S %1="D",%2="B,E,F" K @%1,@%2,@(%1_","_%2),@^V1A(1)
	S VCOMP=$D(A)_" "_$D(B)_" "_$D(C)_" "_$D(D)_" "_$D(E)_" "_$D(F)_" "_$D(^V1A)_" "_$D(^V1B)
	S VCORR="11 0 1 0 0 0 0 10" D EXAMINER
	;
428	W !,"I-428  subscript is denoted by name level indirection"
	S ITEM="I-428  ",VCOMP="" K A
	S A=1,A(1)=1,A(1,1)=11,B="A(@C,@C)",C="D",D=1 K @B
	S VCOMP=$D(A)_" "_$D(A(1))_" "_$D(A(1,1))_"+"
	S ^V1A=1,^V1A(10)=10,^(10,30,10)=1000,^V1B(10)=30
	S ^V1B(1)="^V1A(@^V1B(2),@^V1B(3))",^(2)="^V1A(10)",^(3)="^(10)",^(4)="^V1A"
	K @^V1B(@^V1B(4))
	S VCOMP=VCOMP_$D(^V1A)_" "_$D(^V1A(10))_" "_$D(^V1A(10,30,10))_" "_$D(^V1A(20))
	S VCORR="11 1 0+11 1 0 0" D EXAMINER
	;
429	W !,"I-429  indirection of exclusive KILL"
	S ITEM="I-429  ",VCOMP="" K ^V1A,^V1B
	S (A,B,C,D,E,F)=1,A(1)=1,A(1,1)=11,^V1A(1)="^V1A",^V1B(9)=9,B(7)=0
	S A="(B,PASS,FAIL,ITEM),D,E" K @A
	S VCOMP=$D(A)_" "_$D(B)_" "_$D(C)_" "_$D(D)_" "_$D(E)_" "_$D(F)_" "_$D(^V1A)_" "_$D(^V1B)
	S VCORR="0 11 0 0 0 0 10 10" D EXAMINER
	;
430	W !,"I-430  Value of indirection contains indirection" K (PASS,FAIL)
	S ITEM="I-430  "
	S (A,B,B(1),B(1,1),B(2),B(2,2,2),B(3,3),C)=1
	S Z="@A(1),@B(1)",A(1)="A(2)",B(1)="B(2),B(3)"
	K @Z,Z
	S VCOMP=$D(A)_" "_$D(B)_" "_$D(B(1))_" "_$D(B(1,1))_" "
	S VCOMP=VCOMP_$D(B(2))_" "_$D(B(2,2,2))_" "_$D(B(3,3))_" "_$D(C)
	S VCORR="11 11 11 1 0 0 0 1" D EXAMINER
	;
431	W !,"I-431  Value of indirection contains operators"
	S ITEM="I-431  ",VCOMP=""
	S INC="INCREMEN",INCREMEN="DEC"
	S K="@(""I""_""N""_""C"")"
	K @K
	S VCOMP=$D(INC)_" "_$D(INCREMEN)_INCREMEN
	S VCORR="0 1DEC" D EXAMINER
	;
432	W !,"I-432  Value of indirection is function" K (PASS,FAIL)
	S ITEM="I-432  ",VCOMP=""
	S A=1,B=2,C(1,2)=3,D=4,^V1A(1)=0
	S Z="@$P(""A|B|C|D|^V1A"",""|"",I)"
	F I=1:1:5 K @Z S VCOMP=VCOMP_$D(A)_$D(B)_$D(C)_$D(D)_$D(^V1A)_" "
	S VCORR="0110110 0010110 000110 000010 00000 " D EXAMINER
	;
433	W !,"I-433  Value of indirection is lvn"
	S ITEM="I-433  ",VCOMP=""
	S A(1,1)=11 F I=1:1:5 S B(I)=I,C(1,I)=I,C(2,I)=I,II="I"
	S %A0="A,B(@II),C(1,I)"
	S VCOMP=VCOMP_$D(A) F I=1:1:5 S VCOMP=VCOMP_$D(B(I))_$D(C(1,I))_$D(C(2,I))_" "
	S VCOMP=VCOMP_"/" F I=1:1:4 K @%A0
	S VCOMP=VCOMP_$D(A) F I=1:1:5 S VCOMP=VCOMP_$D(B(I))_$D(C(1,I))_$D(C(2,I))_" "
	S VCORR="10111 111 111 111 111 /0001 001 001 001 111 " D EXAMINER
	;
434	W !,"I-434  Value of indirection is gvn"
	S ITEM="I-434  ",VCOMP="" K ^V1A
	S ^V1A(1)=1,^V1A(2,2)=22,^V1A(2,2,2)=222,^V1A(1,1)=11,^V1A(3)=3,^V1A(2)=2
	S A="^V1A(A1),^(@A(1),A2)",A1=1.0,A2=02,A(1)="A(2)",A(2)=02
	S VCOMP=$D(^V1A(1))_" "_$D(^V1A(2))_" "_$D(^V1A(3))_" "_$D(^V1A(2,2))_" "
	S VCOMP=VCOMP_$D(^V1A(2,2,2))_" "_$D(^V1A(1,1))_"/"
	K @A
	S VCOMP=VCOMP_$D(^V1A(1))_" "_$D(^(2))_" "_$D(^(3))_" "_$D(^V1A(2,2))_" "
	S VCOMP=VCOMP_$D(^(2,2))_" "_$D(^V1A(1,1))
	S VCORR="11 11 1 11 1 1/0 1 1 0 0 0" D EXAMINER
	;
END	W !!,"END OF V1IDARG2",!
	S ROUTINE="V1IDARG2",TESTS=9,AUTO=9,VISUAL=0 D ^VREPORT
	K  K ^V1A,^V1B Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
