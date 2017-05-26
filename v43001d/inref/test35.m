test35	;
	; test that $STACK(-1) follows $STACK under first nested error
x	;
	s $etrap="do etr"
	do y
	quit
y	;
	s x=1/0
	quit
etr	;
	w "in etr  : $stack(-1) = ",$stack(-1),!
	do etr1
	quit
etr1	;
	w "in etr1 : $stack(-1) = ",$stack(-1),!
	quit
