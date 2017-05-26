setp	; test set $PIECE with 4th argument as literal
	w "begin of SET $PIECE testing...",!
	s foo="usr/library/V999",bar=2,baz=3,$p(foo,"/",bar,baz)="local" w foo,!   ;should output 14
	s foo="usr/library/V999",bar=2,$p(foo,"/",bar,0)="local" w foo,!     ;foo remains 1
	s foo="usr/library/V999",bar=2,$p(foo,"/",bar,1)="local" w foo,!     ;foo remains 1
	s foo="usr/library/V999",bar=2,$p(foo,"/",bar,3)="local" w foo,!     ;foo becomes 14
	s foo="usr/library/V999",bar=2,$p(foo,"/",bar,1+2)="local" w foo,!   ;foo becomes 14
	w "...end of SET $PIECE",!
	q
