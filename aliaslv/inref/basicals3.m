;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test additional basic alias-return aspects of alias support [C9J12-003217]
;
; Test combinations of:
;   1) Quit *x	         Alias return argument
;   2) Quit *y(1)        Alias container return argument
;   3) Target of alias.
;   4) Target of container.
;   5) Internal and external routines.
;   6) Quit arguments in same symtab as target or in different symtab.
;
; Additional tests:
;   a) Test $QUIT under various conditions:
;      i)    Routine with no argument return expected
;      ii)   Routine with non-alias argument expected
;      iii)  Routine with alias argument expected
;      iv)   For all 3 of above, both from the routine itself and from an indirect called from the routine.
;   b) Create a simplistic doubly linked list of nodes using aliases which involves exclusive NEW
;      and proper updates to aliased passthru vars.
;   c) Using the linked list test, perform a storage leak test executing the linkedistest many times and
;      checking that our storage use has not increased.
;
	Write !!,"******* Start ",$Text(+0)," *******",!!

	Write "----------",!
	Write "Test of Set *x=$$funcals() with Quit *y "
	Kill  Kill *
	Set *x=$$funcals(0)
	Write "Refcnt  x: ",$View("LV_REF","x"),!
	Write "CRefcnt x: ",$View("LV_CREF","x"),!
	ZWrite

	Write "----------",!
	Write "Test of Set *x=$$funcals() with Quit *y "
	Kill  Kill *
	Set *x=$$funcals(1)
	Write "Refcnt  x: ",$View("LV_REF","x"),!
	Write "CRefcnt x: ",$View("LV_CREF","x"),!
	ZWrite

	Write "----------",!
	Write "Test of Set *x=$$funcals^basicals3funcs() with Quit *y "
	Kill  Kill *
	Set *x=$$funcals^basicals3funcs(0)
	Write "Refcnt  x: ",$View("LV_REF","x"),!
	Write "CRefcnt x: ",$View("LV_CREF","x"),!
	ZWrite

	Write "----------",!
	Write "Test of Set *x=$$funcals^basicals3funcs() with Quit *y "
	Kill  Kill *
	Set *x=$$funcals^basicals3funcs(1)
	Write "Refcnt  x: ",$View("LV_REF","x"),!
	Write "CRefcnt x: ",$View("LV_CREF","x"),!
	ZWrite

	Write "----------",!
	Write "test of Set *x=$$funcalsct() with Quit *z(1) "
	Kill  Kill *
	Set *x=$$funcalsct(0)
	Write "Refcnt  x: ",$View("LV_REF","x"),!
	Write "CRefcnt x: ",$View("LV_CREF","x"),!
	ZWrite

	Write "----------",!
	Write "test of Set *x=$$funcalsct() with Quit *z(1) "
	Kill  Kill *
	Set *x=$$funcalsct(1)
	Write "Refcnt  x: ",$View("LV_REF","x"),!
	Write "CRefcnt x: ",$View("LV_CREF","x"),!
	ZWrite

	Write "----------",!
	Write "test of Set *x=$$funcalsct^basicals3funcs() with Quit *z(1) "
	Kill  Kill *
	Set *x=$$funcalsct^basicals3funcs(0)
	Write "Refcnt  x: ",$View("LV_REF","x"),!
	Write "CRefcnt x: ",$View("LV_CREF","x"),!
	ZWrite

	Write "----------",!
	Write "test of Set *x=$$funcalsct^basicals3funcs() with Quit *z(1) "
	Kill  Kill *
	Set *x=$$funcalsct^basicals3funcs(1)
	Write "Refcnt  x: ",$View("LV_REF","x"),!
	Write "CRefcnt x: ",$View("LV_CREF","x"),!
	ZWrite

	Write "----------",!
	Write "test of Set *x(1)=$$funcals() with Quit *y "
	Kill  Kill *
	Set *x(1)=$$funcals(0)
	Set *z=x(1)
	Kill x
	Write "Refcnt  z: ",$View("LV_REF","z"),!
	Write "CRefcnt z: ",$View("LV_CREF","z"),!
	ZWrite

	Write "----------",!
	Write "test of Set *x(1)=$$funcals() with Quit *y "
	Kill  Kill *
	Set *x(1)=$$funcals(1)
	Set *z=x(1)
	Kill x
	Write "Refcnt  z: ",$View("LV_REF","z"),!
	Write "CRefcnt z: ",$View("LV_CREF","z"),!
	ZWrite

	Write "----------",!
	Write "test of Set *x(1)=$$funcals^basicals3funcs() with Quit *y "
	Kill  Kill *
	Set *x(1)=$$funcals^basicals3funcs(0)
	Set *z=x(1)
	Kill x
	Write "Refcnt  z: ",$View("LV_REF","z"),!
	Write "CRefcnt z: ",$View("LV_CREF","z"),!
	ZWrite

	Write "----------",!
	Write "test of Set *x(1)=$$funcals^basicals3funcs() with Quit *y "
	Kill  Kill *
	Set *x(1)=$$funcals^basicals3funcs(1)
	Set *z=x(1)
	Kill x
	Write "Refcnt  z: ",$View("LV_REF","z"),!
	Write "CRefcnt z: ",$View("LV_CREF","z"),!
	ZWrite

	Write "----------",!
	Write "test of Set *x(1)=$$funcalsct() with Quit *z(1) "
	Kill  Kill *
	Set *x(1)=$$funcalsct(0)
	Set *z=x(1)
	Kill x
	Write "Refcnt  z: ",$View("LV_REF","z"),!
	Write "CRefcnt z: ",$View("LV_CREF","z"),!
	ZWrite

	Write "----------",!
	Write "test of Set *x(1)=$$funcalsct() with Quit *z(1) "
	Kill  Kill *
	Set *x(1)=$$funcalsct(1)
	Set *z=x(1)
	Kill x
	Write "Refcnt  z: ",$View("LV_REF","z"),!
	Write "CRefcnt z: ",$View("LV_CREF","z"),!
	ZWrite

	Write "----------",!
	Write "test of Set *x(1)=$$funcalsct^basicals3funcs() with Quit *z(1) "
	Kill  Kill *
	Set *x(1)=$$funcalsct^basicals3funcs(0)
	Set *z=x(1)
	Kill x
	Write "Refcnt  z: ",$View("LV_REF","z"),!
	Write "CRefcnt z: ",$View("LV_CREF","z"),!
	ZWrite

	Write "----------",!
	Write "test of Set *x(1)=$$funcalsct^basicals3funcs() with Quit *z(1) "
	Kill  Kill *
	Set *x(1)=$$funcalsct^basicals3funcs(1)
	Set *z=x(1)
	Kill x
	Write "Refcnt  z: ",$View("LV_REF","z"),!
	Write "CRefcnt z: ",$View("LV_CREF","z"),!
	ZWrite

	Write "----------",!
	; This test is a bit different and makes sure the xnew return and alias return play well with each other.
	Write "test of returning alias to pass'd through NEW element",!
	Kill  Kill *
	Set *x=y
	Set *z=$$funcalsnew1()
	Write "Refcnt  z: ",$View("LV_REF","z"),!
	Write "CRefcnt z: ",$View("LV_CREF","z"),!
	ZWrite

	Write "----------",!
	; make sure associations that are not supposed to coexist don't
	Write "test of returning alias to pass'd through NEW element",!
	Kill  Kill *
	Set *x=y
	Set *z=$$funcalsnew2()
	Write "Refcnt  z: ",$View("LV_REF","z"),!
	Write "CRefcnt z: ",$View("LV_CREF","z"),!
	ZWrite

	Write "----------",!
	; Test $Quit in routines that do not return a value, return a non-alias value, and return an alias value
	Kill  Kill *
	Do funcnoretval()
	Write "--",!
	Set x=$$funcnonaliasretval()
	Write "Non-alias return value: ",x,!,"--",!
	Set *x=$$funcaliasretval()
	Write "Alias return value: ",x,!

	Write "----------",!
	; Test for NO error with routine returning a non-existant alias (does not generate an error because it just
	; creates the alias).
	Kill  Kill *
	Set lvl=$ZLevel
	Set $ETrap="Do errorcheck("""",lvl,""resumelbl1"")"
	Set *x=$$funcbadals(.errorok)
resumelbl1
	ZWrite
	Set $ETrap=""
	Write:(0<$Data(errorok)) "FAIL: Error for return of non-existant alias incorrectly invoked",!
	Write:(0=$Data(errorok)) "SUCCESS: Error for return of non-existant alias was NOT invoked",!

	Write "----------",!
	; Test for error with routine returning a non-existant alias container
	Kill  Kill *
	Set lvl=$ZLevel
	Set $ETrap="Do errorcheck(""LVUNDEF"",lvl,""resumelbl2"")"
	Set *x=$$funcbadalsct(.errorok)
resumelbl2
	Set $ETrap=""
	Write:(0<$Data(errorok)) "Error for return of non-existant alias container correctly invoked",!
	Write:(0=$Data(errorok)) "FAIL: Error for return of non-existant alias container was NOT invoked",!

	Write "----------",!
	; Now create the equivalent of a doubly linked list (sorted) of random values then use
	; the list to print the results
	Write "Linked list test"
	Kill  Kill *
	Do linkedlisttest(100)
	; Now dump the list of sorted elements
	Set *currelem=anchor("next")
	Set done=0
	For i=1:1 Quit:($ZAHandle(currelem)=$ZAHandle(anchor))!done  Do
	. If (i>9)!(i=1) Set i=1 Write !,"Links: "
	. Set *itm=currelem("itm")
	. Write " ",currelem,"(itm=",itm,")"
	. Set *currelem=currelem("next")

	Write !,"----------",!
	; Now run the linked test repeatedly doing an lv_val garbage collection between each one
	; and verify we don't expand our storage usage.
	Kill itm,*itm,currelem,*currelem
	Set startmem=$ZRealStor
	For ii=1:1:500 Do
	. Kill anchor Kill *anchor	; With the dual pointers, this does not release the list so need an LV_GCOL to do that
	. View "LV_GCOL"   		; This releases the actual list
	. Do linkedlisttest(100)
	Set endmem=$ZRealStor
	If endmem'=startmem Write "** Storage leak test has failed - storage increased by ",endmem-startmem," bytes **",!
	Else  Write "Storage leak test successful",!

	Write !,"----------",!
	Write !!,"******* Finish ",$Text(+0)," *******",!!

	Quit

	; Function to return an alias array doing full NEW (handled as exclusive new with null list) or just new the working vars.
funcals(newall)
	If 'newall New y Write "(New only working vars)",!
	If newall New  Write "(New all vars)",!
	Set y(1)=1
	Set y(2)=2
	Quit *y

	; Same as funcals() except returns a container directly.
funcalsct(newall)
	If 'newall New y,z Write "(New only working vars)",!
	If newall New  Write "(New all vars)",!
	Set y(1)=11
	Set y(2)=22
	Set *z(1)=y
	Quit *z(1)

	; Exclusive new test function 1 (return exclusive new passthru var)
funcalsnew1()
	New (x)
	Set x=42,y=24
	Quit *x

	; Exclusive new test function 2 (return var other than pass thru var)
funcalsnew2()
	New (x)
	Set x=42,y=24
	Quit *y

	; Routine to test $QUIT in a no-return-value situation
funcnoretval()
	New
	Write "Initial value of $Quit in no-return-value routine: ",$Quit,!
	Set xx="y=$Quit"
	Set @xx
	Write "Indirect reference value of $Quit in no-return-value routine: ",y,!
	Quit

	; Routine to test $QUIT in a non-alias-return-value situation
funcnonaliasretval()
	New
	Write "Initial value of $Quit in non-alias-return-value routine: ",$Quit,!
	Set xx="y=$Quit"
	Set @xx
	Write "Indirect reference value of $Quit in non-alias-return-value routine: ",y,!
	Set xx="a+1",a=42
	Quit @xx

	; Routine to test $QUIT in an alias-return-value situation
funcaliasretval()
	New
	Write "Initial value of $Quit in alias-return-value routine: ",$Quit,!
	Set xx="y=$Quit"
	Set @xx
	Write "Indirect reference value of $Quit in alias-return-value routine: ",y,!
	Set xx="*a",a=42
	Quit @xx

	; Routine to test error when return non-existant alias
funcbadals(errflg)
	Quit *c

	; Routine to test error when return non-existant alias container
funcbadalsct(errflg)
	Quit *c(2242)

	; Routine to perform check that we got the error we expected
errorcheck(experr,lvl,resumelabel)
	New $ETrap Set $ETrap=""
	Set errname=$ZPiece($ZStatus,"YDB-E-",2),errname=$ZPiece(errname,",",1)
	If errname=experr Set $ECode="",errflg=1 ZGoto lvl:@resumelabel
	; Else things didn't match and that's a problem..
	Write "FAIL - error did not match - expected: ",experr," but got ",errname,!
	ZShow "*"
	Halt

	; Routine to create a linked list of maxelem elements
linkedlisttest(maxelem)
	New i,x
	Set *anchor("next")=anchor	; Init doubly linked list for this initial element
	Set *anchor("prev")=anchor	; Note value not set since is irrelevant and should not be used
	For i=1:1:maxelem Do
	. Set *x=$$getnewelem()
	. Do addelem(.x,i)
	. Kill *x			; Get rid of singluar reference to one of the array  elements so counts can be verified
	. Do verifyqueue
	Quit

	; Function to allocate a new linked-list element with a random value
getnewelem()
	New
	Set newelm=$Random(1000)
	Quit *newelm

	; Add given element to queue so that its primary value is sorted.
addelem(newelem,order)
	New (anchor,newelem,order)	; Fun with exclusive new passing new element plus chain through
	; Add an "auxilliary component" to the new element -- basically a 2ndary new element that will need to be
	; resolved via the exclusive new unwind logic. The value will the order the element was allocated in
	; (i.e. the "item" number).
	Set auxelem=order
	Set *newelem("itm")=auxelem
	; Find where to insert on the chain
	Set *currelem=anchor("next")
	Set done=0
	For  Quit:($ZAHandle(currelem)=$ZAHandle(anchor))!done  Do
	. If newelem<currelem Set done=1 Quit
	. Set *currelem=currelem("next")
	; Insertion point determined - insert just prior to currelem
	Set *newelem("next")=currelem
	Set *newelem("prev")=currelem("prev")
	Set *prevelem=newelem("prev")
	Set *prevelem("next")=newelem
	Set *currelem("prev")=newelem
	Quit

	; Verify all is well with the queue. Note the total refcount we check in this routine is 1 higher than it would
	; otherwise be due to this routine's own necessary reference to the element.
verifyqueue
	New currelem,done,i,faillvref,failvcref
	Set *currelem=anchor("next")
	Set done=0
	For i=1:1 Quit:($ZAHandle(currelem)=$ZAHandle(anchor))!done  Do
	. If ($View("LV_REF","currelem")'=3)!($View("LV_CREF","currelem")'=2) Do
	. . Set faillvref=$View("LV_REF","currelem"),faillvcref=$View("LV_CREF","currelem")
	. . Write !!,"Incorrect reference count(s) for element with value",currelem,! Set done=1 ZShow "*" Halt
	. Set *currelem=currelem("next")
