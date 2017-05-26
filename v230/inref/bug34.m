	;ERROR IN NEW (X) XECUTE "G FOO" W X
MAIN	S (Q1,Q2,Q3)="" N (X)
	D PROC
	Q
PROC	S X="This must be the place"
	N @("(X"_Q1_Q2_Q3_")")
	D ^bug34a
	W "!",X,!
	X "W ""#"",X,! G TARGET W ""PANIC"""
	W "$",X,!
	Q
TARGET	W "%",X,!
	Q
