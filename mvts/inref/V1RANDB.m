V1RANDB ;IW-KO-TS,VV1,MVTS V9.10;15/6/96;$RANDOM FUNCTION -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"193---V1RANDB: $RANDOM fuction -2-"
 ;
742 W !!,"Gap test"
 W !!,"Following test is examined with 'chi square' test."
 W !,"Each experimented value of 'chi square' is required"
 W !,"to be within 95% confidence value."
 W !,"95% significance limits : LESS THAN 43.8"
 ;
 W !!,"I-742  Randomness of $R(2)"
 S ^ABSN="OPT02",^ITEM="I-742  Randomness of $R(2)",^NEXT="743^V1RANDB,V1IO^VV1" D ^V1PRESET
 S VCOMP=0
 ;S R=2 F I=1:1:3 D G1	; original # of iterations in the official mvts test is 3
 S R=2 F I=1:1:5 D G1	; # of iterations increased to 5 to reduce the frequency of test failures <mvts_randomness_failure>
 S ^VCOMP=VCOMP,^VCORR=5 D OPT^VEXAMINE
 ;
743 W !!,"I-743  Randomness of $R(3)"
 S ^ABSN="OPT03",^ITEM="I-743  Randomness of $R(3)",^NEXT="744^V1RANDB,V1IO^VV1" D ^V1PRESET
 S VCOMP=0
 ;S R=3 F I=1:1:3 D G1	; original # of iterations in the official mvts test is 3
 S R=3 F I=1:1:5 D G1	; # of iterations increased to 5 to reduce the frequency of test failures <mvts_randomness_failure>
 S ^VCOMP=VCOMP,^VCORR=5 D OPT^VEXAMINE
 ;
744 W !!,"I-744  Randomness of $R(4)"
 S ^ABSN="OPT04",^ITEM="I-744  Randomness of $R(4)",^NEXT="745^V1RANDB,V1IO^VV1" D ^V1PRESET
 S VCOMP=0
 ;S R=4 F I=1:1:3 D G1	; original # of iterations in the official mvts test is 3
 S R=4 F I=1:1:5 D G1	; # of iterations increased to 5 to reduce the frequency of test failures <mvts_randomness_failure>
 S ^VCOMP=VCOMP,^VCORR=5 D OPT^VEXAMINE
 ;
745 W !!,"I-745  Randomness of $R(5)"
 S ^ABSN="OPT05",^ITEM="I-745  Randomness of $R(5)",^NEXT="746^V1RANDB,V1IO^VV1" D ^V1PRESET
 S VCOMP=0
 ;S R=5 F I=1:1:3 D G1	; original # of iterations in the official mvts test is 3
 S R=5 F I=1:1:5 D G1	; # of iterations increased to 5 to reduce the frequency of test failures <mvts_randomness_failure>
 S ^VCOMP=VCOMP,^VCORR=5 D OPT^VEXAMINE	; make sure ^VCORR is set to the same value as the loop counter above
 ;
746 W !!,"Frequency test"
 W !!,"Following test is examined with 'chi square' test."
 W !,"Each experimented value of 'chi square' is required"
 W !,"To be within 95% confidence value."
 W !!,"I-746  Randomness of $R(2)"
 S ^ABSN="OPT06",^ITEM="I-746  Randomness of $R(2)",^NEXT="747^V1RANDB,V1IO^VV1" D ^V1PRESET
 S VCOMP=0
 S LML(2)=.001,LMU(2)=5.02
 S R=2 D FRQ1
 ;S ^VCOMP=VCOMP,^VCORR=3 D OPT^VEXAMINE
 S ^VCOMP=VCOMP,^VCORR=5 D OPT^VEXAMINE	; make sure ^VCORR is set to the same value as the loop counter in FRQ1
 ;
747 W !!,"I-747  Randomness of $R(3)"
 S ^ABSN="OPT07",^ITEM="I-747  Randomness of $R(3)",^NEXT="748^V1RANDB,V1IO^VV1" D ^V1PRESET
 S VCOMP=0
 S LML(3)=.051,LMU(3)=7.38
 S R=3 D FRQ1
 ;S ^VCOMP=VCOMP,^VCORR=3 D OPT^VEXAMINE
 S ^VCOMP=VCOMP,^VCORR=5 D OPT^VEXAMINE	; make sure ^VCORR is set to the same value as the loop counter in FRQ1
 ;
748 W !!,"I-748  Randomness of $R(10)"
 S ^ABSN="OPT08",^ITEM="I-748  Randomness of $R(10)",^NEXT="V1IO^VV1" D ^V1PRESET
 S VCOMP=0
 S LML(10)=2.7,LMU(10)=19.02
 S R=10 D FRQ1
 ;S ^VCOMP=VCOMP,^VCORR=3 D OPT^VEXAMINE
 S ^VCOMP=VCOMP,^VCORR=5 D OPT^VEXAMINE	; make sure ^VCORR is set to the same value as the loop counter in FRQ1
 ;
END W !!,"End of 193---V1RANDB",!
 K  Q
 ;
G1 K P F J=0:1:30 S P(J)=0
 F J=1:1:100 D G3
 S CHI=0 F J=0:1:30 D G2
 W:$Y>55 # W !,"       NO.",I," VALUE OF 'CHI SQUARE' : ",$J(CHI,0,2)
 I CHI>43.8 S VCOMP=VCOMP+1 W ?50,"OUT OF LIMITS"
 Q
G2 S F=100/R F K=1:1:J S F=F*(1-(1/R))
 S CHI=(F-P(J))*(F-P(J))/F+CHI Q
G3 S RND=$R(R) F GAP=0:1 Q:RND=$R(R)
 S:GAP<31 P(GAP)=P(GAP)+1 Q
 ;
FRQ1 W !,"       95% SIGNIFICANCE LIMITS : FROM ",LML(R)," TO ",LMU(R)
 ;F I=1:1:3 D FRQ2	; original # of iterations in the official mvts test is 3
 F I=1:1:5 D FRQ2	; # of iterations increased to 5 to reduce the frequency of test failures <mvts_randomness_failure>
 Q
FRQ2 K P F J=0:1:R-1 S P(J)=0
 F J=1:1:R*20 S RND=$R(R),P(RND)=P(RND)+1
 S CHI=0 F J=0:1:R-1 S CHI=(P(J)-20)*(P(J)-20)/20+CHI
 W:$Y>55 # W !,"       NO.",I,"  VALUE OF 'CHI SQUARE' : ",$J(CHI,0,2)
 I CHI<LML(R)!(CHI>LMU(R)) S VCOMP=VCOMP+1 W ?50,"OUT OF LIMITS"
 Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
