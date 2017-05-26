	;BUG42--NEW/QUIT STUFF
	K
MAIN	D MAKEONE
	S Y="X"
	W $D(X),!
	W $D(@Y),!
	Q
MAKEONE	N @"(q,r)"
	S (A,B,C)="DATA"
	S X=1
	S Z="MORE"
	Q
