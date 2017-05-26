mbyexam; Borrowed from Jacquard Systems Research
	KILL ^A,^B
	W "STEP 1",!
	SET ^A(1,2)="First"
	SET ^A(1,2,4)="Second"
	SET ^B(5,6,7)="Third"
	SET ^B(5,6,8)="Fourth"
	SET ^B(5,6,7,8,1)="Fifth"
	SET ^B(5,6,7,8,9)="Sixth"
	MERGE ^A(1,2)=^B(5,6,7) 
	;^A(1,2)="Third"
	;^A(1,2,4)="Second"
	;^A(1,2,8,1)="Fifth"
	;^A(1,2,8,9)="Sixth"
	ZWR ^A
	; Result
	;
	W "STEP 2",!
	MERGE ^A(1,2,3)=^B(5,6,7,8) 
	;^A(1,2)="Third"
	;^A(1,2,3,1)="Sixth"
	;^A(1,2,3,9)="Fifth"
	;^A(1,2,4)="Second"
	;^A(1,2,8,1)="Fifth"
	;^A(1,2,8,9)="Sixth"
	ZWR ^A
	; Result

	;KILL TMP
	;SET TMP("GLOBAL")="TESTGENV"
	;SET TMP("ROUTINE")="TESTRENV"
	;SET TMP("LOCK")="TESTGENV"
	;MERGE ^JOB($JOB)=TMP
	;ZWR ^JOB

	;
	W "STEP 3",!
	K ^ABC
	SET ^ABC(1,5,6)="PASSVAL"
	SET ^ABC(1,5,3,4)="FAILVAL"
	SET ^ABC(1,2)="reset naked indicator"
	; Naked indicator is now ^ABC(1,
	MERGE ^(3,4)=^(5,6)
	; Pretend SET ^(3,4)=^(5,6) is executed
	; 1. fetch ^(5,6) = ^ABC(1,5,6)
	; 2. store ^(3,4) = ^ABC(1,5,3,4)
	; Naked indicator is now: ^ABC(1,5,3,
	S ^("TESTNAKED")="OK"
	IF ^ABC(1,5,3,"TESTNAKED")'="OK"  W "FAIL",!
	ELSE  ZWR ^ABC
	Q
