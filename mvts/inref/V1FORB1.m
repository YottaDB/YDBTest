V1FORB1 ;IW-YS-TS,VV1,MVTS V9.10;15/6/96;FOR COMMNAD -2.1-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"142---V1FORB1: FOR command -2.1-",!
 W !,"List of forparameter",!
355 W !,"I-355  Forparameter is expr"
 S ^ABSN="11759",^ITEM="I-355  Forparameter is expr",^NEXT="356^V1FORB1,V1FORB2^V1FORB,V1FORC^VV1" D ^V1PRESET
 S VCOMP="" FOR I=1,3,4,5.5,7,-1,"ABC",-2.3,50E-1 SET VCOMP=VCOMP_I_" "
 S VCOMP=VCOMP_I S ^VCOMP=VCOMP,^VCORR="1 3 4 5.5 7 -1 ABC -2.3 5 5" D ^VEXAMINE
 ;
356 W !,"I-356  Forparameter is numexpr1:numexpr2"
 S ^ABSN="11760",^ITEM="I-356  Forparameter is numexpr1:numexpr2",^NEXT="357^V1FORB1,V1FORB2^V1FORB,V1FORC^VV1" D ^V1PRESET
 S VCOMP="" F I=.1:-.02,1:2 S VCOMP=VCOMP_I_" " I I<0 Q
 S VCOMP=VCOMP_I S ^VCOMP=VCOMP,^VCORR=".1 .08 .06 .04 .02 0 -.02 -.02" D ^VEXAMINE
 ;
357 W !,"I-357  Forparameter is numexpr1:numexpr2:numexpr3"
 S ^ABSN="11761",^ITEM="I-357  Forparameter is numexpr1:numexpr2:numexpr3",^NEXT="358^V1FORB1,V1FORB2^V1FORB,V1FORC^VV1" D ^V1PRESET
 S ^VCOMP="" F I=1.5:0.1:2.1,1:-0.3:-1 S ^VCOMP=^VCOMP_I_" "
 S ^VCOMP=^VCOMP_I,^VCORR="1.5 1.6 1.7 1.8 1.9 2 2.1 1 .7 .4 .1 -.2 -.5 -.8 -.8" D ^VEXAMINE
 ;
358 W !,"I-358  Forparameter is mixture of the three above"
 S ^ABSN="11762",^ITEM="I-358  Forparameter is mixture of the three above",^NEXT="359^V1FORB1,V1FORB2^V1FORB,V1FORC^VV1" D ^V1PRESET
 S ^VCOMP="" F I=-10.1,3*I,"ABC",2:-0.5:1,"1E0",5:2.5 S ^VCOMP=^VCOMP_I_" " I I>9 Q
 S ^VCOMP=^VCOMP_I,^VCORR="-10.1 -30.3 ABC 2 1.5 1 1E0 5 7.5 10 10" D ^VEXAMINE
 ;
359 W !!,"FOR lvn=forparameter",!
 W !,"I-359  Value of lvn in execution of FOR scope"
 S ^ABSN="11763",^ITEM="I-359  Value of lvn in execution of FOR scope",^NEXT="360^V1FORB1,V1FORB2^V1FORB,V1FORC^VV1" D ^V1PRESET
 S ^VCOMP="" K X F I=-2:1:3 S X(I)=I_" ",^VCOMP=^VCOMP_X(I)
 S ^VCOMP=^VCOMP_I,^VCORR="-2 -1 0 1 2 3 3" D ^VEXAMINE
 ;
360 W !,"I-360  lvn has subscript"
3601 S ^ABSN="11764",^ITEM="I-360.1  3 subscripts",^NEXT="3602^V1FORB1,V1FORB2^V1FORB,V1FORC^VV1" D ^V1PRESET
 K J(1,2,3) S ^VCOMP="" F J(1,2,3)=1:1:3 S ^VCOMP=^VCOMP_J(1,2,3)_" "
 S ^VCOMP=^VCOMP_J(1,2,3),^VCORR="1 2 3 3" D ^VEXAMINE
 ;
3602 S ^ABSN="11765",^ITEM="I-360.2  1 subscript",^NEXT="3603^V1FORB1,V1FORB2^V1FORB,V1FORC^VV1" D ^V1PRESET
 S ^VCOMP="" S I=1,J(3)="A",J(5)="B",J(7)="C" F J(I)=1:1:3 S I=I+2,^VCOMP=^VCOMP_J(I)_" "
 S ^VCOMP=^VCOMP_J(1),^VCORR="A B C 3" D ^VEXAMINE
 ;
3603 S ^ABSN="11766",^ITEM="I-360.3  Subscript contains binary operator",^NEXT="V1FORB2^V1FORB,V1FORC^VV1" D ^V1PRESET
 S VCOMP="",A=1,B=2,C=3,D=4,E=5
 F A(A+B+C,$A(A),D_E)=1:1:3 S A=A+1 S VCOMP=VCOMP_A_" "
 S VCOMP=VCOMP_A(6,49,45),^VCOMP=VCOMP,^VCORR="2 3 4 3" D ^VEXAMINE
 ;
END W !!,"End of 142---V1FORB1",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
