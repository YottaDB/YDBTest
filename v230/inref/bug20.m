MAIN	S X="X" F I=1:1:5 S X=X_(I#10) D PROC
	H 2
	Q
PROC	W ?80-$L(X)/2,X,!
	Q
