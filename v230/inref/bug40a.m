	;BUG40A
ENTRY	W "POINT 2",?10,$D(X) W:$D(X) ?20,X W !
	N (A,B)
	S X=2
	W "POINT 3",?10,$D(X) W:$D(X) ?20,X W !
	D FOO
	W "POINT 4",?10,$D(X) W:$D(X) ?20,X W !
	Q
FOO	N (Z,X)
	W "POINT 5",?10,$D(X) W:$D(X) ?20,X W !
	S X=4
	W "POINT 6",?10,$D(X) W:$D(X) ?20,X W !
	Q
