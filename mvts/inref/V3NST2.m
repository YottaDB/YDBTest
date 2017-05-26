V3NST2 ;IW-KO-YS-TS,VV3,MVTS V9.10;15/6/96;NESTING LEVEL -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"       Moved from V1NST2"
 W !!,"29---V3NST2: Nesting ( FOR, XECUTE, DO, @, <FUNCTION> ) -2-"
 W !,"As this routine itself is counted as one level of nesting,"
 W !,"additional 29 levels of nesting are required."
 W !,"Admitted nesting levels are indicated by the number in each test.",!
 ;
1 W !,"I,III-343  1 level of DO, and 29 levels of argument level indirection"
 S ^ABSN="30343",^ITEM="I,III-343  1 level of DO, and 29 levels of argument level indirection"
 S ^NEXT="2^V3NST2,V3NST3^VV3" D ^V3PRESET
 S V=""
 S ^V1ID(1)="D1,ED1^V3NSTE,@^V1ID(2)",^V1ID(2)="ED2^V3NSTE,@^V1ID(3)"
 S ^V1ID(3)="ED3^V3NSTE,@^V1ID(4)",^V1ID(4)="ED4^V3NSTE,@^V1ID(5)"
 S ^V1ID(5)="D5,ED5^V3NSTE,@^V1ID(6)",^V1ID(6)="ED6^V3NSTE,@^V1ID(7)"
 S ^V1ID(7)="ED7^V3NSTE,@^V1ID(8)",^V1ID(8)="ED8^V3NSTE,@^V1ID(9)"
 S ^V1ID(9)="ED9^V3NSTE,@^V1ID(10)",^V1ID(10)="D10,ED10^V3NSTE,@^V1ID(11)"
 S ^V1ID(11)="ED11^V3NSTE,@^V1ID(12)",^V1ID(12)="ED12^V3NSTE,@^V1ID(13)"
 S ^V1ID(13)="ED13^V3NSTE,@^V1ID(14)",^V1ID(14)="ED14^V3NSTE,@^V1ID(15)"
 S ^V1ID(15)="ED15^V3NSTE,@^V1ID(16)",^V1ID(16)="ED16^V3NSTE,@^V1ID(17)"
 S ^V1ID(17)="ED17^V3NSTE,@^V1ID(18)",^V1ID(18)="ED18^V3NSTE,@^V1ID(19)"
 S ^V1ID(19)="ED19^V3NSTE,@^V1ID(20)",^V1ID(20)="ED20^V3NSTE,@^V1ID(21)"
 S ^V1ID(21)="ED21^V3NSTE,@^V1ID(22)",^V1ID(22)="ED22^V3NSTE,@^V1ID(23)"
 S ^V1ID(23)="ED23^V3NSTE,@^V1ID(24)",^V1ID(24)="ED24^V3NSTE,@^V1ID(25)"
 S ^V1ID(25)="ED25^V3NSTE,@^V1ID(26)",^V1ID(26)="ED26^V3NSTE,@^V1ID(27)"
 S ^V1ID(27)="ED27^V3NSTE,@^V1ID(28)",^V1ID(28)="ED28^V3NSTE,@^V1ID(29)"
 S ^V1ID(29)="ED29^V3NSTE"
 D @^V1ID(1)
 S ^VCOMP=V
 S ^VCORR="12345678910111213141516171819202122232425262728D1 D2 D3 D4 5678910111213141516171819202122232425262728D5 D6 D7 D8 D9 10111213141516171819202122232425262728D10 D11 D12 D13 D14 D15 D16 D17 D18 D19 D20 D21 D22 D23 D24 D25 D26 D27 D28 D29 "
 D ^VEXAMINE K ^V1ID
 ;
2 W !,"I,III-344  1 level of DO, and 29 levels of name level indirection"
 S ^ABSN="30344",^ITEM="I,III-344  1 level of DO, and 29 levels of name level indirection"
 S ^NEXT="3^V3NST2,V3NST3^VV3" D ^V3PRESET
 S VCOMP=""
 S X="#",A="X",B="@A",C="@B",D="@C",E="@D",F="@E",G="@F",H="@G",I="@H"
 S J="@I",K="@J",L="@K",M="@L",N="@M",O="@N",P="@O",Q="@P",R="@Q",S="@R",T="@S",U="@T",V="@U",W="@V",XX="@W",Y="@XX",Z="@Y",AZ="@Z",BZ="@AZ",CZ="@BZ"
 S VCOMP=X_@A_@B_@C_@D_@E_@F_@G_@H_@I_@J_@K_@L_@M_@N_@O_@P_@Q_@R_@S_@T_@U_@V_@W_@XX_@Y_@Z_@AZ_@BZ_@CZ_" "
 S A="A" S VCOMP=VCOMP_A_@A_@@A_@@@A_@@@@A_@@@@@A_@@@@@@A_@@@@@@@A_@@@@@@@@A
 S VCOMP=VCOMP_@@@@@@@@@A
 S VCOMP=VCOMP_@@@@@@@@@@A_@@@@@@@@@@@A_@@@@@@@@@@@@A_@@@@@@@@@@@@@A
 S VCOMP=VCOMP_@@@@@@@@@@@@@@A_@@@@@@@@@@@@@@@A_@@@@@@@@@@@@@@@@A
 S VCOMP=VCOMP_@@@@@@@@@@@@@@@@@A_@@@@@@@@@@@@@@@@@@A_@@@@@@@@@@@@@@@@@@@A
 S VCOMP=VCOMP_@@@@@@@@@@@@@@@@@@@@A_@@@@@@@@@@@@@@@@@@@@@A_@@@@@@@@@@@@@@@@@@@@@@A
 S VCOMP=VCOMP_@@@@@@@@@@@@@@@@@@@@@@@A_@@@@@@@@@@@@@@@@@@@@@@@@A_@@@@@@@@@@@@@@@@@@@@@@@@@A
 S VCOMP=VCOMP_@@@@@@@@@@@@@@@@@@@@@@@@@@A_@@@@@@@@@@@@@@@@@@@@@@@@@@@A_@@@@@@@@@@@@@@@@@@@@@@@@@@@@A
 S VCOMP=VCOMP_@@@@@@@@@@@@@@@@@@@@@@@@@@@@@A
 S ^VCOMP=VCOMP,^VCORR="############################## AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" D ^VEXAMINE
 ;
3 W !,"I,III-345  Up to 7 nesting levels of functions"
FNC S ^ABSN="30345",^ITEM="I,III-345  Up to 7 nesting levels of functions"
 S ^NEXT="V3NST3^VV3" D ^V3PRESET
 S VCOMP=""
F20 S VCOMP=VCOMP_$L($T(FNC))+2-$L($T(FNC))
F21 S VCOMP=VCOMP_$P("1,2",$P(",^.","^",1),$E(2,1))
F30 S VCOMP=VCOMP_$A($C($L("A1B")))
F31 S VCOMP=VCOMP_$L($E($E("ABC",1,3),+$T(F31),3))
F40 S VCOMP=VCOMP_$F("12345",$L($E($P("ABCDE","B",2),1,"3")))
F41 S VCOMP=VCOMP_$F($P($E("12345",$F("A","B"),$L("ABCD")),0,1),"3")
F50 S VCOMP=VCOMP_$E($E($E($E($E("ABCD5",1,5),1,5),1,5),1,5),5)
F51 S VCOMP=VCOMP_$L($J($C($E($P("PQR64","P",2),$L(123),4),6_$L("ABCDE")),5))
F60 S VCOMP=VCOMP_$L($E($E($E($E($E($P("123#ABCDEF","#",2),1,6),1,6),1,6),1,6),1,6))
 S ^VCOMP=VCOMP,^VCORR="223344556" D ^VEXAMINE
 ;
END W !!,"End of 29 --- V3NST2",!
 K  K ^V1ID Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
D6611 S V=V_I_J_" " Q
 ;
D1 S V=V_1 D D2 Q
D2 S V=V_2 D D3 Q
D3 S V=V_3 D D4 Q
D4 S V=V_4 D D5 Q
D5 S V=V_5 D D6 Q
D6 S V=V_6 D D7 Q
D7 S V=V_7 D D8 Q
D8 S V=V_8 D D9 Q
D9 S V=V_9 D D10 Q
D10 S V=V_10 D D11 Q
D11 S V=V_11 D D12 Q
D12 S V=V_12 D D13 Q
D13 S V=V_13 D D14 Q
D14 S V=V_14 D D15 Q
D15 S V=V_15 D D16 Q
D16 S V=V_16 D D17 Q
D17 S V=V_17 D D18 Q
D18 S V=V_18 D D19 Q
D19 S V=V_19 D D20 Q
D20 S V=V_20 D D21 Q
D21 S V=V_21 D D22 Q
D22 S V=V_22 D D23 Q
D23 S V=V_23 D D24 Q
D24 S V=V_24 D D25 Q
D25 S V=V_25 D D26 Q
D26 S V=V_26 D D27 Q
D27 S V=V_27 D D28 Q
D28 S V=V_28 Q
 ;
D6612 S V=V_I_J_" "
