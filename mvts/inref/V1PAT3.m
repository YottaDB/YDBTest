V1PAT3 ;IW-KO-YS-TS,V1PAT,MVTS V9.10;15/6/96;PATTERN MATCH OPERATOR (?) -3-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"165---V1PAT3: Pattern match operator -3-",!
703 W !,"I-703  multiplier>0"
 S ^ABSN="11942",^ITEM="I-703  multiplier>0",^NEXT="704^V1PAT3,V1PAT4^V1PAT,V1NST1^VV1" D ^V1PRESET
 S X="" F I=1:1:100 S X=X_"0"
 S X=X_"1" F I=1:1:99 S X=X_"0"
 S ^VCOMP=X?.N_(X?200N)_(X?."0"."1".N)_(X?.E1"0")_(X?.A.N.E."1".N) S ^VCORR="11111" D ^VEXAMINE
 ;
704 W !,"I-704  multiplier=0"
 S ^ABSN="11943",^ITEM="I-704  multiplier=0",^NEXT="705^V1PAT3,V1PAT4^V1PAT,V1NST1^VV1" D ^V1PRESET
 S X="",^VCOMP=""?0E_(""?0AULPCEN)_("0"?0"0")_("ASBC"?000E)_("ASDF"?0UPLPCEN),^VCORR="11000" D ^VEXAMINE ;(test corrected in V7.2;24/2/88)
 ;
705 W !,"I-705  Infinite multiplier (.)"
 S ^ABSN="11944",^ITEM="I-705  Infinite multiplier (.)",^NEXT="706^V1PAT3,V1PAT4^V1PAT,V1NST1^VV1" D ^V1PRESET
 S X="AB$",^VCOMP=""
 S ^VCOMP=X?.A_(X?.P)_(X?.P.N)_(X?.PN)_(X?.C.A.P)_(X?."AB"."$")_(X?."A"1A1"".P)_(X?.AP."")_(X?.E.A1PU1PL)
 S ^VCORR="000011111" D ^VEXAMINE
 ;
706 W !,"I-706  Empty string as patatom"
7061 S ^ABSN="11945",^ITEM="I-706.1  Empty string ? patatom",^NEXT="7062^V1PAT3,V1PAT4^V1PAT,V1NST1^VV1" D ^V1PRESET
 S A=""
 S ^VCOMP=(A?.C)_(A?.N)_(A?.P)_(A?.A)_(""?.L)_(A?.U)_(A?.E)_(A?."")_(A?."Q")_" "
 S ^VCOMP=^VCOMP_(""?0C)_(A?0N)_(A?0P)_(A?0A)_(A?0L)_(A?0U)_(A?0E)_(A?0"")_(A?0"Q")_" "
 S ^VCOMP=^VCOMP_(A?1C)_(A?2N)_(A?3P)_(""?4A)_(A?5L)_(A?6U)_(A?7E)_(""?8"")_(A?1"Q")_" "
 S ^VCORR="111111111 111111111 000000010 " D ^VEXAMINE
 ;
7062 S ^ABSN="11946",^ITEM="I-706.2  Empty string '? patatom",^NEXT="7063^V1PAT3,V1PAT4^V1PAT,V1NST1^VV1" D ^V1PRESET
 S A=""
 S ^VCOMP=(A'?.C)_(A'?.N)_(A'?.P)_(A'?.A)_(""'?.L)_(A'?.U)_(A'?.E)_(A'?."")_(A'?."Q")_" "
 S ^VCOMP=^VCOMP_(""'?0C)_(A'?0N)_(A'?0P)_(A'?0A)_(A'?0L)_(A'?0U)_(A'?0E)_(A'?0"")_(A'?0"Q")_" "
 S ^VCOMP=^VCOMP_(A'?1C)_(A'?2N)_(A'?3P)_(""'?4A)_(A'?5L)_(A'?6U)_(A'?7E)_(""'?8"")_(A'?1"Q")_" "
 S ^VCORR="000000000 000000000 111111101 " D ^VEXAMINE
 ;
7063 S ^ABSN="11947",^ITEM="I-706.3  '(empty string ? patatom)",^NEXT="V1PAT4^V1PAT,V1NST1^VV1" D ^V1PRESET
 S A="" ;Test added in V7.4;16/9/89
 S ^VCOMP='(A?.C)_'(A?.N)_'(A?.P)_'(A?.A)_'(""?.L)_'(A?.U)_'(A?.E)_'(A?."")_'(A?."Q")_" "
 S ^VCOMP=^VCOMP_'(""?0C)_'(A?0N)_'(A?0P)_'(A?0A)_'(A?0L)_'(A?0U)_'(A?0E)_'(A?0"")_'(A?0"Q")_" "
 S ^VCOMP=^VCOMP_'(A?1C)_'(A?2N)_'(A?3P)_'(""?4A)_'(A?5L)_'(A?6U)_'(A?7E)_'(""?8"")_'(A?1"Q")_" "
 S ^VCORR="000000000 000000000 111111101 " D ^VEXAMINE
 ;
END W !!,"End of 165---V1PAT3",!
 K ^V1 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
