V1PAT4 ;IW-KO-YS-TS,V1PAT,MVTS V9.10;15/6/96;PATTERN MATCH OPERATOR (?) -4-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"166---V1PAT4: Pattern match operator -4-",!
 ;
707 W !,"I-707  Not match ('?)"
7071 S ^ABSN="11948",^ITEM="I-707.1  expr '? patcode",^NEXT="70711^V1PAT4,V1NST1^VV1" D ^V1PRESET
 S ^VCOMP='"A"'?.N_('"0"'?1N)_('0'?1N),^VCORR="000" D ^VEXAMINE ;Number changed in V7.4;16/9/89
70711 S ^ABSN="11949",^ITEM="I-707.1.1  '(expr ? patcode)",^NEXT="708^V1PAT4,V1NST1^VV1" D ^V1PRESET
 S ^VCOMP='('"A"?.N)_'('"0"?1N)_'('0?1N),^VCORR="000" D ^VEXAMINE ;Test added in V7.4;16/9/89
 ;
708 W !,"I-708  Pattern level indirection"
 S ^ABSN="11950",^ITEM="I-708  Pattern level indirection",^NEXT="709^V1PAT4,V1NST1^VV1" D ^V1PRESET
 S X="1NA.NA",Y="1""1B2C"""
 S VCOMP="TEST1TEST2"?@X_("A1B2C3"?@(".C.APL"_Y_"1N"))_" "
 K ^V1 S ^V1(0)="1N2E.PA",VCOMP=VCOMP_(^V1(0)?@^(0))_(^(0)'?@^(0))
 S ^VCOMP=VCOMP,^VCORR="11 10" D ^VEXAMINE
 ;
709 W !,"I-709  Interpretation of left side expression"
 S ^ABSN="11951",^ITEM="I-709  Interpretation of left side expression",^NEXT="710^V1PAT4,V1NST1^VV1" D ^V1PRESET
 S VCOMP="12.34"'?.N_("1234."?.N)_(+"1234."?.N)_(-"-123E"?1N.N)
 S VCOMP=VCOMP_("-123"?.N)_(-123?.N)_(-"-.123E+3"?.N)_(-"-12300E-2"?.N)
 S ^VCOMP=VCOMP,^VCORR="10110011" D ^VEXAMINE
 ;
710 W !,"I-710  Pattern match of maximum length of data"
 S ^ABSN="11952",^ITEM="I-710  Pattern match of maximum length of data",^NEXT="711^V1PAT4,V1NST1^VV1" D ^V1PRESET
 S X="" F I=1:1:255 S X=X_"0"
 S ^VCOMP=X?255N_(X?."0")_(X?.N)_(X?100N.E.N)_(X?50"0"50E50N50"0"."0") S ^VCORR="11111" D ^VEXAMINE
 ;
711 W !,"I-711  Various combination of patcode"
 S ^ABSN="11953",^ITEM="I-711  Various combination of patcode",^NEXT="V1NST1^VV1" D ^V1PRESET
 S V="",X="AB$" FOR I=1:1:10 S V=$C(I,I*2,I+100,I*I)?1CAULPN.ACULPN1NACULP_V
 S V="AB12$asd"_$C(1)_"A09a"'?.AN.P.L2L.E1C.E1L_V
 S V=V_(X?.A)_(X?1A)_(X?3A)_(X?2A1P)_(X?3AP)_(X'?4PA)_(X?1"AB$")_(X?1"A"1"B"1"$")
 S V=V_(X?.C.A.P)_(X?."AB"."$")_(X?."A"1A1"".P)_(X?.AP."")_(X?."AB$")
 S V=V_(X?."AB$"1A2AP)_(X?100""1"AB$")_(X?.E1P)_(X?.E.N1P)_(X?.E.PA1A.P)_(X?.E.A1PU1PL)
 S ^VCOMP=V,^VCORR="011111111110001111111111111111" D ^VEXAMINE
 ;
END W !!,"End of 166---V1PAT4",!
 K ^V1 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
