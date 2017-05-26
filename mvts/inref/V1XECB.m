V1XECB ;IW-YS-TS,VV1,MVTS V9.10;15/6/96;XECUTE COMMAND -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"161---V1XECB: XECUTE command -2-",!
816 W !,"I-816  DO in 2 nesting levels of XECUTE"
 S ^ABSN="11914",^ITEM="I-816  DO in 2 nesting levels of XECUTE",^NEXT="817^V1XECB,V1SEQ^VV1" D ^V1PRESET
 S VCOMP=""
 X "S VCOMP=1 X ""S VCOMP=VCOMP_2 D F S VCOMP=VCOMP_4"" S VCOMP=VCOMP_5","S VCOMP=VCOMP_6"
 S ^VCOMP=VCOMP,^VCORR="123456" D ^VEXAMINE
 ;
817 W !,"I-817  GOTO in 2 nesting levels of XECUTE"
 S ^ABSN="11915",^ITEM="I-817  GOTO in 2 nesting levels of XECUTE",^NEXT="818^V1XECB,V1SEQ^VV1" D ^V1PRESET
 S VCOMP="" X "S VCOMP=7 X ""S VCOMP=VCOMP_8 G G S VCOMP=VCOMP_""""ERROR 1 """""" S VCOMP=VCOMP_10","S VCOMP=VCOMP_11"
 S ^VCOMP=VCOMP,^VCORR="7891011" D ^VEXAMINE
 ;
818 W !,"I-818  QUIT in 2 nesting levels of XECUTE"
 S ^ABSN="11916",^ITEM="I-818  QUIT in 2 nesting levels of XECUTE",^NEXT="819^V1XECB,V1SEQ^VV1" D ^V1PRESET
 S VCOMP=""
 X "S VCOMP=12 X ""S VCOMP=VCOMP_13 Q  S VCOMP=VCOMP_""""ERROR 2 """""" S VCOMP=VCOMP_14","S VCOMP=VCOMP_15"
 S ^VCOMP=VCOMP,^VCORR="12131415" D ^VEXAMINE
 ;
819 W !,"I-819  FOR in 2 nesting levels of XECUTE"
8191 S ^ABSN="11917",^ITEM="I-819.1  Without postcondition",^NEXT="8192^V1XECB,V1SEQ^VV1" D ^V1PRESET
 S V="" X "S V=1 X ""F I=2:1:4 S V=V_I Q:I>2"" S V=V_4","S V=V_5"
 X "S V=V_6 X ""F I=7:1:9 D H Q:I>7"" S V=V_9","S V=V_10"
 X "S V=V_11 X ""F I=12:1:14 G I Q:I>12"" S V=V_13","S V=V_14"
 X "S V=V_15 X ""F I=16:1:17 D J G:I>16 L"" S V=V_19","S V=V_20"
 S ^VCOMP=V,^VCORR="1234567891011121314151617181920" D ^VEXAMINE
 ;
8192 S ^ABSN="11918",^ITEM="I-819.2  With postcondition",^NEXT="820^V1XECB,V1SEQ^VV1" D ^V1PRESET
 S V=""
 X:0 "S V=V_"" ERROR """:1
 X:1 "S V=V_1 X ""F I=2:1:4 S V=V_I Q:I>2"" S V=V_4 Q  S V=V_""ERROR""","S V=V_5"
 X "S V=V_6 X ""F I=7:1 S V=V_I Q:I>99"":0,""S V=V_7"":1 S V=V_8","S V=V_9"
 K P,X,Q,R,S S P="S X=10 S V=V_X",Q="D M" X P,Q:X=10,R:X=10,S
 S ^VCOMP=V,^VCORR="123456789101112" D ^VEXAMINE
 ;
820 W !,"I-820  XECUTE a variable whose data contains KILLing of"
 W !,"       that variable itself"
 S ^ABSN="11919",^ITEM="I-820  KILL of the variable itself",^NEXT="821^V1XECB,V1SEQ^VV1" D ^V1PRESET
 S ^VCOMP="",A="S ^VCOMP=$D(A) K A S ^VCOMP=^VCOMP_$D(A)"
 X A S ^VCOMP=^VCOMP_$D(A) S ^VCORR="100" D ^VEXAMINE
 ;
821 W !,"I-821  XECUTE a variable whose data contains SETting"
 W !,"       the same variable to a different value from the"
 W !,"       one being XECUTEed"
 S ^ABSN="11920",^ITEM="I-821  SET differenct value in EXECUTE",^NEXT="V1SEQ^VV1" D ^V1PRESET
 S VCOMP="",A="S A=$J(1,10) S VCOMP=A"
 X A S ^VCOMP=VCOMP,^VCORR="         1" D ^VEXAMINE
 ;
END W !!,"End of 161---V1XECB",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
F S VCOMP=VCOMP_3 Q
G S VCOMP=VCOMP_9 Q
H S V=V_I Q
I S V=V_I Q
J S V=V_I Q
K S V=V_I Q
L S V=V_(I+1) Q
M S R="***",X=0,S="S V=V_12" S V=V_11
