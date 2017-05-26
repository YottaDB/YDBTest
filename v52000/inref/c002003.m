c002003	;
	; C9C95-002003 Set $PIECE/$EXTRACT give error if part of a compound SET statement
	;
	; At a high level, this program tests that SET $PIECE/$EXTRACT work if specified as part of a compound SET.
	;
	set echostr="----------------------------------------------------------------------"
	do ^sstep
	;
	write echostr,!
	set tststr="Test 1 : Compound SET with a setleft target that is a subscript in ONE other target"
	set a=0,(a,array(a))=1
	zwrite a,array
	kill a,array
	set ^a=0,(^a,^array(^a))=1
	zwrite ^a,^array
	kill ^a,^array
	;
	write echostr,!
	set tststr="Test 2 : Compound SET with a setleft target that is a subscript in TWO other targets"
	set a=0,(a,array1(a),array2(a))=2
	zwrite a,array1,array2
	kill a,array1,array2
	set ^a=0,(^a,^array1(^a),^array2(^a))=2
	zwrite ^a,^array1,^array2
	kill ^a,^array1,^array2
	;
	write echostr,!
	set tststr="Test 3 : Compound SET with subscripted setleft target that is a subscript in multiple targets"
	set (a,b,c,d)=1,a(a,b)=1,a(c,d)=1,d(1)=2
	set (a,b,a(a,b),c,d,a(c,d),d(a(c,d)))=3
	zwrite a,b,c,d
	kill a,b,c,d
	set (^a,^b,^c,^d)=1,^a(^a,^b)=1,^a(^c,^d)=1,^d(1)=2
	set (^a,^b,^a(^a,^b),^c,^d,^a(^c,^d),^d(^a(^c,^d)))=3
	zwrite ^a,^b,^c,^d
	kill ^a,^b,^c,^d
	;
	write echostr,!
	set tststr="Test 4 : Compound SET with $PIECE/$EXTRACT as a setleft target"
  	set a=0,b="a|b|c|d",(a,$piece(b,"|",2))=1
	zwrite a,b
	kill a,b
  	set a=0,^b="a|b|c|d",(a,$piece(^b,"|",2))=1
	zwrite a,^b
	kill a,^b
  	set a=0,b="a|b|c|d",(a,$extract(b,2))=1
	zwrite a,b
	kill a,b
  	set a=0,^b="a|b|c|d",(a,$extract(^b,2))=1
	zwrite a,^b
	kill a,^b
	;
	write echostr,!
	set tststr="Test 5 : Compound SET with $PIECE/$EXTRACT as a setleft using a subscript that is yet another setleft target"
  	set a=0,b(0)="a|b|c|d",(a,$piece(b(a),"|",2))=1
	zwrite a,b
	kill a,b
  	set ^a=0,^b(0)="a|b|c|d",(^a,$piece(^b(^a),"|",2))=1
	zwrite ^a,^b
	kill ^a,^b
  	set a=0,b(0)="a|b|c|d",(a,$extract(b(a),2))=1
	zwrite a,b
	kill a,b
  	set ^a=0,^b(0)="a|b|c|d",(^a,$extract(^b(^a),2))=1
	zwrite ^a,^b
	kill ^a,^b
	;
	write echostr,!
	set tststr="Test 6 : Compound SET with $PIECE/$EXTRACT as a setleft having last argument that is in turn a setleft target"
	set delim="b",x=1,y="abcd",(x,$piece(y,delim,x))=2
	zwrite delim,x,y
	kill delim,x,y
	set ^delim="b",^x=1,^y="abcd",(^x,$piece(^y,^delim,^x))=2
	zwrite ^delim,^x,^y
	kill ^delim,^x,^y
	set delim="b",x=1,y="abcd",(x,$extract(y,x))=2
	zwrite delim,x,y
	kill delim,x,y
	set ^delim="b",^x=1,^y="abcd",(^x,$extract(^y,^x))=2
	zwrite ^delim,^x,^y
	kill ^delim,^x,^y
	;
	write echostr,!
	set tststr="Test 7 : Compound SET with $PIECE/$EXTRACT as a setleft having subscripted last argument that is in turn a setleft target"
	set delim="b",x=1,x(1)=1,x(2)=2,y="abcd",(x,$piece(y,delim,x(x)))=2
	zwrite delim,x,y
	kill delim,x,y
	set ^delim="b",^x=1,^x(1)=1,^x(2)=2,^y="abcd",(^x,$piece(^y,^delim,^x(^x)))=2
	zwrite ^delim,^x,^y
	kill ^delim,^x,^y
	set delim="b",x=1,x(1)=1,x(2)=2,y="abcd",(x,$extract(y,x(x)))=2
	zwrite delim,x,y
	kill delim,x,y
	set ^delim="b",^x=1,^x(1)=1,^x(2)=2,^y="abcd",(^x,$extract(^y,^x(^x)))=2
	zwrite ^delim,^x,^y
	kill ^delim,^x,^y
	;
	write echostr,!
	set tststr="Test 8 : Compound SET with $PIECE/$EXTRACT as setleft using global variable target should not touch naked indicator if first > last"
	set ^y="efgh",^x="abcd"
	set $piece(^x,"2",3,2)=^y	; should set $reference to ^y and not ^x 
	write "$reference=",$reference,!
	zwrite ^x,^y
	kill ^x,^y
	set ^y="efgh",^x="abcd"
	set $extract(^x,3,2)=^y		; should set $reference to ^y and not ^x 
	write "$reference=",$reference,!
	zwrite ^x,^y
	kill ^x,^y
	;
	write echostr,!
	set tststr="Test 9 : Compound SET with $PIECE/$EXTRACT as setleft using global variables in all arguments should not touch naked indicator if first > last"
	set ^a=5,^b=2,^y=2
	set $piece(^x,"a",^a,^b)=^y	; should set $reference to ^y and not ^x 
	write "$reference=",$reference,!
	zwrite ^a,^b,^y
	kill ^a,^b,^y
	set ^a=5,^b=2,^y=2
	set $extract(^x,^a,^b)=^y	; should set $reference to ^y and not ^x 
	write "$reference=",$reference,!
	zwrite ^a,^b,^y
	kill ^a,^b,^y
	;
	write echostr,!
	set tststr="Test 10 : Compound SET with null $PIECE/$EXTRACT as setleft should branch around to next LHS target in the compound SET"
	set (x,$piece(y," ",3,2),z)=3	; this $piece is null because 3 > 2 so it should not change y at all.
	zwrite x,z
	kill x,z
	set (^x,$piece(^y," ",3,2),^z)=3 ; this $piece is null because 3 > 2 so it should not change ^y at all.
	zwrite ^x,^z
	kill ^x,^z
	set (x,$extract(y,3,2),z)=3	; this $extract is null because 3 > 2 so it should not change y at all.
	zwrite x,z
	kill x,z
	set (^x,$extract(^y,3,2),^z)=3	; this $extract is null because 3 > 2 so it should not change ^y at all.
	zwrite ^x,^z
	kill ^x,^z
	;
	write echostr,!
	set tststr="Test 11 : Same as Test 10 but with global variables instead so naked indicator is checked as well"
	set ^a=1,(^x,$piece(^y," ",3,2),z)=^a	; this $piece is null because 3 > 2 so it should not touch ^y at all.
	write "$reference=",$reference,!	; should set $reference to ^x
	zwrite ^a,^x,z
	kill ^a,^x,z
	set ^a=1,(^x,$extract(^y,3,2),z)=^a	; this $extract is null because 3 > 2 so it should not touch ^y at all.
	write "$reference=",$reference,!	; should set $reference to ^x
	zwrite ^a,^x,z
	kill ^a,^x,z
	;
	write echostr,!
	set tststr="Test 12 : Variation on Test 10 with multiple $PIECE/$EXTRACT within a compound SET"
	set (x,$piece(y," ",3,2),z,$piece(k," ",5,3),m)=3
	zwrite x,z,m
	kill x,z,m
	set (x,$extract(y,3,2),z,$extract(k,5,3),m)=3
	zwrite x,z,m
	kill x,z,m
	set (x,$piece(y,3,2),z,$extract(k,5,3),m)=3
	zwrite x,z,m
	kill x,z,m
	set x=1,z(1)=2,(x,$extract(y,3,2),z(x),$piece(k,5,3),m(z(x)))=3
	zwrite x,z,m
	kill x,z,m
	set (^x,$piece(^y," ",3,2),^z,$piece(^k," ",5,3),^m)=3
	zwrite ^x,^z,^m
	kill ^x,^z,^m
	set (^x,$extract(^y,3,2),^z,$extract(^k,5,3),^m)=3
	zwrite ^x,^z,^m
	kill ^x,^z,^m
	set (^x,$piece(^y,3,2),^z,$extract(^k,5,3),^m)=3
	zwrite ^x,^z,^m
	kill ^x,^z,^m
	set ^x=1,^z(1)=2,(^x,$extract(^y,3,2),^z(^x),$piece(^k,5,3),^m(^z(^x)))=3
	zwrite ^x,^z,^m
	kill ^x,^z,^m
	;
	quit
