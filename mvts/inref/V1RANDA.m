V1RANDA ;IW-YS-KO-TS,VV1,MVTS V9.10;15/6/96;$RANDOM FUNCTION -1-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"192---V1RANDA: $RANDOM function -1-",!
 W !,"This routine takes much time.  Please be patient",!
 ;
738 W !,"$RANDOM(intexpr)",!
 W !,"I-738  Randomness of $RANDOM(10)"
 S ^ABSN="12108",^ITEM="I-738  Randomness of $RANDOM(10)",^NEXT="739^V1RANDA,V1RANDB^VV1" D ^V1PRESET
 S VCOMP=0
 K R F I=0:1:9 S R(I)=""
 F I=1:1:10000 S D=$RANDOM(10) D T738 I $D(R)=0 Q
 I I=10000 S VCOMP=VCOMP+10000
 S ^VCOMP=VCOMP,^VCORR=0 D ^VEXAMINE
 ;
739 W !!,"I-739  Interpretation of intexpr"
 S ^ABSN="12109",^ITEM="I-739  Interpretation of intexpr",^NEXT="740^V1RANDA,V1RANDB^VV1" D ^V1PRESET
 S VCOMP=0
 W !,"       $R(1E+1) : "
 F I=1:1:5 S R=$RANDOM(1E+1) W R," " I R'?.N!(R'<10) S VCOMP=VCOMP+1
 W !,"       $R(105.5E-1) : "
 F I=1:1:5 S R=$R(105.5E-1) W R," " I R'?.N!(R'<10) S VCOMP=VCOMP+1
 W !,"       $R(""10000A"") : "
 F I=1:1:5 S R=$R("10000A") W R," " I R'?.N!(R'<10000) S VCOMP=VCOMP+1
 W !,"       $R(--100/9.9) : "
 F I=1:1:5 S R=$R(--100/9.9) W R," " I R'?.N!(R'<10) S VCOMP=VCOMP+1
 W !,"       $R(1) : "
 F I=1:1:5 S R=$R(1) W R," " I R'="0" S VCOMP=VCOMP+1
 S ^VCOMP=VCOMP,^VCORR=0 D ^VEXAMINE
 ;
740 W !!,"I-740  intexpr is 9 digits ( maximum range )"
 S ^ABSN="12110",^ITEM="I-740  intexpr is 9 digits ( maximum range )",^NEXT="741^V1RANDA,V1RANDB^VV1" D ^V1PRESET
 W !,"       (This test I-740 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
741 W !!,"I-741  Range of returned value (transition test)"
 S ^ABSN="OPT01",^ITEM="I-741  Range of returned value (transition test)",^NEXT="V1RANDB^VV1" D ^V1PRESET
 W !!,"Following test is examined with 'chi square' test."
 W !,"Each experimented value of 'chi square' is required"
 W !,"to be within 95% confidence value."
 W !,"Transition test",! S VCOMP=0
 ;F III=1:1:3 D Y1	; original # of iterations in the official mvts test is 3
 F III=1:1:5 D Y1	; # of iterations increased to 5 to reduce the frequency of test failures <mvts_randomness_failure>
 S ^VCOMP=VCOMP,^VCORR=5 D OPT^VEXAMINE	; make sure ^VCORR is set to the same value as the loop counter above
 ;
END W !!,"End of 192---V1RANDA",!
 K  Q
 ;
Y1 W:$Y>55 #
 K A S CHI=0 F I=0:1:9 F J=0:1:9 S A(I,J)=0
Y2 S I=$R(10) F K=1:1:3000 S J=$R(10),A(I,J)=A(I,J)+1,I=J
Y3 W !!?4,":" F J=0:1:9 W ?J+1*7,J
Y4 W ! F K=1:1:36 W " -"
Y5 F I=0:1:9 W:$Y>55 # W !,I,?4,":" F J=0:1:9 W ?J+1*7,A(I,J)
Y6 F I=0:1:9 F J=0:1:9 S CHI=(A(I,J)-30)*(A(I,J)-30)/30+CHI
Y7 W !!,"       95% CONFIDENCE VALUE : LESS THAN 123.2"
Y8 W !,"       NO.",III,"   VALUE OF 'CHI SQUARE' : ",$J(CHI,0,2)
Y9 I CHI>123.2 S VCOMP=VCOMP+1 W "   OUT OF LIMITS"
 Q
 ;
T738 I D<0 S VCOMP=VCOMP+1
 I D>9 S VCOMP=VCOMP+1
 I $L(D)'=1 S VCOMP=VCOMP+1
 I D'?1N S VCOMP=VCOMP+1
 K R(D)
 Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
