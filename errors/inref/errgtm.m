ErrTrap ; Tests related to error trapping
 Quit
 ;
Z01 Write !,"This is GT.M test 1.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program aborts when an error"
 Write !,"occurs, and no error trap has been requested.",!
 Write !,"Note that the initial value of $ZTRAP is ""B"","
 Write !,"(not empty).",!
 Kill A
Bad01 Write A
 Write !,"This is not displayed."
 Quit
 ;
 ; **************************************************
 ;
Z02 Write !,"This is GT.M test 2.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ZTRAP."
 Write !,"In addition, this example shows that it is"
 Write !,"possible to resume execution of a program,"
 Write !,"after an error has been handled.",!
 Set $ZTRAP="Goto Trap01"
 Do Sub02a
 Write !,"Back from Sub02a"
 Quit
Sub02a Write !,"This is Sub02a"
 Do Sub02b
 Write !,"Back from Sub02b"
 Quit
Sub02b Write !,"This is Sub02b"
 Kill A
Bad02 Write A
 Write !,"This is not displayed."
 Quit
Trap01 Write !,"Continuing with error trap after an error."
 Write !,"Level: ",$ZLEVEL
 Set $ZTRAP="B"
 Quit
 ;
 ; **************************************************
 ;
Z03 Write !,"This is GT.M test 3.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ZTRAP."
 Write !,"In addition, this example shows that it is"
 Write !,"possible to resume execution of a program,"
 Write !,"at a specified location, after an error has"
 Write !,"been handled.",!
 Set $ZTRAP="ZGoto 2"
 Do Sub03a
 Write !,"Back from Sub03a"
 Write !,"GT.M test 3 after $ZTRAP"
 Write !,"Level: ",$ZLEVEL
 Set $ZTRAP="B"
 Quit
Sub03a Write !,"This is Sub03a."
 Do Sub03b
 Write !,"Back from Sub03b"
 Write !,"This is skipped by ZGoto."
 Quit
Sub03b Write !,"This is Sub03b."
 Kill A
Bad03 Write A
 Write !,"This is not displayed."
 Quit
 ;
 ; **************************************************
 ;
Z04 Write !,"This is GT.M test 4.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ZTRAP."
 Write !,"In addition, this example shows that it is"
 Write !,"possible handle the error at a specified"
 Write !,"execution level.",!
 Do Main04
 Write !,"This is GT.M test 4 after error."
 Write !,"Level: ",$ZLEVEL
 Quit
Main04 Write !,"This is Main04."
 Write !,"Level: ",$ZLEVEL
 Set ZL=$ZLEVEL
 Set $ZTRAP="ZG ZL:Trap04"
 Do Sub04a
 Write !,"Back from Sub04a"
 Quit
Sub04a Write !,"This is Sub04a."
 Write !,"Level: ",$ZLEVEL
 Do Sub04b
 Write !,"Back from Sub04b"
 Quit
Sub04b Write !,"This is Sub04b."
 Write !,"Level: ",$ZLEVEL
 Kill A
Bad04 Write A
 Write !,"This is not displayed."
 Quit
Trap04 Write !,"Continuing with error trap after an error."
 Write !,"Level: ",$ZLEVEL
 Set $ZTRAP="B"
 Quit
 ;
 ; **************************************************
 ;
Z05 Write !,"This is GT.M test 5.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ZTRAP."
 Write !,"In addition, this example shows that it is"
 Write !,"possible to define different error handlers"
 Write !,"for different execution levels.",!
 Write !,"Starting $ZTRAP: ",$ZTRAP
 Do Sub05a
 Write !,"Back from Sub05a"
 Write !,"Ending $ZTRAP: ",$ZTRAP
 Quit
Sub05a Write !,"This is Sub05a."
 New $ZTRAP
 Set $ZTRAP="Goto Trap05a"
 Write !,"$ZTRAP for Sub05a: ",$ZTRAP
 Kill A
Bad05 Write A
 Quit
Trap05a Write !,"Error trap 1."
 Write !,"$ZTRAP after the trap: ",$ZTRAP
 Quit
 ;
 ; **************************************************
 ;
Z06 Write !,"This is GT.M test 6.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ZTRAP."
 Write !,"In addition, this example shows that it is"
 Write !,"possible to retry execution of the code that caused"
 Write !,"the error, after the error has been handled.",!
 New $ZTRAP
 Set $ZTRAP="DO Trap06"
 Set (CB,CE)=0
 Kill A
Bad06 Set CB=CB+1 Write A Set CE=CE+1
 Write !,"Code executions on line 'Bad06' before error: ",CB
 Write !,"Code executions on line 'Bad06' after error: ",CE
 Quit
Trap06 Set A="Now local variable A is defined."
 Quit
 ;
 ; **************************************************
 ;
Z07 Write !,"This is GT.M test 7.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program aborts when an error"
 Write !,"occurs, and no error trap has been requested.",!
 Write !,"When the value of $ZTRAP is """" (empty),"
 Write !,"an error message is issued, and control returns"
 Write !,"to the operating system level shell.",!
 Set $ZTRAP=""
 Kill A
Bad07 Write A
 Write !,"This is not displayed."
 Quit
 ;
 ; **************************************************
 ;
Z08 Write !,"This is GT.M test 8.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ZTRAP."
 Write !,"In addition, this example shows that it is"
 Write !,"possible that another error may occur, before the"
 Write !,"original error is properly handled."
 Write !,"When that happens, the error trap code will be"
 Write !,"invoked again (and again, and again), until a"
 Write !,"stack overflow occurs. After the stack overflow,"
 Write !,"control is returned to the operating system level"
 Write !,"shell.",!
 Set $ZTRAP="DO Trap08"
 Kill A
Bad08 Write A
 Write !,"This is not displayed."
 Quit
Trap08 Write 2/0
 Quit
 ;
 ; **************************************************
 ;
Z09 Write !,"This is GT.M test 9.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ZTRAP."
 Write !,"In addition, this example shows that it is"
 Write !,"possible that another error may occur, before the"
 Write !,"original error is properly handled."
 Write !,"In this example, the code in the error trap routine"
 Write !,"is prepared for secondary errors, and a stack overflow"
 Write !,"is prevented.",!
 Set $ZTRAP="DO Trap09"
 Kill A
Bad09a Write A
 Write !,"This is not displayed."
 Quit
Trap09 Set $ZTRAP=""
 Write !,"This is the error trap."
Bad09b Write !,"This is an error in the error trap.",2/0
 Quit
 ;
 ; **************************************************
 ;
Z10 Write !,"This is GT.M test 10.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ZTRAP."
 Write !,"In addition, this example shows that it is"
 Write !,"possible to ignore errors.",!
 Set $ZTRAP="QUIT"
 Do Sub10a
 Write !,"Back from Sub10a"
 Quit
Sub10a Write !,"This is Sub10a"
 Do Sub10b
 Write !,"Back from Sub10b"
 Write !,"This is Sub10a after the error was 'ignored'."
 Quit
Sub10b Write !,"This is Sub10b"
 Kill A
Bad10 Write A
 Write !,"This is not displayed."
 Quit
 ;
 ; **************************************************
 ;
Z11 Write !,"This is GT.M test 11.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ZTRAP."
 Write !,"In addition, this example shows that it is"
 Write !,"possible to forgo error processing, and revert"
 Write !,"control directly to the operating system level shell.",!
 Set $ZTRAP="HALT"
 Kill A
Bad11 Write A
 Write !,"This is not displayed."
 Quit
 ;
 ; **************************************************
 ;
Z12 Write !,"This is GT.M test 12.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ZTRAP."
 Write !,"In addition, this example shows that it is"
 Write !,"possible to define a separate error trap procedure"
 Write !,"for errors and issues related to I/O operations.",!
 Write !,"It takes reciprocals."
 Set $ZTRAP="Write !,""Can't take reciprocal of 0."",$Char(7)"
 Use "":(EXCEPTION="Do Trap12":CTRAP=$Char(3))
 Write !,"Type <Ctrl-C> to stop"
Loop12 For  Do
 . Read !,"Type a number: ",X
 . Write ?20,"has reciprocal of: ",1/X
 . Quit
 Quit
Trap12 Write !,"You typed <Ctrl-C> you must be done."
 Use "":(EXCEPTION="":CTRAP="")
 Write !!,$ZSTATUS
 ZGoto 1
 ;
 ; **************************************************
 ;
Z13 Write !,"This is GT.M test 13.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ZTRAP."
 Write !,"In addition, this example shows that it is"
 Write !,"possible to define the error handler as a general"
 Write !,"purpose subroutine that need not reside in the same"
 Write !,"routine as the one in which the error handler is"
 Write !,"defined.",!
 Set $ZTRAP="Goto Trap13"
 New B Set B=2
 Do Sub13a
 Write !,"Back from Sub13a"
 Quit
Sub13a Write !,"This is Sub13a."
 New B Set B=3
 Do Sub13b
 Write !,"Back from Sub13b"
 Quit
Sub13b Write !,"This is Sub13b."
 New B Set B=4
 Kill A
Bad13 Write A
 Write !,"This is not displayed."
 Quit
 ;
Trap13 ; Record context on an error
 ;
 New %errIO,%errZA,%errZB,%errZE
 Set $ZTRAP="Goto Fatal13"
 Set %errIO=$IO,%errZA=$ZA,%errZB=$ZB,%errZE=$ZEOF
 Use $Principal:(NOCENABLE:CTRAP="":EXCEPTION="")
 Write !,"You have encountered an error."
 Write !,"Please notify Joan Supportperson.",!
 Open "REC.ERR":NEWVERSION Use "REC.ERR"
 Write "Date: ",$ZDATE($Horolog),!
 Write !,"$ZSTATUS: ",$ZSTATUS,!
 Write !,"Program stack:",! ZSHOW "S"
 Write !,"I/O status:"
 Write !,"$IO: ",%errIO
 Write !,"$ZA: ",%errZA
 Write !,"$ZB: ",%errZB
 Write !,"$ZEOF: ",%errZE,!
 ZSHOW "D"
 Write !,"Intrinsic special variables: ",! ZSHOW "I"
 ;
Loop13 Write !,"Level: ",$ZLEVEL
 Write !,"Local variables: ",! ZWrite
 If $ZLEVEL>1 ZGOTO $ZLEVEL-1:Loop13
 ;
 Write !
 Close "REC.ERR"
 Quit
 ;
Fatal13 Set $ZT=""
 Write !,"Error recording failure.",!,$ZSTATUS
 Write !
 Close "REC.ERR"
 ZMESSAGE +$ZSTATUS
 Halt
 ;
 ;
 ; **************************************************
 ;
 ;
 ; **************************************************
 ;
 ;
 ; **************************************************
 ;
A21 Write !,"This is ANSI Error Trap test 21.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ETRAP."
 Write !,"In addition, this example shows that it is"
 Write !,"possible to declare a user-defined error by"
 Write !,"setting a value into special variable $ECode.",!
 Set $Etrap="Do Trap21"
 Do
 . Write !,"The next line of code forces an error trap."
 . Set $ECode=",U13: User-Defined Error,"
 . Write !,"This line is not displayed."
 . Quit
 Write !,"This line is displayed."
 Quit
Trap21 Write !,"$ECode=",$ECode,!,"$ZSTATUS=",$ZSTATUS
 Set $ECode=""
 Quit
 ;
 ; **************************************************
 ;
A22 Write !,"This is ANSI Error Trap test 22.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ETRAP."
 Write !,"In addition, this example shows that it is"
 Write !,"possible to declare a user-defined error by"
 Write !,"setting a value into special variable $ECode.",!
 Set $Etrap="Do Trap22"
 Do
 . Write !,"An attempt to put an invalid value into $ECODE"
 . Write !,"is an error by itself (code 101)."
 . Set $ECode="strange value"
 . Write !,"This line is not displayed."
 . Quit
 Write !,"This line is displayed."
 Quit
Trap22 Write !,"$ECode=",$ECode,!,"$ZSTATUS=",$ZSTATUS
 Set $ECode=""
 Quit
 ;
 ; **************************************************
 ;
A23 Write !,"This is ANSI Error Trap test 23.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ETRAP."
 Write !,"In addition, this example shows that it is"
 Write !,"possible to report values of variables at any"
 Write !,"NEW level, and to terminate error processing at"
 Write !,"any DO level.",!
 Set $Etrap="Do Trap23"
 Set x="Value for top level"
 Do Sub23a
 Write !,"Back from Sub23a."
 Do Trap23 ; After all, it is a normal subroutine that can be called at any time...
 Quit
Sub23a New x
 Set x="Value for 'a' level"
 Do Sub23b
 Write !,"Back from Sub23b."
 Quit
Sub23b New x
 Set x="Value for 'b' level"
 Set anchor=$Stack
 Do Sub23c
 Write !,"Back from Sub23c."
 Quit
Sub23c New x
 Set x="Value for 'c' level"
 Do Sub23d
 Write !,"Back from Sub23d."
 Quit
Sub23d New x
 Set x="Value for 'd' level"
Bad23 Set x=1/0
 Quit
Trap23 Write !,"The value of x at level ",$Stack," is ",$Get(x,"--undefined--")
 If $stack=anchor Set $ECode="" Kill x Write !,"Clearing error flag..."
 Quit
 ;
 ; **************************************************
 ;
A24(Recurse) Write !,"This is ANSI Error Trap test 24.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ETRAP."
 Write !,"In addition, this example shows that it is"
 Write !,"possible to report information about the calling"
 Write !,"software at any level, and to terminate error"
 Write !,"processing at any level.",!
 Set $Etrap="Do Trap24"
 Write !,"Do Sub24a."
 Do Sub24a
 Write !,"Back from Sub24a."
 Quit
Sub24a ;
 Write !,"Do Sub24b."
 Do Sub24b
 Write !,"Back from Sub24a."
 Quit
Sub24b ;
 Write !,"Do Sub24c."
 Do Sub24c
 Write !,"Back from Sub24c."
 Quit
Sub24c ;
 Write !,"Do Sub24d."
 Do Sub24d
 Write !,"Back from Sub24d."
 Quit
Sub24d ;
Bad24 Set x=1/0
 Quit
Trap24 Write !,"An error happened, $ECode=",$ECode,!,"$ZSTATUS=",$ZSTATUS
 Write !,"$Stack = ",$Stack,", $Stack(-1) = ",$Stack(-1)
 For i=0:1:$Stack(-1) Do
 . Write !,"$Stack(",i,") = ",$Stack(i)
 . Write !,"$Stack(",i,"""PLACE"") = ",$Stack(i,"PLACE")
 . Write !,"$Stack(",i,"""MCODE"") = ",$Stack(i,"MCODE")
 . Write !,"$Stack(",i,"""ECODE"") = ",$Stack(i,"ECODE")
 If '$Get(Recurse) Set $ECode=""
 Quit
 ;
 ; **************************************************
 ;
A25 Write !,"This is ANSI Error Trap test 25.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ETRAP."
 Write !,"In addition, this example highlights the difference"
 Write !,"between $Stack and $EStack."
 Set $Etrap="Do Trap25a"
 Write !,"$Stack=",$Stack,", $EStack=",$EStack
 Write !,"Do Sub25a."
 Do Sub25a
 Write !,"Back from Sub25a."
 Quit
Sub25a ;
 Write !,"In Sub25a."
 Set anchor=$Stack
 Write !,"$Stack=",$Stack,", $EStack=",$EStack
 Write !,"Do Sub25b."
 Do Sub25b
 Write !,"Back from Sub25b."
 Quit
Sub25b ;
 New $Estack
 Write !,"In Sub25b."
 Write !,"$Stack=",$Stack,", $EStack=",$EStack
 Write !,"Do Sub25c."
 Do Sub25c
 Write !,"Back from Sub25c."
 Quit
Sub25c ;
 Write !,"In Sub25c."
 Write !,"$Stack=",$Stack,", $EStack=",$EStack
 Write !,"Do Sub25d."
 Do Sub25d
 Write !,"Back from Sub25d."
 Quit
Sub25d ;
 Write !,"In Sub25d."
 Write !,"$Stack=",$Stack,", $EStack=",$EStack
Bad25 Set x=1/0
 Quit
Sub25e ;
 Write !,"In Sub25e."
 Write !,"$Stack=",$Stack,", $EStack=",$EStack
 Quit
Trap25a Write !,"An error happened, $ECode=",$ECode,!,"$ZSTATUS=",$ZSTATUS
 Write !,"$Stack = ",$Stack,", $EStack = ",$EStack,", $Stack(-1) = ",$Stack(-1)
 Set $ETrap="Do Trap25b"
 Quit
Trap25b Quit:$Stack>anchor
 Set $ECode=""
 Do Sub25e
 Write !,"Back from Sub25e."
 Quit
 ;
 ; **************************************************
 ;
A26(silent,clear) Write !,"This is ANSI Error Trap test 26.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ETRAP."
 Write !,"In addition, this example shows that it is possible"
 Write !,"to just report an error and return to the environment"
 Write !,"from which the current program (subroutine) was"
 Write !,"invoked.",!
 Write !,"Execute test A26 as:"
 Write !,"  Do A26(0,1)"
 Write !,"and as:"
 Write !,"  Do A26(1,1)",!
 New $Etrap
 Set $Etrap="Write:'silent !,$Stack,"": "",$ECode If clear,$Stack'>anchor Set $ECode="""""
 Set anchor=$Stack,silent=+$Get(silent),clear=+$Get(clear)
 Write !,"Do Sub26a."
 Do Sub26a
 Write !,"Back from Sub26a."
 Quit
Sub26a ;
 Write !,"In Sub26a."
 Write !,"Do Sub26b."
 Do Sub26b
 Write !,"Back from Sub26b."
 Quit
Sub26b ;
 Write !,"In Sub26b."
 Write !,"Do Sub26c."
 Do Sub26c
 Write !,"Back from Sub26c."
 Quit
Sub26c ;
 New $Etrap
 Set $Etrap="Write !,$Stack,"": "",$ECode Set:$Stack'>anchor $ECode="""""
 Write !,"In Sub26c."
 Write !,"Do Sub26d."
 Do Sub26d
 Write !,"Back from Sub26d."
 Quit
Sub26d ;
 Write !,"In Sub26d."
 Write !,"$Stack=",$Stack,", $EStack=",$EStack
Bad26 Set x=1/0
 Quit
 ;
 ; **************************************************
 ;
A27 Write !,"This is ANSI Error Trap test 27.",!
 Write !,"The purpose of this test is to demonstrate"
 Write !,"That a MUMPS program is able to trap an error"
 Write !,"by assigning a value to special variable $ETRAP."
 Write !,"In addition, this example shows that it is possible"
 Write !,"to just report an error and return to the environment"
 Write !,"from which the current program (subroutine) was"
 Write !,"invoked.",!
 Write !,"Call test A26 and allow it to clear the error."
 Do A26(1,1)
 Write !,"Back from test A26."
 Set $Etrap="Do Trap27"
 Write !,"Call test A26 and do not allow it to clear the error."
 Do A26(1,0)
 Write !,"Back from test A26."
 Quit
Trap27 Write !,"An error was encountered in test A26"
 Set $Ecode=""
 Quit

