MAIN	S A="" F B=0:1:79 S A=A_(B#10)
	F J=0:1:20 F I=1:1:79 D PROC
	Q
PROC	W ?I
	F K=0:1:J S X=1/2*3/4,X=X_X
	W $E(A,I+1,79),!
