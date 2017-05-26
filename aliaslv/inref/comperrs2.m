; Alias runtime error tests - Verify expected errors are raised in various conditions.

	Write !!,"******* Start ",$Text(+0)," *******",!!

	Set errorcnt=0,done=0
	For i=1:1:999 Do  Quit:done
	. Set test=$Text(@("statements+"_i_"^comperrs2"))
	. If test=";" Set done=1 Quit	; Exit loop
	. Set stmt=$Piece(test,";",2)
	. Set experr=$Piece(test,";",3)
	. Do stmtchk(stmt,experr)
	Write "comperrs2: Testing ",i-1," statements: ",$Select((errorcnt=(i-1)):"PASS",1:"FAIL"),!
	Write !!,"******* Finish ",$Text(+0)," *******",!!
	Quit

	; Execute provided statement
stmtchk(stmt,expectederror)
  	Set $ETrap="Do stmtchkeh"
	Xecute stmt
	If $ZStatus="" Write "Statement returned without error! FAIL!!",! ZShow "*" Halt
	Quit

	; Provide verification the correct error occurred, then return to caller to continue tests
stmtchkeh
	Set errorcnt=errorcnt+1 
	Set error=$Piece($Piece($ZStatus,",",3),"-",3)
	If error'=expectederror Do
	. Write "For statement ",stmt," got error ",error," instead of expected error ",expectederror,!
	. Set errorcnt=errorcnt+1
	Set $ECode=""
	Quit

	; Don't return an alias when one is expected
funcnoals() Quit 1

	; Return an alias when one is not expected
funcals()
	New
	Set a=1
	Quit *a

	; List of statements and the expected errors:
statements
;	Set x=$VIEW("LV_REF","@*")	;VIEWLVN
;	Set *x=$$funcnoals()		;ALIASEXPECTED
;	Set y=$$funcals()		;QUITALSINV
;	Set *x(1)=$$funcnoals()		;ALIASEXPECTED
;	Set y(1)=$$funcals()		;QUITALSINV
;
