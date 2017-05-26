gtm6395	;
	set $etrap="do etr^gtm6395"
	set linestr="-------------------------------------------------------------------------"
	do test1
	do test2	; expect an UNDEF error
	do test3
	do test4
	do test5
	do test6
	do test7
	; New test cases below. test1..test7 are indirect versions of those in d002724.m
	; These cases are more specific to the indirection-related code changes.
	do test8
	do test9
	do test10
	do test11
	do test12
	do test13
	do test14
	do test15
	do test16
	do test17
	do test18
	do test19
	do test20
	do test21
	do test22
	do test23
	quit
	;
etr	;
	; If we encounter an error, print it and move on. In some cases we expect an UNDEF error.
	;
	write $zstatus,!
	set $ecode=""
	quit
	;
I()     ; 
	set I=I+1
	quit I
	;
II()	;
	set I=I+1
	set J=J+2
	quit I*J
	;
III()	;
	kill I
	quit 2
	;
IIII()	;
	set @"Y($$I)"=I
	quit I
	;
test1	;
	; See comment in d002724.m
	;
	new (linestr)
	write !,linestr,!,"Test 1 ",!
	set I=1,@"X(I)"=$$I
	zwrite I,X
	quit
	; 
test2	;
	; See comment in d002724.m
	;
	new (linestr)
	write !,linestr,!,"Test 2 ",!
	write "Expect UNDEF error",!
	set @"X(I)"=$INCR(I)
	zwrite I,X
	quit
	;
test3	;
	; See comment in d002724.m
	;
	new (linestr)
	write !,linestr,!,"Test 3 ",!
	set I=1,J=2 S @"X(I+J)"=$$II
	zwrite I,J,X
	quit
	;
test4	;
	; See comment in d002724.m
	;
	new (linestr)
	write !,linestr,!,"Test 4 ",!
	S I=1,J=2 S @"X(I,J)"=$$II
	zwrite I,J,X
	quit
	;
test5	;
	; See comment in d002724.m
	;
	new (linestr)
	write !,linestr,!,"Test 5 ",!
	S I=1 S @"X(I)"=$$III
	zwrite X
	write "I=",$get(I),!	; do not use ZWRITE because we expect it to be undefined
	quit
	;
test6	;
	; See comment in d002724.m
	;
	new (linestr)
	write !,linestr,!,"Test 6 ",!
	set I=1,(@"X(I)")=$$I
	zwrite I,X
	quit
test7	;
	; See comment in d002724.m
	;
	new (linestr)
	write !,linestr,!,"Test 7 ",!
	set I=1,J=2,(@"X(I)",@"X(J)")=$$II
	zwrite I,J,X
	quit
test8	;
	; Test that having an unsubscripted local on the LHS still works.
	;
	new (linestr)
	write !,linestr,!,"Test 8 ",!
	set I=1,@"X"=$$I
	zwrite I,X
	quit
	;
test9	;
	; Same as test1, but with a subscripted global within the LHS indirection.
	;
	new (linestr)
	write !,linestr,!,"Test 9 ",!
	kill ^X
	set I=1,@"^X(I)"=$$I
	zwrite I,^X
	quit
	;
test10	;
	; Same as test8, but with an unsubscripted global within the LHS indirection.
	;
	new (linestr)
	write !,linestr,!,"Test 10 ",!
	kill ^X
	set I=1,@"^X"=$$I
	zwrite I,^X
	quit
	;
test11	;
	; Same as test1, but with nested indirection.
	;
	new (linestr)
	write !,linestr,!,"Test 11 ",!
	set I=1,@"@""X(I)"""=$$I
	zwrite I,X
	quit
	;	
test12	;
	; Same as test11, but with nested indirection an a subscripted global.
	;
	new (linestr)
	write !,linestr,!,"Test 12 ",!
	kill ^X
	set I=1,@"@""^X(I)"""=$$I
	zwrite I,^X
	quit
	;
test13	;
	; Test side effect within LHS subscript. The side effect should take place before the RHS is evaluated.
	;
	new (linestr)
	write !,linestr,!,"Test 13 ",!
	set I=1,@"X($$I)"=I
	zwrite I,X
	quit
	;
test14	;
	; If a side effect sets the set destination, verify that the final value is the evaluated RHS.
	;
	new (linestr)
	write !,linestr,!,"Test 14 ",!
	set I=1,@"I"=$$I
	zwrite I
	quit
	;
test15	;
	; Naked indicator test. The flow of updates to the naked indicator should be:
	; (a) stuff before the set --> (b) LHS subscripts --> (c) RHS --> (d) LHS destination
	; In this case, we expect ^Y(1) to get set.
	; Note that test17 would have failed prior to these code changes, but test15 and test16 wouldn't have.
	;
	new (linestr)
	write !,linestr,!,"Test 15 ",!
	kill ^X,^Y
	set ^Y(0)="Y",^X(0)="X"
	set @"^(1)"=^Y(0)
	write $name(^(0)),!
	zwrite ^X,^Y
	quit
	;
test16	;
	;
	; Another naked indicator test.
	;
	new (linestr)
	write !,linestr,!,"Test 16 ",!
	kill ^X,^Y
	set ^Y(0)="Y",^X(0)="X"
	set @"^Y(1)"=^(0)
	write $name(^(0)),!
	zwrite ^X,^Y
	quit
	;
test17	;
	; Yet another naked indicator test.
	;
	new (linestr)
	write !,linestr,!,"Test 17 ",!
	kill ^X,^Y,^Z
	set ^Z(0)="Z",^Y(0)="Y",^X(0)="X"
	set @"^Z(^Y(0))"=^(0)
	write $name(^(0)),!
	zwrite ^X,^Y,^Z
	quit
	;
test18	;
	; Check environment specification within LHS indirection.
	;
	new (linestr)
	write !,linestr,!,"Test 18 ",!
	kill ^X
	set I=1,@"^|""mumps.gld""|X($$I)"=I
	zwrite ^X
	quit
	;
test19	;
	; Kill local within RHS sideffect.
	;
	new (linestr)
	write !,linestr,!,"Test 19 ",!
	set @"X(1)"=$$III
	zwrite X
	quit
	;
test20	;
	; Test set $piece. There are two issues here: first, the side effect within the indirection should take place just once;
	; and second, we should end up setting the same variable we got the $piece from.
	;
	new (linestr)
	write !,linestr,!,"Test 20 ",!
	set I=0,X(1)="alpha|beta"
	set $piece(@"X($$I)","|",1,1)="gamma"
	zwrite I,X
	quit
	;
test21	;
	; Same as test20 but with a global.
	;
	new (linestr)
	write !,linestr,!,"Test 21 ",!
	kill ^X
	set I=0,^X(1)="alpha|beta"
	set $piece(@"^X($$I)","|",1,1)="gamma"
	zwrite I,^X
	quit
	;
test22	;
	; Same as test20 but with a $extract.
	;
	new (linestr)
	write !,linestr,!,"Test 22 ",!
	set I=0,X(1)="ab"
	set $extract(@"X($$I)",1)="c"
	zwrite I,X
	quit
	;
test23	;
	; Mix it up a bit. Compound set and an indirect set as a side effect an LHS indirection ($$IIII).
	;
	new (linestr)
	write !,linestr,!,"Test 23 ",!
	set I=0,(@"X($$I)",@"Y(I,$$I)",@"X($$IIII)",@"X($$I)")=$$IIII
	zwr I,X,Y
	quit
	;
