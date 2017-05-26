tstsfex	;
	; Test the Set $Extract facility of M
	;
	Write "tstsfex starting",!

	; Most of the tests below are taken from Mumps-By-Example from Jacquard Systems

	Set X1="ABaDEFG"
	Set X2="AxxxaDEFG"
	Set X3="AEFG"
	Set X4="APQDEFG"
	Set X5="A=G"
	Set X6="A=G       PQ"
	Set X7="APQG       PQ"
	Set X8="ZzZPQG       PQ"
	Set X9="ZzZPQG   *The*End*"

	Set error=0

	SET X="ABCDEFG"
	SET $EXTRACT(X,3)="a"
	if X'=X1 D NOTEQUAL(X,X1)
	SET $EXTRACT(X,2)="xxx"
	if X'=X2 D NOTEQUAL(X,X2)
	SET $EXTRACT(X,2,6)=""
	if X'=X3 D NOTEQUAL(X,X3)

	SET X="ABCDEFG"
	SET $EXTRACT(X,2,3)="PQ"
	if X'=X4 D NOTEQUAL(X,X4)
	SET $EXTRACT(X,2,6)="="
	if X'=X5 D NOTEQUAL(X,X5)
	SET $EXTRACT(X,11,12)="PQ"
	if X'=X6 D NOTEQUAL(X,X6)
	SET $EXTRACT(X,2)="PQ"
	if X'=X7 D NOTEQUAL(X,X7)
	SET $EXTRACT(X)="ZzZ"
	if X'=X8 D NOTEQUAL(X,X8)
	Set $Extract(X,10,100)="*The*End*"
	If X'=X9 D NOTEQUAL(X,X9)
	; Test no change
	Set $Extract(X,5,1)="BLAH"
	If X'=X9 D NOTEQUAL("Blah "_X,"Blah "_X9)

	; Global versions

	Set ^X1="ABaDEFG"
	Set ^X2="AxxxaDEFG"
	Set ^X3="AEFG"
	Set ^X4="APQDEFG"
	Set ^X5="A=G"
	Set ^X6="A=G       PQ"
	Set ^X7="APQG       PQ"
	Set ^X8="ZzZPQG       PQ"
	Set ^X9="ZzZPQG   *The*End*"

	SET ^X="ABCDEFG"
	SET $EXTRACT(^X,3)="a"
	if ^X'=^X1 D NOTEQUAL(^X,^X1)
	SET $EXTRACT(^X,2)="xxx"
	if ^X'=^X2 D NOTEQUAL(^X,^X2)
	SET $EXTRACT(^X,2,6)=""
	if ^X'=^X3 D NOTEQUAL(^X,^X3)

	SET ^X="ABCDEFG"
	SET $EXTRACT(^X,2,3)="PQ"
	if ^X'=^X4 D NOTEQUAL(^X,^X4)
	SET $EXTRACT(^X,2,6)="="
	if ^X'=^X5 D NOTEQUAL(^X,^X5)
	SET $EXTRACT(^X,11,12)="PQ"
	if ^X'=^X6 D NOTEQUAL(^X,^X6)
	SET $EXTRACT(^X,2)="PQ"
	if ^X'=^X7 D NOTEQUAL(^X,^X7)
	SET $EXTRACT(^X)="ZzZ"
	if ^X'=^X8 D NOTEQUAL(^X,^X8)
	Set $Extract(^X,10,100)="*The*End*"
	If ^X'=^X9 D NOTEQUAL(^X,^X9)
	; Test no change
	Set $Extract(^X,5,1)="BLAH"
	If ^X'=^X9 D NOTEQUAL("Blah "_^X,"Blah "_^X9)

	If error=0 Write "Passed all tests",! Else  Write "Failed ",error," subtests",!
	Quit

NOTEQUAL(comp,expect)
	Write "Expected value: """,expect,"""   Computed: """,comp,"""",!
	Set error=error+1
	Quit
