V2LCF4 ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;LOWER CASE FUNCTION NAMES (LESS $data) AND SPECIAL VARIABLES -4-
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 w !!,"7---V2LCF4: Lower case function names (less $data)"
 W !,"             and special variable neames -4-",!
 ;
61 W !,"II-61  $job"
 S ^ABSN="20061",^ITEM="II-61  $job",^NEXT="62^V2LCF4,V2FN1^VV2" D ^V2PRESET
 S ^VCOMP="" S ^VCOMP=$JOB_$job,^VCORR=+$JOB_(+$job) D ^VEXAMINE
 ;
62 W !,"II-62  $j"
 S ^ABSN="20062",^ITEM="II-62  $j",^NEXT="63^V2LCF4,V2FN1^VV2" D ^V2PRESET
 S ^VCOMP="" S ^VCOMP=$J_$j,^VCORR=+$J_(+$j) D ^VEXAMINE
 ;
63 W !,"II-63  $horolog"
 S ^ABSN="20063",^ITEM="II-63  $horolog",^NEXT="64^V2LCF4,V2FN1^VV2" D ^V2PRESET
 S ^VCOMP=""
 S H1=$HOROLOG,H2=$horolog,H3=$HOROLOG,H4=$Horolog
 S ^VCOMP=$P(H1,",",1)_$P(H2,",",1)_$P(H3,",",2)_$P(H4,",",2)_(H2?1.N1","1.N)
 S ^VCORR=+$P(H1,",",1)_(+$P(H2,",",1))_(+$P(H3,",",2))_(+$P(H4,",",2))_1 D ^VEXAMINE
 ;
64 W !,"II-64  $h"
 S ^ABSN="20064",^ITEM="II-64  $h",^NEXT="65^V2LCF4,V2FN1^VV2" D ^V2PRESET
 S ^VCOMP="" S H1=$H,H2=$h
 S ^VCOMP=$P(H1,",",1)_$P(H2,",",1)_$P(H1,",",2)_$P(H2,",",2)_(H2?1.N1","1.N)
 S ^VCORR=+$P(H1,",",1)_(+$P(H2,",",1))_(+$P(H1,",",2))_(+$P(H2,",",2))_1 D ^VEXAMINE
 ;
65 W !,"II-65  $storage"
 S ^ABSN="20065",^ITEM="II-65  $storage",^NEXT="66^V2LCF4,V2FN1^VV2" D ^V2PRESET
 S ^VCOMP="",SU=$STORAGE,SL=$storage
 S ^VCOMP=SU_SL S ^VCORR=+SU_(+SL) D ^VEXAMINE
 ;
66 W !,"II-66  $s"
 S ^ABSN="20066",^ITEM="II-66  $s",^NEXT="67^V2LCF4,V2FN1^VV2" D ^V2PRESET
 S ^VCOMP="",SU=$S,SL=$s S ^VCOMP=SU_SL S ^VCORR=+SU_(+SL) D ^VEXAMINE
 ;
67 W !,"II-67  $test"
 S ^ABSN="20067",^ITEM="II-67  $test",^NEXT="68^V2LCF4,V2FN1^VV2" D ^V2PRESET
 S ^VCOMP="" I 1 S ^VCOMP=^VCOMP_$TEST_$test_$TEst I 0
 S ^VCOMP=^VCOMP_$TEST_$test_$TEst
 S ^VCORR="111000" D ^VEXAMINE
 ;
68 W !,"II-68  $t"
 S ^ABSN="20068",^ITEM="II-68  $t",^NEXT="V2FN1^VV2" D ^V2PRESET
 S ^VCOMP="" I 1 S ^VCOMP=^VCOMP_$T_$t I 0
 S ^VCOMP=^VCOMP_$T_$t S ^VCORR="1100" D ^VEXAMINE
 ;
END w !!,"End of 7---V2LCF4",!
 k  q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
