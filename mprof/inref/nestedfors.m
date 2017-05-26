nestedfors ;
        ; A part of mprof/D9L03002804 test. Verifies that counts for various combinations of nested
	; FORs work as expected.
	;
	kill ^trace
	view "trace":1:"^trace"
	do innerforcount
	do nestedfor
	do nestinglevels
	do outernestedfor
	view "trace":0:"^trace"
	zwrite ^trace
	quit
	;
innerforcount ; two FORs on one line
	for i=1:1:2 for j=1:1:3 do
	. set v=0
	quit
	;
nestedfor ; two FORs on one line, with changing termination condition
	for i=1:1:3 for j=1:1:(3-i) set v=0
	quit
	;
nestinglevels ; nested FORs on two lines
	for i=1:1:5 do
	. for j=1:1:1 do
	. . s v=3
	quit
	;
outernestedfor ; three FORs on one line, with changing termination conditions
	for i=1:1:3 for j=1:1:(3-i) for k=1:1:(j+1) set v=0
	quit
	;
