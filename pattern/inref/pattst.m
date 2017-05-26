pattst	; Test of MUMPS pattern match operator

	New
	;;Do begin^header($TEXT(+0))
	Set errcnt=$Get(errcnt)

	Write "Test of MUMPS pattern match operator",!
	Set ITEM="pattern match "

	Set X="L|873|*A|1,12|123HE.123|123HE|123H,&ADE|123|1234|12345HE.00K"

	Set R(1,"1U")="1 0 0 0 0 0 0 0 0 0"
	Set R(1,"3N")="0 1 0 0 0 0 0 1 0 0"
	Set R(1,"2P")="0 0 0 0 0 0 0 0 0 0"
	Set R(1,"4L")="0 0 0 0 0 0 0 0 0 0"
	Set R(1,"1""1234""")="0 0 0 0 0 0 0 0 1 0"
	Set R(1,"3N1""H""")="0 0 0 0 0 0 0 0 0 0"
	Set R(1,"1.3N1P.2N")="0 0 0 1 0 0 0 0 0 0"
	Set R(1,".E.N")="1 1 1 1 1 1 1 1 1 1"

	Set errstep=errcnt
	Set p="" For  Set p=$Order(R(1,p)) Quit:p=""  Do match(1,p)
	If errstep=errcnt Write "a  PASS",!

	Set R(2,"1.AN1""HE""1P.N")="0 0 0 0 1 0 0 0 0 0"
	Set R(2,"1.AN1.3""HE"".3N")="0 0 0 0 0 1 0 0 0 0"
	Set R(2,"3N.1""H""")="0 1 0 0 0 0 0 1 0 0"
	Set R(2,".1""1234""")="0 0 0 0 0 0 0 0 1 0"

	Set errstep=errcnt
	Set p="" For  Set p=$Order(R(2,p)) Quit:p=""  Do match(2,p)
	If errstep=errcnt Write "b  PASS",!

	Set R(3,".1""123""")="0 0 0 0 0 0 0 1 0 0"
	Set R(3,".1""123"".N")="0 1 0 0 0 0 0 1 1 0"
	Set R(3,".N1""HE"".P2N1A")="0 0 0 0 0 0 0 0 0 1"

	Set errstep=errcnt
	Set p="" For  Set p=$Order(R(3,p)) Quit:p=""  Do match(3,p)
	If errstep=errcnt Write "c  PASS",!

	Set R(4,"1n1(1a,1n,1p)1n")="0 1 0 0 0 0 0 1 0 0"
	Set R(4,"1n1(1.2a,1.2pn,1.2p)1n")="0 1 0 1 0 0 0 1 1 0"
	Set R(4,"3n1(1.2a,1.3ap,1.2p)3n")="0 0 0 0 1 0 0 0 0 0"
	Set R(4,"3n1(3a,3ap,3p)3an")="0 0 0 0 1 0 1 0 0 0"

	Set errstep=errcnt
	Set p="" For  Set p=$Order(R(4,p)) Quit:p=""  Do match(4,p)
	If errstep=errcnt Write "d  PASS",!

	Kill R,X

; Test for PER 002579:
	Set errstep=errcnt
	Set X="1234X5678"
	Xecute "Write X?.N1U.1N"		; This failed with an ACCVIO.
	If errstep=errcnt Write "e PASS - PER 002579",!

	Do  ; Alternations offer alternative patterns that each may match the string
	. New P
	. Set P("5551212")=1
	. Set P("55512x2")=0
	. Set P("555-1212")=1
	. Set P("555_1212")=1
	. Set P("555+1212")=0
	. Set P("(000)5551212")=1
	. Set P("(0x0)5551212")=0
	. Set P("(000)555-1212")=1
	. Set P("(000)555_1212")=1
	. Set P("(0.0)555_1212")=0
	. Set P("(000)-5551212")=1
	. Set P("(000)-555-1212")=1
	. Set P("(000)-555_1212")=1
	. Set P("(000)_5551212")=1
	. Set P("(000)_555-1212")=1
	. Set P("(000)_555_1212")=1
	. Set P("(000) 555 1212")=0
	. ;        1   p       p    2             21    1             1
	. Set p=".1(1""(""3N1"")"".1(1""-"",1""_""))3N.1(1""-"",1""_"")4N"
	. Set x="" For  Set x=$Order(P(x)) Quit:x=""  Do examine(x?@p,P(x),"MbE: "_x_"?"_p)
	. Quit
	If errstep=errcnt Write "f  PASS -- alternations",!

	Set X="|123|abc|12345|abc123|abcde12345prqst"
	Set R(7,"1""""")="1 0 0 0 0 0"
	Set R(7,".""""")="1 0 0 0 0 0"
	Set R(7,"5.7""""")="1 0 0 0 0 0"
	Set R(7,"5.""""")="1 0 0 0 0 0"
	Set R(7,".7""""")="1 0 0 0 0 0"
	Set R(7,"1n5.7""""2n")="0 1 0 0 0 0"
	Set R(7,"1n4.7""""2.8n")="0 1 0 1 0 0"
	Set R(7,"1a5.7""""2a")="0 0 1 0 0 0"
	Set R(7,"1a5.7""""2.8a")="0 0 1 0 0 0"
	Set R(7,"1.13an5.7""""2.10an")="0 1 1 1 1 1"
	Set R(7,".an."""".an")="1 1 1 1 1 1"

	Set errstep=errcnt
	Set p="" For  Set p=$Order(R(8,p)) Quit:p=""  Do match(4,p)
	If errstep=errcnt Write "h  PASS -- occurrences of empty string",!
	;;Do end^header($TEXT(+0))
	Quit

user(table)	; User-defined patcodes
	; The tests in this section depend on the presence of
	; a user-defined pattern code K.
	; When a table has been loaded that contains a definition
	; for this pattern code, all tests in this section should pass.
	; When no such table is loaded, some of the tests in this section
	; should produce an error with code 'PATNOTFOUND'.
	;
	; The letters that are consonants (both upper case and lower case)
	; should be defined to match pattern code K in the user-defined table.
	;
	; The name of the user-defined table is passed as a parameter
	;
	Set errcnt=$Get(errcnt),ITEM="pattern match "
	Set X="abc|abcde|klm|pqrst|ijkl|jklm"
	Set R(5,"3LK")="1 0 1 0 0 0"
	Set R(5,"3K")="0e 0e 1e 0e 0e 0e"
	Set R(5,"1.5K")="0e 0e 1e 1e 0e 1e"
	Set R(5,"4k")="0e 0e 0e 0e 0e 1e"
	Set R(5,"1k1""qr"".k")="0e 0e 0e 1e 0e 0e"
	Set R(5,"1a3K1""e""")="0e 1e 0e 0e 0e 0e"
	Set R(5,"1.3a1k.2a")="1e 1e 1e 1e 1e 1e"
	Set R(5,".E.k")="1 1 1 1 1 1"

	View "PATCODE":"M" ; Use default table, errors may occur
	Set errstep=errcnt,errok=1
	Set p="" For  Set p=$Order(R(5,p)) Quit:p=""  Do match(5,p)
	If errstep=errcnt Write "g  PASS -- user defined with M patterns",!

	View "PATCODE":table ; Use user-defined table, errors may not occur
	Set errstep=errcnt,errok=0
	Set p="" For  Set p=$Order(R(5,p)) Quit:p=""  Do match(5,p)
	If errstep=errcnt Write "h  PASS -- user defined with patterns from ",table,!

	Quit

match(s,P) New k,level,ok,text,x
	For k=1:1:$Length(X,"|") Do
	. Set x=$PIECE(X,"|",k),ok=$Piece(R(s,P)," ",k)
	. Do
	. . New $ETrap
	. . Set level=$Stack,text=ITEM_x_" ? "_P,show=1
	. . If ok["e" Set $ETrap="Goto Catch^"_$Text(+0),ok=$TRanslate(ok,"e")
	. . Do examine(x?@P,ok,text)
	. . Quit
	. Quit
	Quit

Catch	If show,$ZStatus'["-PATNOTFOUND," Do
	. Write "** FAIL  ",text,!
	. Write "   Error occurred: ",$ZSTATUS
	. Write "   CORRECT  = """,ok,"""",!
	. Quit
	Set show=0 Set:$Stack'>level $ECode=""
	Quit

examine(computed,correct,text) Quit:computed=correct
	Set errcnt=errcnt+1
	Write "** FAIL  ",text,!
	Write "   COMPUTED = """,computed,"""",!
	Write "   CORRECT  = """,correct,"""",!
	Quit
