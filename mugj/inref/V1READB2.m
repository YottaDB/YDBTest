V1READB2	;READ AND $TEST AND READ LEVEL INDIRECTION -2-;KO-TS,V1READB,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1READB2: TEST READ AND $TEST AND READ LEVEL INDIRECTION -2-",!
	W !!,"READ LEVEL INDIRECTION"
767	W !!,"I-767  indirection of readargument except format"
	S ITEM="I-767  " K A
	S D="""   R A   ; TYPE 'MUMPS' AND <ENTRY> KEY > "",A"
	R !!,@D
	S VCOMP=$D(A)_" "_A_" "_(A="MUMPS"),VCORR="1 MUMPS 1" D EXAMINER
	;
768	W !!,"I-768  indirection of readargument list" K (PASS,FAIL)
	S ITEM="I-768  "
	S D="""   R A    ; TYPE 'YES' AND <ENTRY> KEY > "",A"
	S E="!,""   R A(1) ; TYPE 'yes' AND <ENTRY> KEY > "",A(1)"
	R !!,@D,@E
	S VCOMP=$D(A)_" "_A_" "_(A="YES")
	S VCOMP=VCOMP_"/"_$D(A(1))_" "_A(1)_" "_(A(1)="yes")
	S VCORR="11 YES 1/1 yes 1" D EXAMINER
	;
769	W !!,"I-769  indirection of format control parameters"
	S ITEM="I-769  ",VCOMP=""
	W !,"   TYPE SAME STRINGS OF NEXT LINE WITH SPACES"
	S F="!?3,""ABC"",!"
	R @F,VCOMP
	S VCORR="   ABC" D EXAMINER
	;
770	W !!,"I-770  2 levels of readargument indirection"
	S ITEM="I-770  "
	S A="!!,""   R A(2)    ; TYPE 'NO' AND <ENTRY> KEY > "",@A(1)",A(1)="A(2)"
	R @A S VCOMP=A(2)_(A(2)="NO"),VCORR="NO1" D EXAMINER
	;
771	W !!,"I-771  3 levels of readargument indirection"
	S ITEM="I-771  "
	S B="!!,""   R B    ;"",@B(1)",B(1)=""" TYPE 'no' AND "",@B(2)",B(2)="""<ENTRY> KEY > "",B"
	R @B
	S VCOMP=B_(B="no"),VCORR="no1" D EXAMINER
	;
772	W !!,"I-772  Value of indirection contains indirection"
	S ITEM="I-772  "
	S A(1)="@@A(2)",A(2)="A(3)",A(3)="A(@B(1))"
	S B(1)="@B(2)",B(2)="B(3)",B(3)=.4E1
	S A="!!,""   R A(3)    ; TYPE 'BOOK' AND <ENTRY> KEY > "",@A(1)"
	R @A S VCOMP=A(4),VCORR="BOOK" D EXAMINER
	;
773	W !!,"I-773  Value of indirection contains operators"
	S ITEM="I-773  "
	S A="!!,""   R AB:100    ; TYPE 'ABC' AND <ENTRY> KEY WITHIN 100 SECONDS> "",@(A(1)_B(2)_"":100"")"
	S A(1)="A",B(2)="B"
	R @A S VCOMP=AB_$T,VCORR="ABC1" D EXAMINER
	;
774	W !!,"I-774  Value of indirection is function"
	S ITEM="I-774  "
	S A="""   R A(3)    ; TYPE 'Language' AND <ENTRY> KEY > """,I=3
	R !!,@A,@$P("A(1)/A(2)/A(3)/A(4)","/",I) S VCOMP=A(3)
	S VCORR="Language" D EXAMINER
	;
775	W !!,"I-775  Value of indirection is lvn"
	S ITEM="I-775  "
	S A="!!,""   R A(12)    ; TYPE 'OK' AND <ENTRY> KEY > "",@A(@B)",A(2)="A(12)",B="B(1)",B(1)=2
	R @A S VCOMP=A(12),VCORR="OK" D EXAMINER
	;
END	W !!,"END OF V1READB2",!
	S ROUTINE="V1READB2",TESTS=9,AUTO=9,VISUAL=0 D ^VREPORT
	K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
