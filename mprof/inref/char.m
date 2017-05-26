char	; Test of $CHAR function
	W "******** CHAR TEST *******",!
	new xstr,unix
	set unix=$ZVersion'["VMS"
	if unix do
	.	set xstr="view ""NOBADCHAR""" ; switch off default BADCHAR behavior to avoid INVDLRCVAL error below in line# 10
	.	xecute xstr
	F I=0:1:255 I $A($C(I))'=I W "ERROR WITH $A($C(",I,")",!
	F I=0:1:255 I $A($C(I+.1))'=I W "ERROR WITH $A($C(",I,")",!
	F I=0:1:255 I $A($C(I+.9))'=I W "ERROR WITH $A($C(",I,")",!
	F I=0:1:255 I $A($C(I_"BUG"))'=I W "ERROR WITH $A($C(",I,")",!
	F I=-10:1:245 I $A($C(I+10))'=(I+10) W "ERROR WITH $A($C(",I,"+10)",!
	S X="I" F I=0:1:255 I $A($C(@X))'=I W "ERROR WITH $A($C(@X)) WHERE @X = ",@X,!
	F I=-1:-1:-10 I $C(I)'="" W "ERROR WITH $C(",I,") = ",$C(I),!
	I $C($A("A"),$A("B"),$A("C"),$A("D"),$A("E"),$A("F"),$A("G"),$A("H"),$A("I"))'="ABCDEFGHI" W "ERROR",!
	I $C($A("J"),$A("K"),$A("L"),$A("M"),$A("N"),$A("O"),$A("P"),$A("Q"),$A("R"))'="JKLMNOPQR" W "ERROR",!
	I $C($A("S"),$A("T"),$A("U"),$A("V"),$A("W"),$A("X"),$A("Y"),$A("Z"))'="STUVWXYZ" W "ERROR",!
