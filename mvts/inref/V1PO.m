V1PO ;IW-YS-TS,VV1,MVTS V9.10;15/6/96;PARENTHESIS AND OPERATOR
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"191---V1PO: Precedence of operators and effects of parenthesis",!
719 W !,"I-719  Priority of unary operators"
 S ^ABSN="12098",^ITEM="I-719  Priority of unary operators",^NEXT="720^V1PO,V1RANDA^VV1" D ^V1PRESET
 S A='0+'0,B='(0+1),C=1+-+(--(-1++2)+'(1+0)),D=+-'0
 S ^VCOMP=A_" "_B_" "_C_" "_D,^VCORR="2 0 0 -1" D ^VEXAMINE
 ;
720 W !,"I-720  Priority of binary operators"
7201 S ^ABSN="12099",^ITEM="I-720.1  * and +",^NEXT="7202^V1PO,V1RANDA^VV1" D ^V1PRESET
 S A=2*3+1,B=(2*3)+1,C=2*(3+1),D=1+2*3,E=(1+2)*3,F=1+(2*3)
 S ^VCOMP=A_" "_B_" "_C_" "_D_" "_E_" "_F,^VCORR="7 7 8 9 9 7" D ^VEXAMINE
 ;
7202 S ^ABSN="12100",^ITEM="I-720.2  \ and *",^NEXT="7203^V1PO,V1RANDA^VV1" D ^V1PRESET
 S A=3\2*4,B=(3\2)*4,C=3\(2*4),D=3*2\4,E=(3*2)\4,F=3*(2\4)
 S ^VCOMP=A_" "_B_" "_C_" "_D_" "_E_" "_F,^VCORR="4 4 0 1 1 0" D ^VEXAMINE
 ;
7203 S ^ABSN="12101",^ITEM="I-720.3  # and *",^NEXT="7204^V1PO,V1RANDA^VV1" D ^V1PRESET
 S A=3#2*4,B=(3#2)*4,C=3#(2*4),D=3*2#4,E=(3*2)#4,F=3*(2#4)
 S ^VCOMP=A_" "_B_" "_C_" "_D_" "_E_" "_F,^VCORR="4 4 3 2 2 6" D ^VEXAMINE
 ;
7204 S ^ABSN="12102",^ITEM="I-720.4  ' and =",^NEXT="7205^V1PO,V1RANDA^VV1" D ^V1PRESET
 S A='6=5,B=('6)=5,C='(6=5),D='0=2,E=('0)=2,F='(0=2),G='6=1,H=('6)=1,I='(6=1)
 S ^VCOMP=A_" "_B_" "_C_" "_D_" "_E_" "_F_" "_G_" "_H_" "_I,^VCORR="0 0 1 0 0 1 0 0 1" D ^VEXAMINE
 ;
7205 S ^ABSN="12103",^ITEM="I-720.5  & and =",^NEXT="7206^V1PO,V1RANDA^VV1" D ^V1PRESET
 S A=2&5=5,B=(2&5)=5,C=2&(5=5),D=2&5=1,E=(2&5)=1,F=2&(5=1)
 S ^VCOMP=A_" "_B_" "_C_" "_D_" "_E_" "_F,^VCORR="0 0 1 1 1 0" D ^VEXAMINE
 ;
7206 S ^ABSN="12104",^ITEM="I-720.6  ! and =",^NEXT="721^V1PO,V1RANDA^VV1" D ^V1PRESET
 S A=0!2=1,B=(0!2)=1,C=0!(2=1),^VCOMP=A_" "_B_" "_C,^VCORR="1 1 0" D ^VEXAMINE
 ;
721 W !,"I-721  Priority of all operators"
 S ^ABSN="12105",^ITEM="I-721  Priority of all operators",^NEXT="722^V1PO,V1RANDA^VV1" D ^V1PRESET
 S A=1+2*3-4\5#6>7<8=9&10!11]12[13
 S B=1]2[3!4&5=6<7>8#9\10-11*12+13,C=1'>2+3'<4*5'=6-7'&8\9'!10
 S ^VCOMP=A_" "_B_" "_C,^VCORR="0 -119 0" D ^VEXAMINE
 ;
722 W !,"I-722  Effect of parenthesis on interpretation sequence"
 S ^ABSN="12106",^ITEM="I-722  Effect of parenthesis on interpretation sequence",^NEXT="723^V1PO,V1RANDA^VV1" D ^V1PRESET
 S A=4-((2-3)*(4-2)+(2-1))*2,B=(1+(10/2+1)>(3-1*2)*4)
 S ^VCOMP=A_" "_B,^VCORR="10 4" D ^VEXAMINE
 ;
723 W !,"I-723  Nesting of parenthesis"
 S ^ABSN="12107",^ITEM="I-723  Nesting of parenthesis",^NEXT="V1RANDA^VV1" D ^V1PRESET
 S A=1+(2*(3+(4*5)))
 S B=1+(2*(3-(4#(5\(6>(7<(8=(9&(10!(11](12[13)))))))))))
 S C=1'>(2+(3'<(4*5)))'=(6-(7'&(8\9)'!0)),D=((((((((((((((1+1.1))))))))))))))
 S ^VCOMP=A_" "_B_" "_C_" "_D,^VCORR="47 -1 1 2.1" D ^VEXAMINE
 ;
END W !!,"End of 191---V1PO",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
