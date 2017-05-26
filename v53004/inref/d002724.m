d002724	;
	set linestr="-------------------------------------------------------------------------"
	do test1
	do test3
	do test4
	do test5
	do test6
	do test7
	do test2 ; do this last as this will give an UNDEF error
	quit
	;
test1	;
	; Test case that triggered this change request in the first place.
	; Here the presence of $$ on the right hand side should have triggered a different compilation path where the left side
	; use of I as a subscript in X(I) should have been stored as a temporary variable so the change in I's value from the
	; $$I call is not seen on the left hand side.
	; 
	new (linestr)
	write !,linestr,!,"Test 1 ",!
	set I=1,X(I)=$$I
	zwrite I,X
	quit
	; 
test2	;
	; Test that if variable is undefined on left side of the set and is defined by $INCR done on right side
	; an UNDEF error is still signalled. This tests that in case of $INCR too, the left side is evaluated
	; first (just like is done for $$ on right hand side in test1)
	;
	new (linestr)
	write !,linestr,!,"Test 2 ",!
	set X(I)=$INCR(I)
	zwrite I,X
	quit
	;
test3	;
	; Test that lhs is evaluated ahead of rhs even in case variables are used in expressions evaluating to a subscript 
	; This case worked even before and is included just for comprehensiveness.
	;
	new (linestr)
	write !,linestr,!,"Test 3 ",!
	set I=1,J=2 S X(I+J)=$$II
	zwrite I,J,X
	quit
	;
test4	;
	; Same as test1 except that MORE THAN ONE subscript on lhs is modified by rhs
	;
	new (linestr)
	write !,linestr,!,"Test 4 ",!
	S I=1,J=2 S X(I,J)=$$II
	zwrite I,J,X
	quit
	;
test5	;
	; Same as test1 but using KILL (instead of +1) inside the $$ function
	new (linestr)
	write !,linestr,!,"Test 5 ",!
	S I=1 S X(I)=$$III
	zwrite X
	write "I=",$get(I),!	; do not use ZWRITE because we expect it to be undefined
	quit
	;
test6	;
	; Same as test1 but using parenthesized SET
	new (linestr)
	write !,linestr,!,"Test 6 ",!
	set I=1,(X(I))=$$I
	zwrite I,X
	quit
test7	;
	; Similar to test4 but using parenthesized SET and TWO different setleft targets
	new (linestr)
	write !,linestr,!,"Test 7 ",!
	set I=1,J=2,(X(I),X(J))=$$II
	zwrite I,J,X
	quit
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
