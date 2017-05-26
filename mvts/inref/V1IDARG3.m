V1IDARG3 ;IW-KO-MM-YS-TS,V1IDARG,MVTS V9.10;15/6/96;ARGUMENT LEVEL INDIRECTION -3-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"155---V1IDARG3: Argument level indirection -3-",!
 ;
431 W !,"I-431  Value of indirection contains operators"
 S ^ABSN="11862",^ITEM="I-431  Value of indirection contains operators",^NEXT="432^V1IDARG3,V1IDARG4^V1IDARG,V1XECA^VV1" D ^V1PRESET
 K  S VCOMP="" S INC="INCREMEN",INCREMEN="DEC"
 S K="@(""I""_""N""_""C"")"
 K @K
 S VCOMP=$D(INC)_" "_$D(INCREMEN)_INCREMEN
 S ^VCOMP=VCOMP,^VCORR="0 1DEC" D ^VEXAMINE
 ;
432 W !,"I-432  Value of indirection is function"
 S ^ABSN="11863",^ITEM="I-432  Value of indirection is function",^NEXT="433^V1IDARG3,V1IDARG4^V1IDARG,V1XECA^VV1" D ^V1PRESET
 K  S ^VCOMP=""
 S A=1,B=2,C(1,2)=3,D=4,^V1A(1)=0
 S Z="@$P(""A|B|C|D|^V1A"",""|"",I)"
 F I=1:1:5 K @Z S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_$D(D)_$D(^V1A)_" "
 S ^VCORR="0110110 0010110 000110 000010 00000 " D ^VEXAMINE
 ;
433 W !,"I-433  Value of indirection is lvn"
 S ^ABSN="11864",^ITEM="I-433  Value of indirection is lvn",^NEXT="434^V1IDARG3,V1IDARG4^V1IDARG,V1XECA^VV1" D ^V1PRESET
 K  S ^VCOMP=""
 S A(1,1)=11 F I=1:1:5 S B(I)=I,C(1,I)=I,C(2,I)=I,II="I"
 S %A0="A,B(@II),C(1,I)"
 S ^VCOMP=^VCOMP_$D(A) F I=1:1:5 S ^VCOMP=^VCOMP_$D(B(I))_$D(C(1,I))_$D(C(2,I))_" "
 S ^VCOMP=^VCOMP_"/" F I=1:1:4 K @%A0
 S ^VCOMP=^VCOMP_$D(A) F I=1:1:5 S ^VCOMP=^VCOMP_$D(B(I))_$D(C(1,I))_$D(C(2,I))_" "
 S ^VCORR="10111 111 111 111 111 /0001 001 001 001 111 " D ^VEXAMINE
 ;
434 W !,"I-434  Value of indirection is gvn"
 S ^ABSN="11865",^ITEM="I-434  Value of indirection is gvn",^NEXT="854^V1IDARG3,V1IDARG4^V1IDARG,V1XECA^VV1" D ^V1PRESET
 K  S VCOMP="" K ^V1A
 S ^V1A(1)=1,^V1A(2,2)=22,^V1A(2,2,2)=222,^V1A(1,1)=11,^V1A(3)=3,^V1A(2)=2
 S A="^V1A(A1),^(@A(1),A2)",A1=1.0,A2=02,A(1)="A(2)",A(2)=02
 S VCOMP=$D(^V1A(1))_" "_$D(^V1A(2))_" "_$D(^V1A(3))_" "_$D(^V1A(2,2))_" "
 S VCOMP=VCOMP_$D(^V1A(2,2,2))_" "_$D(^V1A(1,1))_"/"
 K @A
 S VCOMP=VCOMP_$D(^V1A(1))_" "_$D(^(2))_" "_$D(^(3))_" "_$D(^V1A(2,2))_" "
 S VCOMP=VCOMP_$D(^(2,2))_" "_$D(^V1A(1,1))
 S ^VCOMP=VCOMP,^VCORR="11 11 1 11 1 1/0 1 1 0 0 0" D ^VEXAMINE
 ;
854 W !,"I-854  Transition of $DATA from 11 to 1 after KILLing the only descendent"
 ;--(12/2/93 add. in V8.02 for ANSI 1990 Std. KILL command)
 S ^ABSN="12155",^ITEM="I-854  Transition of $DATA from 11 to 1 after KILLing the only descendent",^NEXT="V1IDARG4^V1IDARG,V1XECA^VV1" D ^V1PRESET
 K  S VCOMP="" K ^V1A
 S ^V1A(1)=1,^V1A(2,2,2)=222,^V1A(1,1)=11,^V1A(3)=3,^V1A(2)=2
 S A="^V1A(A1,@A(1)-1),^V1A(@A(1),^V1A(A2),3-A1)",A1=1.0,A2=02,A(1)="A(2)",A(2)=02
 S VCOMP=$D(^V1A(1))_" "_$D(^V1A(2))_" "_$D(^V1A(3))_" "_$D(^V1A(2,2))_" "
 S VCOMP=VCOMP_$D(^V1A(2,2,2))_" "_$D(^V1A(1,1))_"/"
 K @A
 S VCOMP=VCOMP_$D(^V1A(1))_" "_$D(^(2))_" "_$D(^(3))_" "_$D(^V1A(2,2))_" "
 S VCOMP=VCOMP_$D(^(2,2))_" "_$D(^V1A(1,1))
 S ^VCOMP=VCOMP,^VCORR="11 11 1 10 1 1/1 1 1 0 0 0" D ^VEXAMINE
 ;
END W !!,"End of 155---V1IDARG3",!
 K  K ^V1A Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
