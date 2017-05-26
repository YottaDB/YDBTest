V1AC2	;$ASCII AND $CHAR FUNCTIONS -2-;YS-TS,V1AC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1AC2: TEST OF $ASCII FUNCTION",!
	W !,"$ASCII(expr)",!
8	W !,"I-8  expr is string literal, and $L(expr)=0  i.e. expr is empty string"
	S ITEM="I-8  ",VCOMP="" S VCOMP=$A(""),VCORR="-1" D EXAMINER
	;
9	W !,"I-9  expr is string literal, and $L(expr)=1"
	S ITEM="I-9  ",VCOMP=""
	S VCOMP=$ASCII(" ")_$A("!")_$A("""")_$A("#")_$A("$")_$A("%")_$A("&")_$A("'")
	S VCOMP=VCOMP_$A("(")_$A(")")_$A("*")_$A("+")_$A(",")_$A("-")_$A(".")
	S VCOMP=VCOMP_$A("/")_$A("0")_$A("1")_$A("2")_$A("3")_$A("4")_$A("5")_$A("6")
	S VCOMP=VCOMP_$A("7")_$A("8")_$A("9")_$A(":")_$A(";")_$A("<")_$A("=")_$A(">")_$A("?")_$A("@")
	S VCORR="323334353637383940414243444546474849505152535455565758596061626364"
	D EXAMINER
	;
10	W !,"I-10  expr is string literal, and $L(expr)>0"
	S ITEM="I-10  ",X="*|^=09876",VCOMP=$A(X),VCORR=42 D EXAMINER
	;
11	W !,"I-11  expr is numeric literal, and $L(expr)=1  i.e. expr is a digit"
	S ITEM="I-11  ",VCOMP=$A(02),VCORR=50 D EXAMINER
	;
12	W !,"I-12  expr is numeric literal, and $L(expr)>1,expr<0"
	S ITEM="I-12  " S VCOMP=$A(-0.30) S VCORR=45 D EXAMINER
	;
13	W !,"I-13  expr is numeric literal, and $L(expr)>1,expr<=0"
	S ITEM="I-13  ",VCOMP=$A(.00E3),VCORR=48 D EXAMINER
	;
14	W !,"I-14  expr is $CHAR corresponding to ASCII code 0-127"
	S ITEM="I-14.1  0-31",VCOMP="" F I=0:1:31 S VCOMP=VCOMP_$A($C(I))
	S VCORR="012345678910111213141516171819202122232425262728293031" D EXAMINER
	;
	S ITEM="I-14.2  32-94",VCOMP="" F I=32:1:94 S VCOMP=VCOMP_$A($C(I))
	S VCORR="323334353637383940414243444546474849505152535455565758596061626364656667686970717273747576777879808182838485868788899091929394" D EXAMINER
	;
	S ITEM="I-14.3  95-127",VCOMP="" F I=95:1:127 S VCOMP=VCOMP_$A($C(I))
	S VCORR="9596979899100101102103104105106107108109110111112113114115116117118119120121122123124125126127" D EXAMINER
	;
	S ITEM="I-14.4  expr is lvn",VCOMP="",X=1,Y=$C($A(X),$A(X,2))
	S VCOMP=$L(Y)_" "_Y S VCORR="1 1" D EXAMINER
	;
	W !!,"$A(expr1,intexpr2)",!
15	W !,"I-15  expr1 is string literal"
	S ITEM="I-15  ",VCOMP="" F I=1:1:30 S VCOMP=VCOMP_$A(">?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[",I)
	S VCORR="626364656667686970717273747576777879808182838485868788899091" D EXAMINER
	;
16	W !,"I-16  expr1 is non-integer numeric literal, and greater than zero"
	S ITEM="I-16  ",VCOMP=$A(034.95165E2,00.04000E+2),VCORR=53 D EXAMINER
	;
17	W !,"I-17  expr1 is non-integer numeric literal, and less than zero"
	S ITEM="I-17  ",VCOMP=$A(-00.000034567000E+008,6000E-3),VCORR=46 D EXAMINER
	;
18	W !,"I-18  expr1 is integer numeric literal, and greater than zero"
	S ITEM="I-18  ",VCOMP=$A(00000234650.0000,2+1),VCORR="52" D EXAMINER
	;
19	W !,"I-19  expr1 is integer numeric literal, and less than zero"
	S ITEM="I-19  ",VCOMP="" S VCOMP=$A(-0059.34E3,04) S VCORR=51 D EXAMINER
	;
20	;
21	W !,"I-20/21  intexpr2 is less than zero or greater than $L(expr1)"
	S ITEM="I-20/21.1  intexpr2 is less than zero",VCOMP="" S VCOMP=$A("Q",-2),VCORR="-1" D EXAMINER
	S ITEM="I-20/21.2  intexpr2 is greater than $L(expr1)",VCOMP=$A(1,2),VCORR="-1" D EXAMINER
	S ITEM="I-20/21.3  expr1 is strlit" S VCOMP="" F I=-3:1:8 S VCOMP=VCOMP_$A("\]^_",I)
	S VCORR="-1-1-1-192939495-1-1-1-1" D EXAMINER
	;
	S ITEM="I-20/21.4  expr1 is non-integer literal",VCOMP="" F I=-1:1:9 S VCOMP=VCOMP_$A(12345.6,I)
	S VCORR="-1-149505152534654-1-1" D EXAMINER
	;
END	W !!,"END OF V1AC2",!
	S ROUTINE="V1AC2",TESTS=19,AUTO=19,VISUAL=0 D ^VREPORT
	K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
