;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2020-2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Generate boolean expression tests (GTM-7277).
;
; Create "exprcnt" boolean expressions placing each into three places where boolean expressions can be:
;
;  1. Expression - A single WRITE command writes the value of the generated expression (Exp).
;  2. IF (expression) - Generates IF (expr) Write 1 then also generates an ELSE  WRITE 0 (IF).
;  3. Command post-conditionals - Implemented as two WRITE commands with post conditionals. The first is just
;     the generated expression. If TRUE it writes a "1". The second uses a NOT operator on the same expression
;     and if TRUE, prints a 0. The hope is only one of the two writes prints something (CPC).
;  4. Argument post-conditionals - Generates one of a few different types (APC).
;
; The expressions are randomly generated from a defined set of boolean-ish terms (See ttypes() array below).
;
; Note this routine can generate $ZQGblmod() functions. Since the output must be repeatable, this test should
; NOT run under replication which could make this function less predictable and predictable is what we need.
;
	Set $ETrap="Do Error^"_$Text(+0)
	;
	; Configuration parms
	;
	; On AARCH64, ARMV7L and ARMV6L, generating 5000 boolean expressions runs into memory issues.
	; Therefore limit the # of expressions to a much smaller number (1500) there.
	Set exprcnt=$Select(($ZVersion'["x86_64"):1500,1:5000)	; Create this many expressions - each is executed in all 3 places
	Set baseoprnpct=33	; Base open paren percentage. Is reduced by multiples of paren nesting
	Set basecprnpct=40	; Base close paren percentage. Is increased by multiples of paren nesting
	Set nxtopandpct=35	; Next operator this percent to be AND, else is an OR operator
	Set numterms=5		; Minimum terms in expression is $RANDOM(numterms)+3. Max is min +5
	;
	; Initialization
	;
	Set TAB=$Char(9)
	;
	; Types of terms used in generated expressions. If anything changes in these terms, may need to adjust code
	; in NextTerm routine. Note changing order or new term added requires update in NextTerm() routine.
	;
	Set ttypes(0)="constant"		; Constant TRUE/FALSE value (i.e. 1 or 0)
	Set ttypes(1)="$Test"			; Binary result ISV
	Set ttypes(2)="extrinsic"		; One of $$Always0, $$Always1, $$RetSame(x) or $$RetNot(x)
	Set ttypes(3)="variable"		; Local and global vars (may be indirect, subscripted by 0 or 1 or passed by reference)
	Set ttypes(4)="relexpr"			; Generate a relational expression of terms
	Set ttypes(5)="function"		; Generates function usages or an expression with tfuncs() function in it
	Set ttypecnt=$Order(ttypes(""),-1)+1	; Highest + 1 since 0 origin
	;
	; Types of functions generated. For all of these, the argument is either fixed or indirect. If a boolean
	; return from the function is not possible, gets turned into an expression possibly subtracting two types so the
	; end result is always a boolean value. Note if anything changes in these function names, may need to adjust
	; code in GenFuncTerm routine.
	;
	Set tfuncs(0)="$Increment"		; Generates an expr.
	Set tfuncs(1)="$Data"			; Argument is ^TRUE or TRUE with subscript 1, or 2
	Set tfuncs(2)="$Get"			; Argument one of the t/f vars, optional 2nd arg
	Set tfuncs(3)="$Next"			; Argument is t/f var with subscript -1 or 0.
	Set tfuncs(4)="$Order"			; 2 types, forward and backward. Otherwise same as $Next()
	Set tfuncs(5)="$Query"			; Similar to $Next() when surrounded by @(..) to eval it
	Set tfuncs(6)="$Select"			; Argument is one of the truth vars
	Set tfuncs(7)="$ZAHandle"		; Generates an expr relating $ZAHandle() of two vars
	Set tfuncs(8)="$ZPrevious"		; Similar to backwards $Order()
	Set tfuncs(9)="$ZQGblmod"		; Arg is gvn t/f var. Since no replication, always return 1.
	Set tfunccnt=$Order(tfuncs(""),-1)+1	; Highest + 1 since 0 origin
	;
	; Set of relational ops we can generate in the relational expression.
	;
	Set relop(0)="="
	Set relop(1)="'="
	Set relop(2)="<"
	Set relop(3)="'<"
	Set relop(4)=">"
	Set relop(5)="'>"
	Set relop(6)="["
	Set relop(7)="'["
	Set relop(8)="]"
	Set relop(9)="']"
	Set relop(10)="]]"
	Set relop(11)="']]"
	Set relopcnt=$Order(relop(""),-1)+1	; Highest + 1 since 0 origin
	;
	; Types of tokens added to expression. When assigned into lasttk() array, helps keep track of the last
	; token type generated at a given paren nesting level.
	;
	Set tkoparen=1				; Open paren
	Set tkclparen=2				; Close paren
	Set tkterm=3				; One of the term types above
	Set tkop=4				; Operator (& or !)
	;
	; Open output file and start generating..
	;
	Set ofile="btest.m"
	Open ofile:New
	Use ofile
	Write ";",!
	Write "; Generated full boolean test program - run once with $gtm_boolean as 0 and once as 1 and compare output",!
	Write ";",!
	Write "; First - some initialization of values used in the generated expressions.",!
	Write ";",!
	Write TAB,"Set $ETrap=""Set $ETrap="""""""" Write $ZStatus,! ZShow """"*"""" ZHalt 1""",!
	Write "; we count on $ZAHandle(TRUE)]$ZAHandle(FALSE) evaluate to a fixed value (say 0) across all versions",!
	write "; hence we first allocate two dummy local vars and find out whose address is higher and assign that to",!
	write "; alias variables TRUE and FALSE based on their value (since $ZAHandle of an alias variable is same as",!
	write "; that of the base variable",!
	write TAB,"Set dummyfalse=0,dummytrue=1",!
	write TAB,"If $ZAHandle(dummyfalse)]$ZAHandle(dummytrue) Do",!
	write TAB,". Set *TRUE=dummyfalse,*FALSE=dummytrue",!
	write TAB,"Else  Set *TRUE=dummytrue,*FALSE=dummyfalse",!
	Write TAB,"Set TRUE=1,FALSE=0,iTRUE=""TRUE"",TRUE(-1)=1,TRUE(0)=1,TRUE(1)=1,TRUE(2)=1",!
	Write TAB,"Set ^iTRUE=""^TRUE"",^TRUE=1,^TRUE(-1)=1,^TRUE(0)=1,^TRUE(1)=1,^TRUE(2)=1",!
	Write TAB,"Set iFALSE=""FALSE"",FALSE(-1)=0,FALSE(0)=0,FALSE(1)=0,FALSE(2)=0",!
	Write TAB,"Set ^iFALSE=""^FALSE"",^FALSE=0,^FALSE(-1)=0,^FALSE(0)=0,^FALSE(1)=0,^FALSE(2)=0",!
	Write TAB,"Set bogus=""unknwn"",^bogus=""^unknwn"",^dummy=0",!
	Write TAB,"Set incrvar=0,indincrvar=""incrvar"",zl=$ZLevel",!
	Write TAB,"Set nextt=",$Random(2),"    ; Preload for $TEST with either 0 or 1 generated randomly",!
	Set lasttstnaked=1		  ; Pretend we had to set naked last time to force initialization first time thru
	;
	; Generate expressions and put each one into three test cases.
	;
	For exprnum=1:1:exprcnt Do
	. Set type=$Random(2)			; Types are: 0 uses always0/1() and 1 uses retnot/same() routines
	. Set expr=$$GenBoolExpr	    	; Create expression for this set of tests
	. Set initnaked=(0'=$ZFind(expr,"^"))  	; Has a global ref in it so reinit naked for each phrase
	. Write !,TAB,"Write ""Expr#",exprnum,":""",!
	. Write TAB,"If nextt",?29,"; Set $TEST to next progressive value",!
	. Write TAB,"Set t=$TEST",?29,"; Save so usage in each expression usage is repeatable",!
	. Write:(lasttstnaked&('initnaked)) TAB,"Set x=^dummy",?29,"; Init naked for all tests this expr",!
	. ;
	. ; Generate expression test
	. ;
	. Write TAB,"Write ?12,"" Exp:"",(",expr,"),""/"",$Reference",!
	. ;
	. ; Generate expression test
	. ;
	. Write TAB,"If (",expr,") Write ?32,"" If:1/"",$Reference",!
	. Write TAB,"Else  Write ?32,"" If:0/"",$Reference",!
	. Write TAB,"Set nextt=$TEST",?29,"; Save for restore next test so don't have same $TEST for all exprs",!
	. ;
	. ; Generate argument post conditional - determine which of 4 types to use (DO, GOTO, XECUT, ZGOTO)
	. ;
	. Set apctyp=$Random(4)
	. Write TAB,"If t",?29,"; Restore initial $TEST value",!
	. Write TAB,"Write ?52,"" APC:""",!
	. If (0=apctyp) Do		; Generate DO type APC
	. . Write TAB,"Do Write1:(",expr,"),Write0:('(",expr,"))",!
	. . Write TAB,"Write ""/"",$Reference",!
	. Else  If (1=apctyp) Do	; Generate Xecute type APC
	. . Write TAB,"Xecute ""Do Write1"":(",expr,"),""Do Write0"":('(",expr,"))",!
	. . Write TAB,"Write ""/"",$Reference",!
	. Else  Do	      	   	; Generate GOTO and ZGOTO types of APC
	. . Write TAB,$Select((2=apctyp):"Goto ",1:"ZGoto zl:"),"Lbl",exprnum,"A:(",expr,"),",$Select((3=apctyp):"zl:",1:""),"Lbl",exprnum,"B:('(",expr,"))",!
	. . Write TAB,"Write ""FAIL - neither condition tripped"",!",!
	. . Write TAB,"Goto Lbl",exprnum,"Done",!
	. . Write "Lbl",exprnum,"A Write 1",!
	. . Write TAB,"Goto Lbl",exprnum,"Done",!
	. . Write "Lbl",exprnum,"B Write 0",!
	. . Write "Lbl",exprnum,"Done",!
	. . Write TAB,"Write ""/"",$Reference",!
	. ;
	. ; Generate post-conditional test - comes last due to propensity for broken boolean to eval both expressions
	. ; as TRUE printing two values. At the end, this doesn't interfere with anything.
	. ;
	. Write TAB,"Write:(",expr,") ?72,"" CPC:1/"",$Reference",!
	. Write TAB,"Write:('(",expr,")) ?72,"" CPC:0/"",$Reference",!
	. ;
	. ; Each test is one line long so write end of test newline
	. ;
	. Write TAB,"Write !",!
	. Set lasttstnaked=initnaked
	Write TAB,"Quit",!
	;
	; Create driven functions
	;
	Write !,"Always0()",!
	Write TAB,"Quit 0",!
	Write "Always1()",!
	Write TAB,"Quit 1",!
	Write "RetSame(x)",!
	Write TAB,"Quit x",!
	Write "RetNot(x)",!
	Write TAB,"Quit '(x)",!
	Write "Write0",TAB,"Write 0",!
	Write TAB,"Quit",!
	Write "Write1",TAB,"Write 1",!
	Write TAB,"Quit",!
	;
	; All done!
	;
	Close ofile
	Use $P
	Write "Test routine with ",exprcnt," expressions created",!
	Quit

;
; GenBoolExpr - Generate random boolean expression
;
; Percentage events:
;
;         100% - open new paren level when no paren level pending
;    variable% - open new paren level when prnnest>0. Exact pctage is baseoprnpct% - (10% * prnnest)
;    variable% - close a paren level if at least 2 terms. Exact pcgage is basecprnpct% + (10% * prnnest)
;
GenBoolExpr()
	New trm,expr,lasttk,lastoprn,minterms,prnnest,newlvl
	Set minterms=$Random(numterms)+3
	Set lastoprn(0)=0
	Set lasttk(0)=""
	Set expr="("				; Start expression with open paren
	Set prnnest=1				; Paren nesting level
	Set newlvl=1				; New paren nesting level just started (no terms yet)
	Set lastoprn(1)=1
	Set lasttk(prnnest)=tkoparen
	For curtrm=1:1:999 Quit:((curtrm>(minterms+5))&(0=prnnest))  Do		; Quit when reach max terms or we have "enough" terms generated
	. Do:('newlvl&(curtrm<(minterms+2)))			     		; Not enough terms in this level yet & haven't just started a new lvl
	. . Set expr=expr_$$NextOp						; .. so gen new term and operator
	. . Set lasttk(prnnest)=tkop
	. Do:(('prnnest!$$NewParenLevel)&(curtrm<(minterms-prnnest-3)))		; New paren level if none or %random & not enuf terms this paren lvl
	. . Set expr=expr_"("
	. . Set prnnest=prnnest+1
	. . Set newlvl=1
	. . Set lastoprn(prnnest)=curtrm
	. . Set lasttk(prnnest)=tkoparen
	. Do:(curtrm<(minterms+2))						; Not enough terms this expr, generate a new one
	. . Set:('newlvl&(tkop'=lasttk(prnnest))) expr=expr_$$NextOp
	. . Set expr=expr_$$NextTerm
	. . Set lasttk(prnnest)=tkterm
	. Set newlvl=0
	. Do:((0<prnnest)&((curtrm-2)'<lastoprn(prnnest))&$$CloseParenLevel)	; Need non-zero paren level and at least 2 terms to close a paren lvl
	. . Set expr=expr_")"
	. . Set prnnest=prnnest-1
	. . Do:((curtrm<(minterms+1))&(curtrm=lastoprn(prnnest)))
	. . . Set expr=expr_")"
	. . . Set lasttk(prnnest)=tkclparen
	Quit expr

;
; NextTerm - Generate the next expression term randomly from one of ttypes().
;
NextTerm()
	New ttype,term
	Set ttype=$Random(ttypecnt)
	If ("constant"=ttypes(ttype)) Do  Quit term		; Term is the constant 0 or 1
	. Set term=$Random(2)
	If ("$Test"=ttypes(ttype)) Set term="$Test" Quit term	; Term is $Test
	If ("extrinsic"=ttypes(ttype)) Do  Quit term		; Term is $$Always0, $$Always1, $$RetSame(), or $$RetNot()
	. New arg,termarg
	. Set arg=$Random(2)			; arg or no arg
	. If (arg) Do				; arg it is
	. . Set termarg=$$NextTerm
	. . Set:($Random(2)&(("TRUE"=termarg)!("FALSE"=termarg))) termarg="."_termarg	; If simple LV, 50% chance it is passed by reference
	. . Set term="$$Ret"_$Select($Random(2):"Same",1:"Not")_"("_termarg_")"
	. Else  Set term="$$Always"_$Random(2)	; no arg
	If ("variable"=ttypes(ttype)) Do  Quit term		; Term is local or global var indirect or direct (50% are subscripted)
	. New idx,indr,lclgbl
	. Set idx=$Random(2)			; Subscripted or not
	. Set indr=$Random(2)			; Indirect or not
	. Set lclgbl=$Random(2)			; Local or global
	. Set term=$Select(indr:"@",1:"")_$Select(lclgbl:"",1:"^")_$Select(indr:"i",1:"")_$Select($Random(2):"TRUE",1:"FALSE")
	. Quit:(0=idx)
	. ;
	. ; Var is to be subscripted
	. ;
	. Set term=term_$Select(indr:"@",1:"")_"("_$$NextTerm_")"
	If ("relexpr"=ttypes(ttype)) Do  Quit term		; Term is a relational expression between two generated term.
	. ;
	. ; Note this expression is "self contained" only counting as a single term when it returns. Generated as
	. ; (term<op>term).
	. ;
	. Set term="("_$$NextTerm_relop($Random(relopcnt))_$$NextTerm_")"
	If ("function"=ttypes(ttype)) Do  Quit term		; Term is a function or simple expression using functions
	. Set term=$$GenFuncTerm     			; Separate routine to take care of that
	;
	; We should never end up here as all defined terms do a QUIT
	;
	Use $P
	Write "ASSERT - unknown term type: ",ttype,!
	ZShow "*"
	ZHalt 1

;
; Generate a term from one of the tfuncs() types. Return value must be a boolean type value so some of these turn
; into expressions using functions.
;
GenFuncTerm()
	New ftype,fterm,ind,argvar
	Set ftype=$Random(tfunccnt)
	Set ind=$Random(2)				; Indirect or not
	If ("$Increment"=tfuncs(ftype)) Do  Quit fterm		; Covers $Indirect()
	. New argvar,incval
	. Set argvar=$Select(ind:"@indincrvar",1:"incrvar")
	. Set incval=$Random(3)-1
	. ;
	. ; Note the below expression returns a value but leaves argvar the same as it was. The reason for this
	. ; is so shortcutting boolean0 runs and non-shortcutting boolean1 runs behave the same. When it was possible
	. ; for this term to behave differently between the two types, intermittent failures occured.
	. ;
	. Set fterm="(0<($Incr("_argvar_","_incval_")-$Incr("_argvar_","_-incval_")))"
	If ("$Data"=tfuncs(ftype)) Do  Quit fterm		; Covers $Data() - use subscripted vars. Known vars give 1, unknown gets 0
	. New known
	. Set known=$Random(2)				; known is subscripted var, unknown is not. Both can be indirect.
	. Do:(known)					; Handle known var
	. . Set argvar=$Select(ind:"@",1:"")_$Select($Random(2):"^",1:"")_$Select(ind:"i",1:"")_$Select($Random(2):"TRUE",1:"FALSE")
	. . Set argvar=argvar_$Select(ind:"@(",1:"(")_$Random(2)_")"
	. Set:('known) argvar=$Select(ind:"@",1:"")_$Select($Random(2):"^",1:"")_$Select(ind:"bogus",1:"unknwn")
	. Set fterm="$Data("_argvar_")"
	If ("$Get"=tfuncs(ftype)) Do  Quit fterm		; Covers $Get() (1 or 2 args - 2 arg forum uses unknown var)
	. New args
	. Set args=$Random(2)+1				; 1 or 2 args
	. Do:(1=args)					; Chose local or global indirect or not with or without subscript
	. . Set argvar=$Select(ind:"@",1:"")_$Select($Random(2):"^",1:"")_$Select(ind:"i",1:"")_$Select($Random(2):"TRUE",1:"FALSE")
	. . Set argvar=argvar_$Select($Random(2):$Select(ind:"@",1:"")_"("_$Random(2)_")",1:"")
	. . Set fterm="$Get("_argvar_")"
	. Set:(2=args) fterm="$Get("_$Select(ind:"@",1:"")_$Select($Random(2):"^",1:"")_$Select(ind:"bogus",1:"unknwn")_","_$Random(2)_")"
	If ("$Next"=tfuncs(ftype)) Do  Quit fterm		; Covers $Next()
	. Set argvar=$Select(ind:"@",1:"")_$Select($Random(2):"^",1:"")_$Select(ind:"i",1:"")_$Select($Random(2):"TRUE",1:"FALSE")
	. Set argvar=argvar_$Select(ind:$Select(ind:"@",1:"")_"(",1:"(")_($Random(2)-1)_")"
	. Set fterm="$Next("_argvar_")"
	If ("$Order"=tfuncs(ftype)) Do  Quit fterm		; Covers $Order() (1 and 2 arg types with 2nd arg constant or var ref)
	. New args
	. Set args=$Random(2)+1				; 1 or 2 args
	. Set argvar=$Select(ind:"@",1:"")_$Select($Random(2):"^",1:"")_$Select(ind:"i",1:"")_$Select($Random(2):"TRUE",1:"FALSE")
	. Set argvar=argvar_$Select(ind:"@(",1:"(")
	. Do:(1=args)					; 1 arg is always "forward"
	. . Set argvar=argvar_($Random(2)-1)_")"
	. . Set fterm="$Order("_argvar_")"
	. Do:(2=args)
	. . New dir
	. . Set dir=$Random(2)				; Forward or backwards
	. . Set:(0=dir) argvar=argvar_($Random(2)-1)_")"	; Forward
	. . Set:(1=dir) argvar=argvar_($Random(2)+1)_")"	; Backward
	. . Set fterm="$Order("_argvar_","_$Select(dir:-1,1:1)_")"
	If ("$Query"=tfuncs(ftype)) Do  Quit fterm		; Covers $Query() - Form generated: @($Query(varref)) - returns bool value
	. Set argvar=$Select(ind:"@",1:"")_$Select($Random(2):"^",1:"")_$Select(ind:"i",1:"")_$Select($Random(2):"TRUE",1:"FALSE")
	. Set argvar=argvar_$Select(ind:"@(",1:"(")_($Random(2)-1)_")"
	. Set fterm="@($Query("_argvar_"))"
	If ("$Select"=tfuncs(ftype)) Do  Quit fterm		; Covers $Select()
	. Set argvar=$Select(ind:"@",1:"")_$Select($Random(2):"^",1:"")_$Select(ind:"i",1:"")_$Select($Random(2):"TRUE",1:"FALSE")
	. Set argvar=argvar_$Select($Random(2):$Select(ind:"@",1:"")_"("_$Random(2)_")",1:"")
	. Set fterm="$Select("_argvar_":1,1:0)"
	If ("$ZAHandle"=tfuncs(ftype)) Do  Quit fterm		; Covers $ZAHandle() - creates relational expression between $ZAH() for 2 vars
	. New argvar1,argvar2
	. Set argvar1=$Select(ind:"@",1:"")_$Select(ind:"i",1:"")_$Select($Random(2):"TRUE",1:"FALSE")
	. Set argvar1=argvar1_$Select($Random(2):$Select(ind:"@",1:"")_"("_$Random(2)_")",1:"")
	. Set argvar2=$Select(ind:"@",1:"")_$Select(ind:"i",1:"")_$Select($Random(2):"TRUE",1:"FALSE")
	. Set argvar2=argvar2_$Select($Random(2):$Select(ind:"@",1:"")_"("_$Random(2)_")",1:"")
	. Set fterm="($ZAHandle("_argvar1_")]$ZAHandle("_argvar2_"))"
	If ("$ZPrevious"=tfuncs(ftype)) Do  Quit fterm		; Covers $ZPrevious() - same as $Order() backward without 2nd arg
	. Set argvar=$Select(ind:"@",1:"")_$Select($Random(2):"^",1:"")_$Select(ind:"i",1:"")_$Select($Random(2):"TRUE",1:"FALSE")
	. Set argvar=argvar_$Select(ind:"@(",1:"(")_($Random(2)+1)_")"
	. Set fterm="$ZPrevious("_argvar_")"
	If ("$ZQGblmod"=tfuncs(ftype)) Do  Quit fterm		; Covers $ZQGblmod() - no replication so always returns 1
	. Set argvar=$Select(ind:"@",1:"")_$Select(ind:"^i",1:"^")_$Select($Random(2):"TRUE",1:"FALSE")
	. Set fterm="$ZQGblmod("_argvar_")"
	;
	; Should never reach here
	;
	Use $P
	Write "ASSERT - unknown func type: ",ftype,!
	ZShow "*"
	ZHalt 1

;
; NextOp - nxtopandpct% chance for AND, else is OR
;
NextOp()
	New opp
	Set opp=$Random(100)
	Quit:(nxtopandpct>opp) "&"
	Quit "!"

;
; NewParenLevel - baseoprnpct% less 10% for each paren nesting level
;
NewParenLevel()
	Quit (($Random(100)+baseoprnpct-(10*prnnest))>99)

;
; CloseParenLevel - basecprnpct plus 10% for each paren nesting level
;
CloseParenLevel()
	Quit:(curtrm>(minterms+2)) 1		; We are about done here
	Quit (($Random(100)+basecprnpct+(10*prnnest))>99)

;
; Do necessary for outputting debug messages to $P. Useful to debug changes to above rtns since can be
; used without changing $IO around (this rtn takes care of that). Rtn used for debugging.
;
dbgzwrite(zwrarg,sfx)
	New saveio
	Do DoWrite("DbgZwrite ----------- "_$Select(""'=$Get(sfx,""):"("_sfx_")",TRUE:"")_":")
	Set saveio=$IO
	Use $P
	ZWrite @zwrarg
	Use saveio
	Quit

;
; Routine to write text $P while doing other IO. Can be used instead of dbgzwrite if more appropriate.
;
DoWrite(msg)
	New saveio
	Set saveio=$IO
	Use $P
	Write msg,!
	Use saveio
	Quit

;
; Error handler
;
Error
	Set $ETrap=""
	Use $P
	Write $ZStatus,!!
	Break					; Allow debugging but not ZCONTINUE..
	ZShow "*"
	Write "ZContinue not happening..",!
	ZHalt 1
