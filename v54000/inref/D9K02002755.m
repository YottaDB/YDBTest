; D9K02-002755 $Quit not being evaluated correctly.
;
; Test $Quit under varying conditions. $Quit follows the stackframe backchain to look at the machine 
; instructions at the return point to try to determine if there is an EXFUNRET[ALS] opcode at that point.
; The instructions can vary depending on the offset of the compiler temporary mval that is passed as an
; an argument to op_exfunret[als](). We need will use code that will generate different offsets by
; forcing more compiler temps to be used at the call site.
;
	Set lasterror=""
	Do NoOffsetTest
	Do SmallOffsetTest
	Do MediumOffsetTest
	Do LargeOffsetTest
	Do CallTest
	Write "D9K02002755: ",$Select((""=lasterror):"PASS",1:"FAIL"),!
	Quit

NoOffsetTest
	Set x=$$FuncTest
	Quit

SmallOffsetTest
	For i=1:1:$$FuncTest Set x=$$FuncTest
	Quit

MediumOffsetTest
	For i=1:1:$$FuncTest For j=1:1:$$FuncTest For k=1:1:$$FuncTest For l=1:1:$$FuncTest For m=1:1:$$FuncTest Set x=$$FuncTest
	Quit

LargeOffsetTest
	For a=$$FuncTest:$$FuncTest:$$FuncTest For b=$$FuncTest:$$FuncTest:$$FuncTest For c=$$FuncTest:$$FuncTest:$$FuncTest For d=$$FuncTest:$$FuncTest:$$FuncTest For e=$$FuncTest:$$FuncTest:$$FuncTest For f=$$FuncTest:$$FuncTest:$$FuncTest For g=$$FuncTest:$$FuncTest:$$FuncTest For h=$$FuncTest:$$FuncTest:$$FuncTest For i=$$FuncTest:$$FuncTest:$$FuncTest For j=$$FuncTest:$$FuncTest:$$FuncTest For k=$$FuncTest:$$FuncTest:$$FuncTest For l=$$FuncTest:$$FuncTest:$$FuncTest For m=$$FuncTest:$$FuncTest:$$FuncTest For n=$$FuncTest:$$FuncTest:$$FuncTest For o=$$FuncTest:$$FuncTest:$$FuncTest For p=$$FuncTest:$$FuncTest:$$FuncTest For q=$$FuncTest:$$FuncTest:$$FuncTest For r=$$FuncTest:$$FuncTest:$$FuncTest For s=$$FuncTest:$$FuncTest:$$FuncTest For t=$$FuncTest:$$FuncTest:$$FuncTest For u=$$FuncTest:$$FuncTest:$$FuncTest For v=$$FuncTest:$$FuncTest:$$FuncTest For w=$$FuncTest:$$FuncTest:$$FuncTest For x=$$FuncTest:$$FuncTest:$$FuncTest For y=$$FuncTest:$$FuncTest:$$FuncTest For z=$$FuncTest:$$FuncTest:$$FuncTest For A=$$FuncTest:$$FuncTest:$$FuncTest For B=$$FuncTest:$$FuncTest:$$FuncTest For C=$$FuncTest:$$FuncTest:$$FuncTest For D=$$FuncTest:$$FuncTest:$$FuncTest For E=$$FuncTest:$$FuncTest:$$FuncTest  Set xx=$$FuncTest
	Quit

CallTest
	For a=$$FuncTest:$$FuncTest:$$FuncTest For b=$$FuncTest:$$FuncTest:$$FuncTest For c=$$FuncTest:$$FuncTest:$$FuncTest For d=$$FuncTest:$$FuncTest:$$FuncTest For e=$$FuncTest:$$FuncTest:$$FuncTest For f=$$FuncTest:$$FuncTest:$$FuncTest For g=$$FuncTest:$$FuncTest:$$FuncTest For h=$$FuncTest:$$FuncTest:$$FuncTest For i=$$FuncTest:$$FuncTest:$$FuncTest For j=$$FuncTest:$$FuncTest:$$FuncTest For k=$$FuncTest:$$FuncTest:$$FuncTest For l=$$FuncTest:$$FuncTest:$$FuncTest For m=$$FuncTest:$$FuncTest:$$FuncTest For n=$$FuncTest:$$FuncTest:$$FuncTest For o=$$FuncTest:$$FuncTest:$$FuncTest For p=$$FuncTest:$$FuncTest:$$FuncTest For q=$$FuncTest:$$FuncTest:$$FuncTest For r=$$FuncTest:$$FuncTest:$$FuncTest For s=$$FuncTest:$$FuncTest:$$FuncTest For t=$$FuncTest:$$FuncTest:$$FuncTest For u=$$FuncTest:$$FuncTest:$$FuncTest For v=$$FuncTest:$$FuncTest:$$FuncTest For w=$$FuncTest:$$FuncTest:$$FuncTest For x=$$FuncTest:$$FuncTest:$$FuncTest For y=$$FuncTest:$$FuncTest:$$FuncTest For z=$$FuncTest:$$FuncTest:$$FuncTest For A=$$FuncTest:$$FuncTest:$$FuncTest For B=$$FuncTest:$$FuncTest:$$FuncTest For C=$$FuncTest:$$FuncTest:$$FuncTest For D=$$FuncTest:$$FuncTest:$$FuncTest For E=$$FuncTest:$$FuncTest:$$FuncTest  Do NonFuncTest Write ""	; Forms a similar instruction stream to EXFUNRET - test non-confusion scenario..
	Quit

FuncTest()
	If 1'=$Quit Do
	. Set currenterror=$Stack($Stack(-1)-2,"PLACE")
	. If (currenterror'=lasterror) Write "$QUIT is not appropriately set for call from ",$Stack($Stack(-1)-1,"PLACE")," - EPIC FAIL !!!!",! ZWrite
	. Set lasterror=currenterror
	Quit 1

NonFuncTest
	If 0'=$Quit Set lasterror=1 Write "Failure in non-function version",!
	Quit
