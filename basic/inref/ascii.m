ascii	; Test of $ASCII function
	W "******* ASCII TEST ********",!
	S X=""
	F I=1:1:255 S X=X_$C(I)
	F I=1:1:255 I $A(X,I)'=(I) W "ERROR 1 I = ",I,!
	F I=1:1:255 I $A(X,I_"BUG")'=(I) W "ERROR 2 I = ",I,!
	F I=1:1:255 I $A(X,I+.9)'=(I) W "ERROR 3 I = ",I,!
	F I=1:1:255 I $A(X,I)'=$A($E(X,I)) W "ERROR 4 I = ",I,!
	S X="" F I=1:10:255 I $A(X,I)'=-1 W "ERROR 5 I = ",I,!
	I $A("")'=-1 W "ERROR $A("""""""")'=-1",!
