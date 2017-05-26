;
; Execute the example cases defined in the tech spec
;
	Write !,!,"******* Start of ",$Text(+0)," *******",!,!

	; Build list of cases and run them
	Set caselist="basecase newvardel alsprskill destructall destnewscp alcnocroot alcchgdesc alcvalngraph varoneval morcmplxex"
	Set caselist=caselist_" zwrxmpl1 zwrxmpl2 tstartxmpl1 tstartxmpl2 tstartxmpl3 tstartxmpl4 tstartxmpl5"
	W !,"--------------------------",!
	For i=1:1:$Length(caselist," ") Do
	. Set casename=$Piece(caselist," ",i)
	. Kill *	; Rid the world of aliases prior to new case
	. Write "Test case: ",casename,!
	. Do @casename

	Write !,!,"******* Finish ",$Text(+0)," *******",!,!
	Quit


TRAPUNDEF	
	Write !
	If (+$ZSTATUS)'=150373850 ZShow "*" Halt
	Write "Expected undefined local variable error occured",!
	W "--------------------------",!
	Quit


;-----------------------------------
basecase	; Base case
	W "Base case:",!
	New X,Y
	Set X="foo",Y="bar"
	Do XYZ1
	Write X
	W !,"--------------------------",!
	Quit
XYZ1
	Set *X=Y	; X, Y are now bound to "bar"
	Write X
	Quit


;-----------------------------------
; New'd variable goes away on exit
newvardel
	W "New'd var goes away on exit:",!
	New X,Y
	Set X="foo",Y="bar"
	Do XYZ2
	Write X
	W !,"--------------------------",!
	Quit
XYZ2
	New X
	Set *X=Y
	Write X
	Quit


;-----------------------------------
; Alias persistent through a KILL
alsprskill
	Write "Alias is persistent through a Kill:",!
	New X,Y
	Set X="foo",Y="bar"
	Do XYZ3
	Write X
	W !,"--------------------------",!
	Quit
XYZ3
	Set *X=Y
	Write X
	Kill X
	Set Y="zot"
	Quit


;-----------------------------------
; Destruction - Kill *
destructall
	Write "Destruction - KILL * :",!
	New X,Y,$ZT
	Set X="foo",Y="bar"
	Do XYZ4
	Kill *X
	Set $ZT="ZGOTO "_$ZLEVEL_":TRAPUNDEF^specexamples"
	Write Y,X
	W !,"--------------------------",!
	Quit
XYZ4
	Set *X=Y
	Write X
	Quit


;-----------------------------------
; Destruction - New may cause alias to go out of scope
destnewscp
	Write "Destruction - New may cause alias to go out of scope:",!
	New X,Y,$ZT
	Set X="foo",Y="bar"
	Do XYZ5
	Set $ZT="ZGOTO "_$ZLEVEL_":TRAPUNDEF^specexamples"
	Kill X
	Write Y,X
	W !,"--------------------------",!
	Quit
XYZ5
	New X
	Set *X=Y
	Write X
	Quit


;-----------------------------------
; Creating an alias container doesn't change the root
alcnocroot
	Write "Creating an alias container doesn't change the root:",!
	New X,Y
	Set X="foo",Y="bar"
	Do XYZ6
	Write X
	W !,"--------------------------",!
	Quit
XYZ6
	Set *X(1)=Y
	Write X
	Quit


;-----------------------------------
; Creating an alias does change descendants
alcchgdesc
	Write "Creating an alias does change descendants:",!
	New X,Y,$ZT
	Set X(1)="foo",Y="bar"
	Do XYZ7
	Write X
	Set $ZT="ZGOTO "_$ZLEVEL_":TRAPUNDEF^specexamples"
	Write X(1)
	W !,"--------------------------",!
	Quit
XYZ7
	Set *X=Y
	Write X
	Quit


;-----------------------------------
; An alias contain value is not graphic
alcvalngraph
	Write "An alias contain value is not graphic:",!
	New X,Y
	Set Y="bar"
	Do XYZ8
	W "--------------------------",!
	Quit
XYZ8
	Set *X(1)=Y
	Write "Value >>",X(1),"<<",!
	Quit


;-----------------------------------
; Variable can only have one value
varoneval
	Write "Variable can only have one value:",!
	New X,Y
	Set X(1)="foo",Y="bar"
	Do XYZ9
	W "--------------------------",!
	Quit
XYZ9
	Set *X(1)=Y
	Write "Value >>",X(1),"<<",!
	Quit


;-----------------------------------
; More complex example (with some additional coverage)
morcmplxex
	Write "More complex example (with some additional coverage):",!
	New x,y,a,b,c,i
	Set x="name level",x(1)=1,x(1,2)="1,2",x("foo")="bar"	; x is a conventional lvn
	Set *y=x						; x an y are now alias variables
	Set *a(1)=y						; a(1) is now an alias container variable
	Set b="bness",b("b")="bbness"				; b is a conventional lvn
	Set *b=a(1)						; b joins x and y as alias variables for the same data - prior b values are lost
	  							;  S *<name> is equivalent to K <name> S *<name>
	Set y("hi")="sailor"					; Assignment applies to all of {b,x,y}
	Kill b("foo")						; Kill applies to all of {b,x,y}
	Kill *x							; x is undefined and no longer an alias variable
	  							; b and y still provide access to the data
	Write a(1),"<",!					; output appears as <
	Write a(1)*3,!						; output appears as 0
	Write $Length(a(1)),!					; output appears as 0
	Set c=y,c("legs")="tars"				; c is a conventional lvn with value "name level"
 	Do sub1
 	Write $Data(c),!					; output is 1
 	Do sub2(.c)
	Set a(1)=""						; a(1) ceases to be an alias container variable - has the value ""
	Write $Data(i),!						; output is 0
	Kill *c,*y						; c and y become undefined lvns
	ZWrite b						; output is b("got")="a match"
	    							; it's no longer an alias variable as everything else has gone
	Write $ZData(b),!					; Should be 10
	Write "--------------------------",!
	Quit
sub1
	New y							; in this scope y is no longer an alias for b
	Set *y=c						; in this scope c and y are alias variables
	Kill y("legs")						; Kill apples to all of {c,y}
	Kill *y							; in this scope y is no longer an alias for c
	  							; this is really redundant as the Quit would implicitly do the same thing
	Quit
sub2(i)	
	Kill b							; data for {b,y} is gone
	  							; both are undefined, but remain alias variables
	Set *c=a(1)						; c and i join b an y as alias variables
	  							; i and c are joined by matching pass-by-reference
								; prior values of c and i are lost
	Set i=a(1)						; Assignment applies to all of {b,c,i,y) - value is ""
	Set c("got")="a match"					; Assignment applies to all of {b,c,i,y)
	Quit 	      						; i goes out of scope as an alias variable


;-----------------------------------
; ZWrite example:
zwrxmpl1
	Write "ZWrite example:",!
	New a,b,caselist,casename,i
	Set a=22
	Set *b(1)=a
	Kill *a
	ZWrite
	Write "--------------------------",!
	Quit


;-----------------------------------
; ZWrite more complex example
zwrxmpl2
	Write "ZWrite more complex example:",!
	New a,b,c,d,x,caselist,casename,i
	Set *a=b
	Set b(1)="foo"
	Set *c("bar")=b
	Set *d(1)=x
	Set x("bar")="1|2|3|",x("bar",1)="Mrs. Jones" Kill *x
	Set x(5000)="where's the beef?"
	Set *d(2)=x 
	Kill *x
	ZWrite
	Write "--------------------------",!
	Quit


;-----------------------------------
; TStart data only example
tstartxmpl1
	Write "TStart data only example:",!
	New A,B,C,FOO,caselist,casename,i
	Set A(1)="I"
	Set A(2)="DON'T"
	Set A(3)="CARE"
	Set *B=A
	; Two aliases pointing to the array "I", "DON'T", "CARE"
	TStart (A)    	       ; A is named, B is not
	Write !,B(2)	       	; always produces: "DON'T"
	Set B(2)="DO"		; this sets A(2) to DO also
	TRestart:$Increment(FOO)<2
	TRollback
	Write !,"--------------------------",!
	Quit


;-----------------------------------
; TStart data and alias example
tstartxmpl2
	Write "TStart data and alias example:",!
	New A,B,FOO,caselist,casename,i
	Set A(1)="I"
	Set A(2)="DON'T"
	Set A(3)="CARE"
	Set *B=A
	Set C(1)="WELL"
	Set C(2)="ME"
	Set C(3)="NEITHER"
	TStart (A)
	Write !,A(2)		; always produces: "DON'T"
	Set *A=C		 ; alias change to a RESTART variable; a KILL * here would also be undone
	TRestart:$Increment(FOO)<2
	TRollback
	Write !,"--------------------------",!
	Quit


;-----------------------------------
; TStart data but not alias example
tstartxmpl3
	Write "TStart data but not alias example:",!
	New A,B,C,FOO,caselist,casename,i
	Set A(1)="I"
	Set A(2)="DON'T"
	Set A(3)="CARE"
	Set *B=A
	Set C(1)="WELL"
	Set C(2)="ME"
	Set C(3)="NEITHER"
	TStart (A)
	Write !,B(2)	; first produces: "DON'T" then "ME"
	Set B(2)="DO"	; this sets A(2) to DO also
	Set *B=C	; alias change to a variable outside the RESTART set; a KILL * here would persist as well
	TRestart:$Increment(FOO)<2
	TRollback
	Write !,"--------------------------",!
	Quit
	

;-----------------------------------
; TStart - another data but not alias example
tstartxmpl4
	Write "TStart - another data but not alias example:",!
	New A,B,C,FOO,caselist,casename,i
	Set A(1)="I"
	Set A(2)="DON'T"
	Set A(3)="CARE"
	Set C(1)="WELL"
	Set C(2)="ME"
	Set C(3)="NEITHER"
	TSTART (A)
	Write !,C(2)	; first produces: "ME" then "DON'T"
	Set *C=A	; alias change to a variable outside the RESTART set 
	TRestart:$Increment(FOO)<2
	TRollback
	Write !,"--------------------------",!
	Quit
	

;-----------------------------------
; Protected alias with associated container example
tstartxmpl5
	Write "Protected alias with associated container example:",!
	New A,B,C,FOO,caselist,casename,i
	Set A(1)="I"
	Set A(2)="DON'T"
	Set A(3)="CARE"
	Set *A(4)=C
	Set C(1)="WELL"
	Set C(2)="ME"
	Set C(3)="NEITHER"
	Write !,"Refcnt for A: ",$View("LV_REF","A"),"  Refcnt for B: ",$View("LV_REF","B"),"  Refcnt for C: ",$View("LV_REF","C"),!
	TStart (A,C)
	Set *B=A(4)		; gives a new alias 
	Kill *A(4)		; destroys the alias container - but it's protected
	Write !,B(2)		; always produces: "ME"
	Set B(2)="DO"		; this sets C(2) to DO also
	TRestart:$Increment(FOO)<2
	TRollback
	Write !,"Refcnt for A: ",$View("LV_REF","A"),"  Refcnt for B: ",$View("LV_REF","B"),"  Refcnt for C: ",$View("LV_REF","C"),!
	Write !,"--------------------------",!
	Quit
