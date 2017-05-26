VV2LCF2	;LOWER CASE LETTER FUNCTION NAMES (LESS $data) AND SPECIAL VARIABLES -2-;KO-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1984
	S PASS=0,FAIL=0
	w !!,"VV2LCF2: TEST OF LOWER CASE LETTER FUNCTION NAMES (LESS$data)"
	W !,"         AND SPECIAL VARIABLE NEAMES -2-",!
	W !,"function names are lower case letters ($r $s $t)",!
51	W !,"II-51  $random"
	S ITEM="II-51  ",VCOMP="",VCOMP=$random(1)_$Random(1),VCORR="00" D EXAMINER
	;
52	W !,"II-52  $r"
	S ITEM="II-52  ",VCOMP="",VCOMP=$r(1)_$r(1),VCORR="00" D EXAMINER
	;
53	W !,"II-53  $select" K ABC
	S ITEM="II-53  ",VCOMP="",ABC="ABC",ABC(1)="00123.45"
	S VCOMP=$select(ABC="ABC":"abc",1:1)_$Select(ABC=1:"EFG",1:2),VCORR="abc2" D EXAMINER
	;
54	W !,"II-54  $s" K ABC
	S ITEM="II-54  ",VCOMP="",ABC="abc",ABC(1)="00123.45"
	S VCOMP=$s(ABC="abc":"abc",1:1)_$s(ABC(1)=1:"EFG",1:2),VCORR="abc2" D EXAMINER
	;
55	W !,"II-55  $text"
	SET ITEM="II-55  ",VCOMP=""
	S VCOMP=$p($text(55)," ",1)_$p($Text(55+1)," ",2),VCORR="55SET" D EXAMINER
	;
56	W !,"II-56  $t"
	S ITEM="II-56  ",VCOMP=""
	S VCOMP=$p($t(56)," ",1)_$p($t(56+1)," ",2),VCORR="56S" D EXAMINER
	;
	W !!,"special variable names are lower case letters ($x $y $i $j $h $s $t)",!
57	W !,"II-57  $x"
	S ITEM="II-57  ",VCOMP="" S VCOMP=$x,VCORR=+$x D EXAMINER
	;
58	W !,"II-58  $y"
	S ITEM="II-58  ",VCOMP="" S VCOMP=$y,VCORR=+$y D EXAMINER
	;
59	W !,"II-59  $io"
	S ITEM="II-59  ",VCOMP="" S VCOMP=$io,VCORR=+$io D EXAMINER
	;
60	W !,"II-60  $i"
	S ITEM="II-60  ",VCOMP="" S VCOMP=$i,VCORR=+$i D EXAMINER
	;
61	W !,"II-61  $job"
	S ITEM="II-61  ",VCOMP="" S VCOMP=$JOB_$job,VCORR=+$JOB_(+$job) D EXAMINER
	;
62	W !,"II-62  $j"
	S ITEM="II-62  ",VCOMP="" S VCOMP=$J_$j,VCORR=+$J_(+$j) D EXAMINER
	;
63	W !,"II-63  $horolog"
	S ITEM="II-63  ",VCOMP=""
	S H1=$HOROLOG,H2=$horolog,H3=$HOROLOG,H4=$Horolog
	S VCOMP=$P(H1,",",1)_$P(H2,",",1)_$P(H3,",",2)_$P(H4,",",2)_(H2?1.N1","1.N)
	S VCORR=+$P(H1,",",1)_(+$P(H2,",",1))_(+$P(H3,",",2))_(+$P(H4,",",2))_1 D EXAMINER
	;
64	W !,"II-64  $h"
	S ITEM="II-64  ",VCOMP="" S H1=$H,H2=$h
	S VCOMP=$P(H1,",",1)_$P(H2,",",1)_$P(H1,",",2)_$P(H2,",",2)_(H2?1.N1","1.N)
	S VCORR=+$P(H1,",",1)_(+$P(H2,",",1))_(+$P(H1,",",2))_(+$P(H2,",",2))_1 D EXAMINER
	;
65	W !,"II-65  $storage"
	S ITEM="II-65  ",VCOMP="",SU=$STORAGE,SL=$storage
	S VCOMP=SU_SL S VCORR=+SU_(+SL) D EXAMINER
	;
66	W !,"II-66  $s",SU=$S,SL=$s
	S ITEM="II-66  ",VCOMP="" S VCOMP=SU_SL S VCORR=+SU_(+SL) D EXAMINER
	;
67	W !,"II-67  $test"
	S ITEM="II-67  ",VCOMP="" I 1 S VCOMP=VCOMP_$TEST_$test_$TEst I 0
	S VCOMP=VCOMP_$TEST_$test_$TEst
	S VCORR="111000" D EXAMINER
	;
68	W !,"II-68  $t"
	S ITEM="II-68  ",VCOMP="" I 1 S VCOMP=VCOMP_$T_$t I 0
	S VCOMP=VCOMP_$T_$t S VCORR="1100" D EXAMINER
	;
END	w !!,"END OF VV2LCF2",!
	S ROUTINE="VV2LCF2",TESTS=18,AUTO=18,VISUAL=0 D ^VREPORT
	k  q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
