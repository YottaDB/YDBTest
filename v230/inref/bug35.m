	;IF N(X)...K X...Q THEN X MUST BE KILLED
MAIN	S A=1,B(2)=2,C=88 D PROC
	W $D(A),?10,$D(B),?20,$D(C),!
	W C,!
	Q
PROC	N (A,B)
	K
	W $D(A),?10,$D(B),?20,$D(C),!
	Q
