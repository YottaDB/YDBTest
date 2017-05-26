V1RANDB	;$RANDOM FUNCTION -2-;KO-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	W !!,"V1RANDB:TEST $RANDOM FUCTION -2-"
	W !!,"Gap test"
	W !,"95% SIGNIFICANCE LIMITS : LESS THAN 43.8" K
742	W !!,"I-742  Randomness of $R(2)  (visual)"
	S ITEM="I-742  "
	S R=2 F I=1:1:5 D G1
	;
743	W !!,"I-743  Randomness of $R(3)  (visual)"
	S ITEM="I-743  "
	S R=3 F I=1:1:5 D G1
	;
744	W !!,"I-744  Randomness of $R(4)  (visual)"
	S ITEM="I-744  "
	S R=4 F I=1:1:5 D G1
	;
745	W !!,"I-745  Randomness of $R(5)  (visual)"
	S ITEM="I-745  "
	S R=5 F I=1:1:5 D G1
	;
	W !!,"Frequency test" K
746	W !!,"I-746  Randomness of $R(2)  (visual)"
	S ITEM="I-746  "
	S LML(2)=.001,LMU(2)=5.02
	S R=2 D FRQ1
	;
747	W !!,"I-747  Randomness of $R(3)  (visual)"
	S ITEM="I-747  "
	S LML(3)=.051,LMU(3)=7.38
	S R=3 D FRQ1
	;
748	W !!,"I-748  Randomness of $R(10)  (visual)"
	S ITEM="I-748  "
	S LML(10)=2.7,LMU(10)=19.02
	S R=10 D FRQ1
	;
END	W !!,"END OF V1RANDB",!
	S ROUTINE="V1RANDB",TESTS=7,AUTO=0,VISUAL=7 D ^VREPORT
	K  Q
	;
G1	F J=0:1:30 S P(J)=0
	F J=1:1:100 D G3
	S KAI=0 F J=0:1:30 D G2
	W:$Y>55 # W !,"       NO.",I," VALUE OF 'KAI SQUARE' : ",$J(KAI,0,2)
	I KAI>43.8 W ?50,"OUT OF LIMITS"
	Q
G2	S F=100/R F K=1:1:J S F=F*(1-(1/R))
	S KAI=(F-P(J))*(F-P(J))/F+KAI Q
G3	S RND=$R(R) F GAP=0:1 Q:RND=$R(R)
	S:GAP<31 P(GAP)=P(GAP)+1 Q
	;
FRQ1	W !,"       95% SIGNIFICANCE LIMITS : FROM ",LML(R)," TO ",LMU(R)
	F I=1:1:5 D FRQ2
	Q
FRQ2	K P F J=0:1:R-1 S P(J)=0
	F J=1:1:R*20 S RND=$R(R),P(RND)=P(RND)+1
	S KAI=0 F J=0:1:R-1 S KAI=(P(J)-20)*(P(J)-20)/20+KAI
	W:$Y>55 # W !,"       NO.",I," VALUE OF 'KAI SQUARE' : ",$J(KAI,0,2)
	I KAI<LML(R)!(KAI>LMU(R)) W ?50,"OUT OF LIMITS"
	Q
