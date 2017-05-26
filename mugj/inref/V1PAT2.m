V1PAT2	;PATTERN MATCH OPERATOR (?) -2-;KO-YS-TS,V1PAT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1PAT2: TEST OF PATTERN MATCH OPERATOR -2-",!
703	W !,"I-703  multiplier>0"
	S ITEM="I-703  ",X="" F I=1:1:100 S X=X_"0"
	S X=X_"1" F I=1:1:99 S X=X_"0"
	S VCOMP=X?.N_(X?200N)_(X?."0"."1".N)_(X?.E1"0")_(X?.A.N.E."1".N) S VCORR="11111" D EXAMINER
	;
704	W !,"I-704  multiplier=0"
	S ITEM="I-704  ",X="",VCOMP=""?0E_(""?0AULPCEN)_("0"?.0"0")_("ASBC"?000E)_("ASDF"?0UPLPCEN),VCORR="11000" D EXAMINER
	;
705	W !,"I-705  infinite multiplier (.)"
	S ITEM="I-705  " S X="AB$",VCOMP=""
	S VCOMP=X?.A_(X?.P)_(X?.P.N)_(X?.PN)_(X?.C.A.P)_(X?."AB"."$")_(X?."A"1A1"".P)_(X?.AP."")_(X?.E.A1PU1PL)
	S VCORR="000011111" D EXAMINER
	;
706	W !,"I-706  empty string as patatom"
	S ITEM="I-706.1  ?patatom",A=""
	S VCOMP=(A?.C)_(A?.N)_(A?.P)_(A?.A)_(""?.L)_(A?.U)_(A?.E)_(A?."")_(A?."Q")_" "
	S VCOMP=VCOMP_(""?0C)_(A?0N)_(A?0P)_(A?0A)_(A?0L)_(A?0U)_(A?0E)_(A?0"")_(A?0"Q")_" "
	S VCOMP=VCOMP_(A?1C)_(A?2N)_(A?3P)_(""?4A)_(A?5L)_(A?6U)_(A?7E)_(""?8"")_(A?1"Q")_" "
	S VCORR="111111111 111111111 000000010 " D EXAMINER
	;
	S ITEM="I-706.2  '?patatom",A=""
	S VCOMP=(A'?.C)_(A'?.N)_(A'?.P)_(A'?.A)_(""'?.L)_(A'?.U)_(A'?.E)_(A'?."")_(A'?."Q")_" "
	S VCOMP=VCOMP_(""'?0C)_(A'?0N)_(A'?0P)_(A'?0A)_(A'?0L)_(A'?0U)_(A'?0E)_(A'?0"")_(A'?0"Q")_" "
	S VCOMP=VCOMP_(A'?1C)_(A'?2N)_(A'?3P)_(""'?4A)_(A'?5L)_(A'?6U)_(A'?7E)_(""'?8"")_(A'?1"Q")_" "
	S VCORR="000000000 000000000 111111101 " D EXAMINER
	;
707	W !,"I-707  not match ('?)"
	S ITEM="I-707  " S VCOMP='"A"'?.N_('"0"'?1N)_('0?1N),VCORR="001" D EXAMINER
	;
708	W !,"I-708  pattern level indirection"
	S ITEM="I-708  ",X="1NA.NA",Y="1""1B2C"""
	S VCOMP="TEST1TEST2"?@X_("A1B2C3"?@(".C.APL"_Y_"1N"))_" "
	K ^V1 S ^V1(0)="1N2E.PA",VCOMP=VCOMP_(^V1(0)?@^(0))_(^(0)'?@^(0))
	S VCORR="11 10" D EXAMINER
	;
709	W !,"I-709  interpretation of left side expression"
	S ITEM="I-709  ",VCOMP="12.34"'?.N_("1234."?.N)_(+"1234."?.N)_(-"-123E"?1N.N)
	S VCOMP=VCOMP_("-123"?.N)_(-123?.N)_(-"-.123E+3"?.N)_(-"-12300E-2"?.N)
	S VCORR="10110011" D EXAMINER
	;
710	W !,"I-710  pattern match of maximum length of data"
	S ITEM="I-710  " S X="" F I=1:1:255 S X=X_"0"
	S VCOMP=X?255N_(X?."0")_(X?.N)_(X?100N.E.N)_(X?50"0"50E50N50"0"."0") S VCORR="11111" D EXAMINER
	;
711	W !,"I-711  various combination of patcode"
	S ITEM="I-711  ",V="",X="AB$" FOR I=1:1:10 S V=$C(I,I*2,I+100,I*I)?1CAULPN.ACULPN1NACULP_V
	S V="AB12$asd"_$C(1)_"A09a"'?.AN.P.L2L.E1C.E1L_V
	S V=V_(X?.A)_(X?1A)_(X?3A)_(X?2A1P)_(X?3AP)_(X'?4PA)_(X?1"AB$")_(X?1"A"1"B"1"$")
	S V=V_(X?.C.A.P)_(X?."AB"."$")_(X?."A"1A1"".P)_(X?.AP."")_(X?."AB$")
	S V=V_(X?."AB$"1A2AP)_(X?100""1"AB$")_(X?.E1P)_(X?.E.N1P)_(X?.E.PA1A.P)_(X?.E.A1PU1PL)
	S VCORR="011111111110001111111111111111",VCOMP=V D EXAMINER
	;
END	W !!,"END OF V1PAT2",!
	S ROUTINE="V1PAT2",TESTS=10,AUTO=10,VISUAL=0 D ^VREPORT
	K ^V1 K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
