;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2020-2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Generate and return a boolean expression to be used in other tests.
;
; This routine was originally taken from v60000/inref/boolgen.m that was used to test GTM-7277. It has been
; made somewhat more general purpose to create boolean expressions that can either be used immediately or can
; be written to a generated routine. The entry points are:
;
;   - Init():            Initializes the boolean expression generator.
;   - BooleanExprGen():  Returns a boolean expression in that it always evaluates to 0 or 1.
;   - CreateRoutine(fn): Creates 'fn'.m and writes several prologue initializations with it. It opens the output file
;     			 and leaves its name in the variable 'ofile'.
;   - GenEndOfFile():    Finishes generation of the output file by adding a QUIT statement and then defining several
;     			 extrinsics that can be used by the generator.
;
; The expressions are randomly generated from a defined set of boolean-ish terms (See ttypes() array below).
;
; Note this routine can generate $ZQGBLMOD() functions. Since the output must be repeatable, this test should
; NOT run under replication which could make this function less predictable and predictable is what is needed.
;
	write "FAILURE - This main entry should not be used. Need to directly call what ever routine is needed",!
	zhalt 1
;
; BooleanExprGen - Generate random boolean expression
;
; Percentage events:
;
;         100% - open new paren level when no paren level pending
;    variable% - open new paren level when prnnest>0. Exact pctage is baseoprnpct% - (10% * prnnest)
;    variable% - close a paren level if at least 2 terms. Exact pcgage is basecprnpct% + (10% * prnnest)
;
BooleanExprGen()
	new trm,expr,lasttk,lastoprn,minterms,prnnest,newlvl
	set minterms=$random(numterms)+3
	set lastoprn(0)=0
	set lasttk(0)=""
	set expr="("				; Start expression with open paren
	set prnnest=1				; Paren nesting level
	set newlvl=1				; New paren nesting level just started (no terms yet)
	set lastoprn(1)=1
	set lasttk(prnnest)=tkoparen
	for curtrm=1:1:999 quit:((curtrm>(minterms+5))&(0=prnnest))  do		; Quit when reach max terms or we have "enough" terms generated
	. do:('newlvl&(curtrm<(minterms+2)))			     		; Not enough terms in this level yet & haven't just started a new lvl
	. . set expr=expr_$$NextOp						; .. so gen new term and operator
	. . set lasttk(prnnest)=tkop
	. do:(('prnnest!$$NewParenLevel)&(curtrm<(minterms-prnnest-3)))		; New paren level if none or %random & not enuf terms this paren lvl
	. . set expr=expr_"("
	. . set prnnest=prnnest+1
	. . set newlvl=1
	. . set lastoprn(prnnest)=curtrm
	. . set lasttk(prnnest)=tkoparen
	. do:(curtrm<(minterms+2))						; Not enough terms this expr, generate a new one
	. . set:('newlvl&(tkop'=lasttk(prnnest))) expr=expr_$$NextOp
	. . set expr=expr_$$NextTerm
	. . set lasttk(prnnest)=tkterm
	. set newlvl=0
	. do:((0<prnnest)&((curtrm-2)'<lastoprn(prnnest))&$$CloseParenLevel)	; Need non-zero paren level and at least 2 terms to close a paren lvl
	. . set expr=expr_")"
	. . set prnnest=prnnest-1
	. . do:((curtrm<(minterms+1))&(curtrm=lastoprn(prnnest)))
	. . . set expr=expr_")"
	. . . set lasttk(prnnest)=tkclparen
	quit "("_expr_")"

;
; NextTerm - Generate the next expression term randomly from one of ttypes().
;
NextTerm()
	new ttype,term
	set ttype=$random(ttypecnt)
	if ("constant"=ttypes(ttype)) do  quit term		; Term is the constant 0 or 1
	. set term=$random(2)
	if ("$test"=ttypes(ttype)) set term="$test" quit term	; Term is $test
	if ("extrinsic"=ttypes(ttype)) do  quit term		; Term is $$Always0, $$Always1, $$RetSame(), or $$RetNot()
	. new arg,termarg
	. set arg=$random(2)					; arg or no arg
	. if (arg) do						; arg it is
	. . set termarg=$$NextTerm
	. . set:($random(2)&(("TRUE"=termarg)!("FALSE"=termarg))) termarg="."_termarg	; If simple LV, 50% chance it is passed by reference
	. . set term="$$Ret"_$select($random(2):"Same",1:"Not")_"("_termarg_")"
	. else  set term="$$Always"_$random(2)	; no arg
	if ("variable"=ttypes(ttype)) do  quit term		; Term is local or global var indirect or direct (50% are subscripted)
	. new idx,indr,lclgbl
	. set idx=$random(2)					; Subscripted or not
	. set indr=$random(2)					; Indirect or not
	. set lclgbl=$random(2)					; Local or global
	. set term=$select(indr:"@",1:"")_$select(lclgbl:"",1:"^")_$select(indr:"i",1:"")_$select($random(2):"TRUE",1:"FALSE")
	. quit:(0=idx)
	. ;
	. ; Var is to be subscripted
	. ;
	. set term=term_$select(indr:"@",1:"")_"("_$$NextTerm_")"
	if ("relexpr"=ttypes(ttype)) do  quit term		; Term is a relational expression between two generated term.
	. ;
	. ; Note this expression is "self contained" only counting as a single term when it returns. Generated as
	. ; (term<op>term).
	. ;
	. set term="("_$$NextTerm_relop($random(relopcnt))_$$NextTerm_")"
	if ("function"=ttypes(ttype)) do  quit term		; Term is a function or simple expression using functions
	. set term=$$GenFuncTerm     				; Separate routine to take care of that
	;
	; We should never end up here as all defined terms do a QUIT
	;
	use $p
	write "ASSERT - unknown term type: ",ttype,!
	zshow "*"
	zhalt 1

;
; Generate a term from one of the tfuncs() types. Return value must be a boolean type value so some of these turn
; into expressions using functions.
;
GenFuncTerm()
	new ftype,fterm,ind,argvar
	set ftype=$random(tfunccnt)
	set ind=$random(2)					; Indirect or not
	if ("$increment"=tfuncs(ftype)) do  quit fterm		; Covers $Indirect()
	. new argvar,incval
	. set argvar=$select(ind:"@indincrvar",1:"incrvar")
	. set incval=$random(3)-1
	. ;
	. ; Note the below expression returns a value but leaves argvar the same as it was. The reason for this
	. ; is so shortcutting boolean0 runs and non-shortcutting boolean1 runs behave the same. When it was possible
	. ; for this term to behave differently between the two types, intermittent failures occured.
	. ;
	. set fterm="(0<($Incr("_argvar_","_incval_")-$Incr("_argvar_","_-incval_")))"
	if ("$data"=tfuncs(ftype)) do  quit fterm		; Covers $data() - use subscripted vars. Known vars give 1, unknown gets 0
	. new known
	. set known=$random(2)					; known is subscripted var, unknown is not. Both can be indirect.
	. do:(known)						; Handle known var
	. . set argvar=$select(ind:"@",1:"")_$select($random(2):"^",1:"")_$select(ind:"i",1:"")_$select($random(2):"TRUE",1:"FALSE")
	. . set argvar=argvar_$select(ind:"@(",1:"(")_$random(2)_")"
	. set:('known) argvar=$select(ind:"@",1:"")_$select($random(2):"^",1:"")_$select(ind:"bogus",1:"unknwn")
	. set fterm="$data("_argvar_")"
	if ("$get"=tfuncs(ftype)) do  quit fterm		; Covers $get() (1 or 2 args - 2 arg forum uses unknown var)
	. new args
	. set args=$random(2)+1					; 1 or 2 args
	. do:(1=args)						; Chose local or global indirect or not with or without subscript
	. . set argvar=$select(ind:"@",1:"")_$select($random(2):"^",1:"")_$select(ind:"i",1:"")_$select($random(2):"TRUE",1:"FALSE")
	. . set argvar=argvar_$select($random(2):$select(ind:"@",1:"")_"("_$random(2)_")",1:"")
	. . set fterm="$get("_argvar_")"
	. set:(2=args) fterm="$get("_$select(ind:"@",1:"")_$select($random(2):"^",1:"")_$select(ind:"bogus",1:"unknwn")_","_$random(2)_")"
	if ("$next"=tfuncs(ftype)) do  quit fterm		; Covers $next()
	. set argvar=$select(ind:"@",1:"")_$select($random(2):"^",1:"")_$select(ind:"i",1:"")_$select($random(2):"TRUE",1:"FALSE")
	. set argvar=argvar_$select(ind:$select(ind:"@",1:"")_"(",1:"(")_($random(2)-1)_")"
	. set fterm="$next("_argvar_")"
	if ("$order"=tfuncs(ftype)) do  quit fterm		; Covers $order() (1 and 2 arg types with 2nd arg constant or var ref)
	. new args
	. set args=$random(2)+1					; 1 or 2 args
	. set argvar=$select(ind:"@",1:"")_$select($random(2):"^",1:"")_$select(ind:"i",1:"")_$select($random(2):"TRUE",1:"FALSE")
	. set argvar=argvar_$select(ind:"@(",1:"(")
	. do:(1=args)						; 1 arg is always "forward"
	. . set argvar=argvar_($random(2)-1)_")"
	. . set fterm="$order("_argvar_")"
	. do:(2=args)
	. . new dir
	. . set dir=$random(2)					; Forward or backwards
	. . set:(0=dir) argvar=argvar_($random(2)-1)_")"	; Forward
	. . set:(1=dir) argvar=argvar_($random(2)+1)_")"	; Backward
	. . set fterm="$order("_argvar_","_$select(dir:-1,1:1)_")"
	if ("$query"=tfuncs(ftype)) do  quit fterm		; Covers $query() - Form generated: @($query(varref)) - returns bool value
	. set argvar=$select(ind:"@",1:"")_$select($random(2):"^",1:"")_$select(ind:"i",1:"")_$select($random(2):"TRUE",1:"FALSE")
	. set argvar=argvar_$select(ind:"@(",1:"(")_($random(2)-1)_")"
	. set fterm="@($query("_argvar_"))"
	if ("$select"=tfuncs(ftype)) do  quit fterm		; Covers $select()
	. set argvar=$select(ind:"@",1:"")_$select($random(2):"^",1:"")_$select(ind:"i",1:"")_$select($random(2):"TRUE",1:"FALSE")
	. set argvar=argvar_$select($random(2):$select(ind:"@",1:"")_"("_$random(2)_")",1:"")
	. set fterm="$select("_argvar_":1,1:0)"
	if ("$zahandle"=tfuncs(ftype)) do  quit fterm		; Covers $zahandle() - creates relational expression between $ZAH() for 2 vars
	. new argvar1,argvar2
	. set argvar1=$select(ind:"@",1:"")_$select(ind:"i",1:"")_$select($random(2):"TRUE",1:"FALSE")
	. set argvar1=argvar1_$select($random(2):$select(ind:"@",1:"")_"("_$random(2)_")",1:"")
	. set argvar2=$select(ind:"@",1:"")_$select(ind:"i",1:"")_$select($random(2):"TRUE",1:"FALSE")
	. set argvar2=argvar2_$select($random(2):$select(ind:"@",1:"")_"("_$random(2)_")",1:"")
	. set fterm="($zahandle("_argvar1_")]$zahandle("_argvar2_"))"
	if ("$zprevious"=tfuncs(ftype)) do  quit fterm		; Covers $zprevious() - same as $order() backward without 2nd arg
	. set argvar=$select(ind:"@",1:"")_$select($random(2):"^",1:"")_$select(ind:"i",1:"")_$select($random(2):"TRUE",1:"FALSE")
	. set argvar=argvar_$select(ind:"@(",1:"(")_($random(2)+1)_")"
	. set fterm="$zprevious("_argvar_")"
	if ("$zqgblmod"=tfuncs(ftype)) do  quit fterm		; Covers $zqgblmod() - no replication so always returns 1
	. set argvar=$select(ind:"@",1:"")_$select(ind:"^i",1:"^")_$select($random(2):"TRUE",1:"FALSE")
	. set fterm="$zqgblmod("_argvar_")"
	;
	; Should never reach here
	;
	use $p
	write "ASSERT - unknown func type: ",ftype,!
	zshow "*"
	zhalt 1

;
; NextOp - nxtopandpct% chance for AND, else is OR
;
NextOp()
	new opp
	set opp=$random(100)
	quit:(nxtopandpct>opp) "&"
	quit "!"

;
; NewParenLevel - baseoprnpct% less 10% for each paren nesting level
;
NewParenLevel()
	quit (($random(100)+baseoprnpct-(10*prnnest))>99)

;
; CloseParenLevel - basecprnpct plus 10% for each paren nesting level
;
CloseParenLevel()
	quit:(curtrm>(minterms+2)) 1		; We are about done here
	quit (($random(100)+basecprnpct+(10*prnnest))>99)

;
; Initialize all the parts/pieces we need to generate a boolean expression. Note there is no guarantee what these expressions
; resolve to - except that they are boolean expressions.
;
Init
	set $etrap="do Error^"_$Text(+0)
	;
	; Configuration parms
	;
	set baseoprnpct=33	; Base open paren percentage. Is reduced by multiples of paren nesting
	set basecprnpct=40	; Base close paren percentage. Is increased by multiples of paren nesting
	set nxtopandpct=35	; Next operator this percent to be AND, else is an OR operator
	set numterms=5		; Minimum terms in expression is $random(numterms)+3. Max is min +5
	;
	; Initialization
	;
	set TAB=$Char(9)
	;
	; Types of terms used in generated expressions. If anything changes in these terms, may need to adjust code
	; in NextTerm routine. Note changing order or new term added requires update in NextTerm() routine.
	;
	set ttypes(0)="constant"		; Constant TRUE/FALSE value (i.e. 1 or 0)
	set ttypes(1)="$test"			; Binary result ISV
	set ttypes(2)="extrinsic"		; One of $$Always0, $$Always1, $$RetSame(x) or $$RetNot(x)
	set ttypes(3)="variable"		; Local and global vars (may be indirect, subscripted by 0 or 1 or passed by reference)
	set ttypes(4)="relexpr"			; Generate a relational expression of terms
	set ttypes(5)="function"		; Generates function usages or an expression with tfuncs() function in it
	set ttypecnt=$order(ttypes(""),-1)+1	; Highest + 1 since 0 origin
	;
	; Types of functions generated. For all of these, the argument is either fixed or indirect. If a boolean
	; return from the function is not possible, gets turned into an expression possibly subtracting two types so the
	; end result is always a boolean value. Note if anything changes in these function names, may need to adjust
	; code in GenFuncTerm routine.
	;
	set tfuncs(0)="$increment"		; Generates an expr.
	set tfuncs(1)="$data"			; Argument is ^TRUE or TRUE with subscript 1, or 2
	set tfuncs(2)="$get"			; Argument one of the t/f vars, optional 2nd arg
	set tfuncs(3)="$next"			; Argument is t/f var with subscript -1 or 0.
	set tfuncs(4)="$order"			; 2 types, forward and backward. Otherwise same as $next()
	set tfuncs(5)="$query"			; Similar to $next() when surrounded by @(..) to eval it
	set tfuncs(6)="$select"			; Argument is one of the truth vars
	set tfuncs(7)="$zahandle"		; Generates an expr relating $zahandle() of two vars
	set tfuncs(8)="$zprevious"		; Similar to backwards $order()
	set tfuncs(9)="$zqgblmod"		; Arg is gvn t/f var. Since no replication, always return 1.
	set tfunccnt=$order(tfuncs(""),-1)+1	; Highest + 1 since 0 origin
	;
	; Set of relational ops we can generate in the relational expression.
	;
	set relop(0)="="
	set relop(1)="'="
	set relop(2)="<"
	set relop(3)="'<"
	set relop(4)=">"
	set relop(5)="'>"
	set relop(6)="["
	set relop(7)="'["
	set relop(8)="]"
	set relop(9)="']"
	set relop(10)="]]"
	set relop(11)="']]"
	set relopcnt=$order(relop(""),-1)+1	; Highest + 1 since 0 origin
	;
	; Types of tokens added to expression. When assigned into lasttk() array, helps keep track of the last
	; token type generated at a given paren nesting level.
	;
	set tkoparen=1				; Open paren
	set tkclparen=2				; Close paren
	set tkterm=3				; One of the term types above
	set tkop=4				; Operator (& or !)
	;
	; Define vars used in the actual boolean expressions
	;
	; We count on $ZAHandle(TRUE)]$ZAHandle(FALSE) evaluate to a fixed value (say 0) across all versions
	; hence we first allocate two dummy local vars and find out whose address is higher and assign that to
	; alias variables TRUE and FALSE based on their value (since $ZAHandle of an alias variable is same as
	; that of the base variable.
	;
	set dummyfalse=0,dummytrue=1
	if $zahandle(dummyfalse)]$zahandle(dummytrue) do
	. set *TRUE=dummyfalse,*FALSE=dummytrue
	else  set *TRUE=dummytrue,*FALSE=dummyfalse
	set TRUE=1,FALSE=0,iTRUE="TRUE",TRUE(-1)=1,TRUE(0)=1,TRUE(1)=1,TRUE(2)=1
	set ^iTRUE="^TRUE",^TRUE=1,^TRUE(-1)=1,^TRUE(0)=1,^TRUE(1)=1,^TRUE(2)=1
	set iFALSE="FALSE",FALSE(-1)=0,FALSE(0)=0,FALSE(1)=0,FALSE(2)=0
	set ^iFALSE="^FALSE",^FALSE=0,^FALSE(-1)=0,^FALSE(0)=0,^FALSE(1)=0,^FALSE(2)=0
	set bogus="unknwn",^bogus="^unknwn",^dummy=0
	set incrvar=0,indincrvar="incrvar",zl=$zlevel
	set nextt=$random(2)			; Preload for $TEST with either 0 or 1 generated randomly
	set lasttstnaked=1		  	; Pretend we had to set naked last time to force initialization first time thru
	quit

;
; Routine to create and initialize the executable to be written out (if any)
;
CreateRoutine(fn)
	set fn=$get(fn,"btest.m")
	;
	; Open output file and start generating..
	;
	set ofile=fn
	Open ofile:new
	use ofile
	write ";",!
	write "; Generated test program - header created by ",$text(0),!
	write ";",!
	write "; First - some initialization of values used in the generated expressions.",!
	write ";",!
	write TAB,"set $etrap=""set $etrap="""""""" write $zstatus,! zshow """"*"""" zhalt 1""",!
	write ";",!
	write "; We count on $zahandle(TRUE)]$zahandle(FALSE) evaluate to a fixed value (say 0) across all versions",!
	write "; hence we first allocate two dummy local vars and find out whose address is higher and assign that to",!
	write "; alias variables TRUE and FALSE based on their value (since $zahandle of an alias variable is same as",!
	write "; that of the base variable",!
	write ";",!
	write TAB,"set dummyfalse=0,dummytrue=1",!
	write TAB,"if $zahandle(dummyfalse)]$zahandle(dummytrue) do",!
	write TAB,". set *TRUE=dummyfalse,*FALSE=dummytrue",!
	write TAB,"else  set *TRUE=dummytrue,*FALSE=dummyfalse",!
	write TAB,"set TRUE=1,FALSE=0,iTRUE=""TRUE"",TRUE(-1)=1,TRUE(0)=1,TRUE(1)=1,TRUE(2)=1",!
	write TAB,"set ^iTRUE=""^TRUE"",^TRUE=1,^TRUE(-1)=1,^TRUE(0)=1,^TRUE(1)=1,^TRUE(2)=1",!
	write TAB,"set iFALSE=""FALSE"",FALSE(-1)=0,FALSE(0)=0,FALSE(1)=0,FALSE(2)=0",!
	write TAB,"set ^iFALSE=""^FALSE"",^FALSE=0,^FALSE(-1)=0,^FALSE(0)=0,^FALSE(1)=0,^FALSE(2)=0",!
	write TAB,"set bogus=""unknwn"",^bogus=""^unknwn"",^dummy=0",!
	write TAB,"set incrvar=0,indincrvar=""incrvar"",zl=$zlevel",!
	write TAB,"set nextt=",$random(2),"    ; Preload for $TEST with either 0 or 1 generated randomly",!
	set lasttstnaked=1		  ; Pretend we had to set naked last time to force initialization first time thru
	quit

;
; Generate end of file and additional routines
;
GenEndOfFile(callback)
	use ofile
	write TAB,"quit",!
	;
	; Create driven functions
	;
	write !,"Always0()",!
	write TAB,"quit 0",!
	write "Always1()",!
	write TAB,"quit 1",!
	write "RetSame(x)",!
	write TAB,"quit x",!
	write "RetNot(x)",!
	write TAB,"quit '(x)",!
	do:(""'=$get(callback)) @callback
	;
	; All done!
	;
	close ofile
	use $p
	quit

;
; do necessary for outputting debug messages to $p. Useful to debug changes to above rtns since can be
; used without changing $io around (this rtn takes care of that). Rtn used for debugging.
;
dbgzwrite(zwrarg,sfx)
	new saveio
	do DoWrite("DbgZwrite ----------- "_$select(""'=$get(sfx,""):"("_sfx_")",TRUE:"")_":")
	set saveio=$io
	use $p
	zwrite @zwrarg
	use saveio
	quit

;
; Routine to write text $p while doing other IO. Can be used instead of dbgzwrite if more appropriate.
;
DoWrite(msg)
	new saveio
	set saveio=$io
	use $p
	write msg,!
	use saveio
	quit

;
; Error handler
;
Error
	set $etrap=""
	use $p
	write $zstatus,!!
	zshow "*"
	zhalt 1
