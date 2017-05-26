gtm7492	;
	set $etrap="do etr^gtm7492"
	set linestr="-------------------------------------------------------------------------"
	do test1
	do test2
	do test3
	do test4
	quit
	;
etr	;
	; If we encounter an error, print it and move on. In some cases we expect an UNDEF error.
	;
	write $zstatus,!
	set $ecode=""
	quit
	;
I()	;
	for j(0)=1:1:1 for k(0)=1:1:1 write "abc",!
	quit 0
test1	;
	new (linestr)
	write !,linestr,!,"Test 1 ",!
	for x($$I)=1:1:3 write "x(0)="_x(0),!
	quit
	;
test2	;
	new (linestr)
	write !,linestr,!,"Test 2 ",!
	for @"x($$I)"=1:1:3 write "x(0)="_x(0),!
	quit
	;	
test3	;
	; Test that literal_null does not become the control variable. This would SIG-11's on most platforms, but on RS/6000 the
	; loop would continue and subsequent calculations involving literal_null would be incorrect.
	;
	new (linestr)
	write !,linestr,!,"Test 3 ",!
	view "NOUNDEF"
	set j=0
	for i=1:1:5 kill i if $incr(j)=10 quit
	write $get(asdf)+0,!				; should be 0, not 5
	zwr j
	quit
	;
test4	;
	; Just make sure variable name gets formatted correctly with UNDEF error.
	;
	new (linestr)
	write !,linestr,!,"Test 4 ",!
	view "UNDEF"
	set j=0
	for i(1,"abc",3)=1:1:2 kill i if $incr(j)=10 quit
	zwr j
	quit
