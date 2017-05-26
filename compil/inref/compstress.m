; Possible forms of compiler stress:
;  1) Jump offsets
;  2) Label tables offset
;  3) Literal offsets
;  4) l_symtab and vartab offset
;  5) Linkage table offsets
;
; This routine creates three additional routines compstrsA, compstrsB, and compstrsB:
;
; compstrsA: Stresses 1, 2 (create), and 3 above.
;   Does this by Creating a series of local calls in one giant chain. The first
;   half of the calls will call forward, the second half will call backwards. The
;   top most of the calls will call the bottom most so the calls will work their
;   way from the outside in. 
;
;   Since there will be 32,000 subroutines, this is pretty much guaranteed to blow the
;   M stack so we will keep an eye on the stack depth and return when it gets too deep.
;   When we get all the way back out, a subsequent call to the "more inner" routine to
;   pick up the call tests will get all the call offsets tested -- both forward and backward.
;
;   Since each of the entry points has a label, this should stress test the label table 
;   offset allocation and each of the entry points will address one or two unique literals
;   providing testing for them as well.
;
;   Item 4 cannot really be tested with the current implementation. A large number of local vars
;   Causes a large l_symtab to be allocated on the stack. Often larger than the stack itself
;   is capable of supporting even at startup so no stress test exists for this table.
;
;   One additional test is inserted every 100 routines which checks the $ZPOS value that the
;   numeric offset from the label is less than 10. This also utilizes the label table.
;
; compstrsB and C stress 2 and 5 above:
;   The compstrsB routine is much more simplistic. We are wanting to stress the addressing
;   to the linkage table and the label table so we are just going to generate a fairly linear 
;   series of external calls to equivalent routines in compstrsC. We will generate a few different 
;   types of calls to stress the various generated types. The linkage lookup will lookup both
;   the routine name in the routine table but more importantly will also lookup the label in
;   the label table in addition to accessing the linkage table to fill in the values and to
;   pull them back out.
;

	Set $ETrap="ZShow ""*"" Halt"
	Set compstrsA="compstrsA.m"
	Set compstrsB="compstrsB.m"
	Set compstrsC="compstrsC.m"
	Set maxSRtns=32768
	Set maxSRtns1H=maxSRtns/2
	Set maxStackDepth=256

	Open compstrsA:New
	Use compstrsA
	
	Set maxStackDepth=(maxStackDepth/2)*2		; make sure it is an even number
	
	Write "  Set $ETrap=""ZShow """"*"""" Halt""",!
	Write "  Write """,compstrsA," started"",!",!
	Write "  Set zot=0,srtncnts=0",!
	Write "  Goto longjumpfwd",!!
	Write "longjumpbkwd",!
	; Generate the calls that will invoke the routines we are about to call
	For i=1:maxStackDepth/2:maxSRtns/2  Write "  Set x=$$SRtn",i,"(",i,")",!
	Write "  If srtncnts'=",maxSRtns," Write ""** FAIL ** Internal subroutine execution count incorrect"",!",!
	Write "  If srtncnts=",maxSRtns,"  Write ""PASS"",!",!
	Write "  Quit",!

	; Generate call forward routines
	Set csrtn=maxSRtns
	For i=1:1:maxSRtns1H Do gensrtnA(i,csrtn,0) Set csrtn=csrtn-1
	; For the call backward subroutines, the first subroutine is the last one that will be
	; called so give it last=1 parm.
	Do gensrtnA(i+1,99999999,1)
	For i=i+2:1:maxSRtns Do gensrtnA(i,csrtn,0) Set csrtn=csrtn-1
	
	; Write longjump back up to where we want it
	Write !,"longjumpfwd Goto longjumpbkwd",!

	Close compstrsA

	; Now build compstrsB/C
	Open compstrsB:New
	Open compstrsC:New

	Use compstrsB
	Write "  Set $ETrap=""ZShow """"*"""" Halt""",!
	Write "  Write """,compstrsB," started"",!",!
	Write "  Set srtncnts=0,baseLevel=$ZLevel",!!
	Use compstrsC
	Write "  Write "" *** FAIL *** Not to be invoked directly"",!",!!
	
	; First half, call using DO and return using ZGOTO
	For i=1:1:maxSRtns1H Do
	. Use compstrsB
	. Write "  Do SRtn",i,"^compstrsC",!
	. Write "Lbl",i,"Ret If $ZLevel'=baseLevel Write ""** FAIL ** $ZLevel exceeds baseLevel ("",baseLevel,"") for SRtn",i,"ret"",!",!
	. Use compstrsC
	. Write "SRtn",i,"  Set srtncnts=srtncnts+1 ZGoto ($ZLevel-1):Lbl",i,"Ret^compstrsB",!

	; For the 2nd half call via a function, then GOTO a return routine in compstrsB
	For i=maxSRtns1H+1:1:maxSRtns Do
	. Use compstrsB
	. Write "  Set x=$$Func",i,"^compstrsC()",!
	. Write "  If $ZLevel'=baseLevel Write ""** FAIL ** $ZLevel exceeds baseLevel ("",baseLevel,"") for Func",i,"ret"",!",!
	. Use compstrsC
	. Write "Func",i,"()  Set srtncnts=srtncnts+1 Goto Func",i,"Ret^compstrsB",!
	Use compstrsB
	Write !!
	Write "  If srtncnts'=",maxSRtns," Write ""** FAIL ** Internal subroutine execution count incorrect"",!",!
	Write "  If srtncnts=",maxSRtns,"  Write ""PASS"",!",!
	Write "  Quit",!
	; 2nd half of the 2nd half is to create the Goto/Return routines in compstrsB
	Write !!
	For i=maxSRtns1H+1:1:maxSRtns Do
	. Write "Func",i,"Ret  Quit ",i,! 

	Close compstrsB
	Close compstrsC

	Quit

gensrtnA(srtnsrc,srtncall,last)
	Set srtnnam="SRtn"_srtnsrc
	Write srtnnam,"(var)",!
	Write:(1=(srtnsrc#100)) "  Set y="""_srtnnam_"+1^""_$Text(+0) If y'=$ZPos Write ""*** FAIL *** Bad $ZPos at ",srtnnam,"+1"",! ZShow ""*"" Halt",!
 	Write "  Set var=""LitC",srtncall,""",srtncnts=srtncnts+1",!
 	Write:'last "  Set",$Select(srtncall<srtnsrc:":$Stack<"_maxStackDepth,1:"")," var=$$SRtn",srtncall,"(.var)",!
	Write "  Set var=""LitS",srtnsrc,"""",!
	Write "  Quit ",srtnsrc,"/",srtncall,!
	Quit
