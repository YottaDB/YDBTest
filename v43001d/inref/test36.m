test36	;
	; test $STACK(-1) freezes after first error
x	;
	s $etrap="do etr"
	do y
	quit
y	;
	do z
	quit
z	;
	s x=1/0
	quit
etr	;
	w "in etr  : $stack(-1) = ",$stack(-1),!
	quit
