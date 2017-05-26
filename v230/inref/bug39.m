	;ERROR IN NEW (X) XECUTE "G FOO" W X
MAIN	S Q1=",",Q2="Y",Q3=",Y1" N (X,Q1,Q2,Q3)
	D PROC
	Q
PROC	S X="This must be the place",Y="Why naught?"
	N @("(X"_Q1_Q2_Q3_")")
	W !,"STASH STACK" S LEV=0 D STASH
	W "!",X,!
	X "W ""#"",X,! G TARGET W ""PANIC"""
	W "$",X,!
	Q
TARGET	W "%",X,!
	Q
STASH	S LEV=LEV+1 I LEV>100 W ! Q
	W:LEV#10=0 "." D STASH
	Q
