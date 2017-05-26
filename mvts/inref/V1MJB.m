V1MJB ;IW-KO-TS,V1MJB,MVTS V9.10;15/6/96;LOCK, OPEN, CLOSE, $JOB, $IO and $TEST
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 H 5
 S ^V1C(2,1)=$IO,^V1C(2,2)=$I
 W !!,"This routine should run on another partition"
LOCK W !!,"Now LOCK command is under examination" K
628 S POS="628" D HANG
 LOCK ^V1A:1 S T=$T_"/" L ^V1A(1):1 S T=T_$T_"/" L ^V1A(1,2,3):1 S T=T_$T_"/"
 L ^V1A(1,1):1 S T=T_$T_"/" L ^V1B:1 S T=T_$T_"/" L ^V1B:0 L  S ^V1F=T_$T
629 S POS="629" D HANG
 S T=^V1A(1,2)_"/"_^V1A(23)
 S ^V1A(1,2)=^V1A(1,2)+^V1A(23),^V1A(23)=^V1A(23)_"/"_$D(^V1A(1))
 S ^V1A(100)=10000 L  S ^V1F=T
630 S POS="630" D HANG
 L ^V1A:1 S T=$T_"/"
 L ^V1B(1):1 S T=T_$T_"/"
 L ^V1B(100):1 L  S ^V1F=T_$T
631 S POS="631-1" D HANG L:"HELP"=$E("ABCHELPJK",4,7) ^V1A:1 S ^V1F=$T_"/"
 S POS="631-2" D HANG S ^V1F=222 L
632 S POS="632" D HANG L ^V1A:1 S T=$T_"/" L ^V1B(2):1 L  S ^V1F=T_$T_"/"
633 S POS="633-1" D HANG L ^V1A:1 S T=$T_"/" L ^V1B(2):1 S ^V1F=T_$T_"/"
 S POS="633-2" D HANG L  S ^V1F=6666
634 S POS="634" D HANG L ^V1A:1 S T=$T_"/" L ^V1B:1 S T=T_$T L  S ^V1F=T
635 S POS="635" D HANG L ^V1A:1 L  S ^V1F=$TEST
637 S POS="637" D HANG L A(1,1):1 S T=$T_"/" L A:1 S T=T_$T_"/" L A(2):1
 K A L  S ^V1F=T_$T_"/"_$D(A(1,1))
 ;
OPEN H 30 ;waiting V1MJA2 start ;(test corrected in V7.2, V7.3;20/6/88)
 W !,"Now OPEN command is under examination"
639 S POS="639" D HANG
 O ^V1A("OPEN TIMEOUT") S T=$T_"/"
 O ^V1B("OPEN TIMEOUT") S T=T_$T C ^V1B("CLOSE") S ^V1F=T
640 S POS="640" D HANG
 O ^V1A("OPEN TIMEOUT")
 C ^V1A("CLOSE") S ^V1F=$T
641 S POS="641" D HANG
 O ^V1A("OPEN TIMEOUT") S T=$T_"/"
 O ^V1B("OPEN TIMEOUT") S ^V1F=T_$T
642 S POS="642-1" D HANG O ^V1A("OPEN TIMEOUT") S ^V1F=$T_"/"
 S PAS="642-2" D HANG O ^V1A("OPEN TIMEOUT") S T=$T C ^V1A("CLOSE") S ^V1F=T_"/"
 ;
JOB S ^V1A(2,1)=$JOB,^V1A(2,2)=$J,^V1A(2,3)=$IO,^V1A(2,4)=$I
 U ^V1C(2,1) ;U 0  ;(test corrected in V7.4;16/9/89)
 W !,"Now $JOB is under examination"
 S POS="JOB" D HANG S ^V1F=1 ;(test corrected in V7.4;16/9/89)
 ;
IO ;U 0 ;(test corrected in V7.4;16/9/89)
 W !,"Now $IO is under examination"
 S POS="IO" D HANG S ^V1F=1 ;(test corrected in V7.4;16/9/89)
 ;
END W !!,"End of V1MJB" K  L  Q
 ;
HANG F I=1:1 Q:'$D(^V1F)  H 1
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
