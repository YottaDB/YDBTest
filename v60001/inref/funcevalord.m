;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2012, 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; funcevalord generate fncevlordtst.m to check order of evaluation of function arguments, then run it
;
; GT.M order of function argument test (GTM-3907).
; Order of evaluations for functions test. Generally checking that functions with "inter-argument dependencies"
; are handled correctly so that when an argument is $Increment() or an extrensic that modifies a previous
; argument, argument evaluation doesn't modify the actual value passed. This is because the M standard says that
; arguments are evaluated in order and processing after an arguments evaluation should not change its value in
; that instance unless the argument is passed by value - then all bets are off.
;
; Methodology - given a list of functions to test and  internal functions that specialize in tests for the given
; function, generate tests with a subscripted and unsubscripted, indirect and non-indirect first argument with
; at least some of the subsequent arguments being one of a set of extrinsics that both supply the value to be
; passed to the function and muck with the first argument. Generate the test cases in a generated M program then
; invoke the generated test routine if "rungenfile" in the prologue below is enabled.
;
; Note the generated routine contains epilogue and prologue code that is defined by labels further down in this
; routine which are copied to the generated routine.
;
; Note the following functions are not tested here for the reasons stated:
;
;   1. Function has only one argument:  $[Z]DATA(), $NEXT() $QLENGTH() $QUERY() $RANDOM(), $REVERSE(), $TEXT(), $ZAHANDLE(),
;      $ZBITCOUNT(), $ZBITLEN(), $ZBITNOT(), $ZJOBEXAM(), $ZMESSAGE(), $ZPREVIOUS(), $ZQGBLMOD(), $ZWIDTH(), $ZWRITE()
;   2. Function has reverse evaluation order: $INCREMENT()
;
; Overall test architecture:
;
;   1.  Code generation for each test is done in a routine named GenTest<function-name>. Some functions are stacked with
;       multiple labels if the code generation for them is the same.
;   2.  The target variable is chosen. This is a combination of subscripted or not (which defines the setup variable)
;       and indirect or not to determine which of %, %(1), @%i, or @%i@(1) gets used.
;   3.  Some functions have multiple argument counts being tested (e.g. 3 and 4 argument $PIECE() invocations). These
;       tests are described in the MultiArg() array setup below.
;   4.  If multiple arg counts are being tested for a function, which of the counts to pick is randomized.
;   5.  Some functions (those that support it) are generated as SET functions (i.e. $[Z]PIECE(), $[Z]EXTRACT()).
;   6.  The %r() array stores the results of information at each extrinsic. They show how the target var can be modified
;       at each extrinsic in the argument list (there can be several).
;   7.  The initial value of the target value is also stored in %r(0).
;   8.  For simple extrinsics where the modified target var value can be used as the argument, the %r() array elements show
;       that value.
;   9.  When the modified value of the target var is not appropriate for an argument, the modifying extrinsics can be
;       "wrapped" with $$WrapFunc() whose first argument is the modifying extrinsic and the 2nd arg of which is the value
;       to return to the function. Some of the piece-related extrinsics take care of this in their own way.
;   10. When a function is wrapped, there are two or more values to keep track of - the modified target var and the value
;       that was returned. In this situation, the %r(n) value can hold both separated by a multi-char separator defined
;       in the %rsep variable.
;   11. The test executes the function with the given target var and extrinsic arguments and saves its result in %r1.
;   12. If the value to return is not obvious, the test sets the result of a function with non-modifying arguments into
;       %r2 then checks the values for differences. If the code fails with an error or %r1 does not equal %r2, the test
;       is considered to have failed.
;   13. There is a debug switch (which is copied to the generated tests) that prints out more information than a regular
;       failure even printing some values out on a pass that can help debug issues.
;   14. Below the code for the test generation are two sets of routines and definitions, the prologue and epilogue code.
;       Both of these are copied respectively to the start and end of the generated routine.
;
; List of functions with strategy statements:
;
; Total funcs to cover (excludes Z-mode func and its UTF8 form counted as 1): 30; single arg funcs (not needed): 17
; 1.  x $ASCII(str<,index>)
;       Test with numeric string 1-10 digits, index is a modulo-10 extrinsic
; 2.  x $[Z]CHAR(dec1<,dec2..>)
;       Generate random number of chars, start with fixed (random) and use $increment on arg successive times.
; X $[Z]DATA() - *********** bypass due to single arg
; 3.  x $[SET ][Z]EXTRACT(expr<,intexp1<,intexp2>>)
;       Test with 2 and 3 arg versions.
;       2 arg version - similar to $ASCII
;       3 arg version - interaction between intexp1/2. Use $Increment and/or extrinsic to add 1.
; 4.  x $[Z]FIND(expr<,expr2<,intexp>>)
;       Test with 2 and 3 arg versions. Both are similar with random number less than where string was found as intexp.
; 5.  x $FNUMBER(numexp<,strcode<,digits>>)
;       Test with 3 arg version with random selection(s) for arg2. Use $ASCII technique for args 1 and 3.
; 6.  x $GET(lvn1<,lvn2>)
;       Test 2 argument version with 2nd being a modified type of the first but 1st arg randomly undefined (75% of time)
; X $INCREMENT(glvn,glvn) - *********** bypass due to internal operator evaluation order (right to left).
; 7.  x $[Z]JUSTIFY(expr,intexp1<,intexp2>)
;       Test 2 and 3 arg versions. Only 2 arg version needs Z-format as 3 arg version always numeric.
; 8.  x $[Z]LENGTH(expr<,expr2>)
;       Test 2 arg version with 2nd arg calling extrinsic that modifies 1st arg and returning 1 char from the first.
; 9.  x $NAME(lvnexp<,intexp>)
;       Test 2 arg version. Make sure there are references before/after the one given, do + and - values, check result
; X $NEXT(glvn) - *********** bypass due to single arg
; 10. x $ORDER(glvn<,intdir>)
;       Use 2 arg form. Ways to test:
;         1. 2nd arg modifies index in first arg
;         2. 2nd arg kills first arg
; 11. x $[Z]PIECE(expr1,expr2<,intexp1<,intexp2>>) - Note also has SET variant to test
;       Use 3 and 4 arg versions. Ways to test:
;         1. Each arg is $incr() from last
;         2. Use extrinsics.
;         3. 2nd arg fixed with only args 2 & 3 changing
; X $QLENGTH(glvn) - *********** bypass due to single arg
; 12. x $QSUBSCRIPT(glvn, intexp)
;     2nd arg should either break the subscript or modify it in some fashion.
; X $QUERY(glvn) - *********** bypass due to single arg
; X $RANDOM(intexp) - *********** bypass due to single arg
; X $REVERSE(expr) - *********** bypass due to single arg
; 13. x $SELECT(tvexpr:expr,..)
;       Use simplistic var as tvexpr and modify it in subsequent expressions.
; 14. x $STACK(intexp<,expr>)      Pass intexp as a var that gets modified in the extrinsic called for the 2nd argument.
; X $TEXT(entryref) - *********** bypass due to single arg
; 15. x $[Z]TRANSLATE(srcexpr<,inpexp<,outpexp>>)
;       Test 2 arg version to remove chars specified.
;       Test 3 arg version to change a single char with 2nd char $incremented;
;       test numerics & strings by using numeric as subscript to a range of letters for strings and use numbers directly.
; 16. x $VIEW(expr1<,expr2)
;       Decide set on expr1/expr2 and have extrinsic modify expr1 as it returns expr2; expr2 must be valid for both expr1's
; X $ZAHANDLE(lvn) - *********** bypass due to single arg
; 17. x $ZBITAND(bitexp1,bitexp2)
;       Use wrapped extrinsic as bitexp2 to modify or recreate bitexp1 but returning what we want (2nd generated bit expression).
; X $ZBITCOUNT(bitexp) - *********** bypass due to single arg
; 18. x $ZBITFIND(bitexp,tvexpr<,bitindx>)
;       Test 2 and 3 argument version with and extrinsic for 2nd and 3rd args.
; 19. x $ZBITGET(bitexp,bitindx)
;     Test with random bit string and extrinsic for bitindx returning random bit and modifying arg1
; X $ZBITLEN(bitexp) - *********** bypass due to single arg
; X $ZBITNOT(bitexp) - *********** bypass due to single arg
; 20. x $ZBITOR(bitexp1,bitexp2)
;       Same as $ZBITAND()
; 21. x $ZBITSET(bitexp,bitindx,tvexpr)
;       Test 3 arg form with 2 modifying extrinsic calls.
; 22. x $ZBITSTR(intexp<,tvexpr>)
;       Test 2 arg form with modifying extrinsic as 2nd parm.
; 23. x $ZBITXOR(bitexp1,bitexp2)
;       Basically same as $zbitor
; 24. x $ZCONVERT(expr1,expr2<,expr3>)
;       Test 2 arg version where extrinsic in 2nd arg modifies arg1
; 25. x $ZDATE(expr1<,expr2<,expr3<,expr4>>>)
;       Test 2 arg version: arg2 is an extrinsic that KILLs the first arg or modifies the first arg.
; X $ZJOBEXAM(expr) - *********** bypass due to single arg
; X $ZMESSAGE(intexp) - *********** bypass due to single arg
; 26. x $ZPARSE(expr1<,expr2<,expr3<,expr4<,expr5>>>>)
;       Test 2, 3, and 4 arg versions. 2nd arg is "NAME" either directly or indirectly. In all cases, set the 5th
;       arg to "SYNTAX" so doesn't look for the files we are referencing (which we don't care about).
;       Args 3 and 4 (when specified) are partial specifications.
; X $ZPREVIOUS(glvn) - *********** bypass due to single arg
; X $ZQGBLMOD(gvn) - *********** bypass due to single arg
; 27. x $ZSEARCH(expr<,intexp>)
;       Test 2 argument version where 2nd arg is an extrinsic that messes with arg1 and returns 42.
; 28. x $ZSUBSTR(expr,intexp1<,intexp2>)
;       Nearly identical to $[Z]FIND() - main diff is intexp2 which specifies length intead of end byte
; 29. $ZTRIGGER(expr1<,expr2>)
;     Test 2 argument version. First arg can be either of the 3 forms while 2nd arg removes the first arg.
; 30. x $ZTRNLNM(expr<,expr2<,expr3<,expr4<,expr5<,expr6>>>>>)
;       Test with two args (1 & 6). check both value returned and length of value when 6th arg extrinsic modifies source.
; X $ZWIDTH(expr) - *********** bypass due to single arg
; X $ZWRITE(expr) - *********** bypass due to single arg
;**********************************************************************************************************************************
;
	; Initialization - change the 3 values below as desired
	;
	Set numtests=500				; Number of random tests to generate
	Set rungenfile=1				; When 1, drives the created test
	Set debug=0					; See 13, above
	Set maxattempts=101				; Max attempts at randomization of alternate arguments
	;
	Set rtnname=$Text(+0)
	Set $ETrap="Do GTMError^"_rtnname_"($ZStatus)"	; Uses stripped down error handler from gtmpcat
	Set entrylvl=$ZLevel
	Set alphalowc="abcdefghijklmnopqrstuvwxyz"
	Set alphauppc="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	Set alpha=alphalowc_alphauppc
	Set alphalen=$ZLength(alpha)
	Set numerics=1234567890
	Set alphanumerics=alpha_numerics
	Set alphanumlen=$ZLength(alphanumerics)
	Set outfile="fncevlordtst.m"
	Set outfileopen=0
	Set TAB=$ZChar(9)
	Set %rsep="<>"					; Need double byte separator char for %rsep since any char can appear in these generated  strings
	Set %rsepchar=$Char(60,62,17,37)		; %rsep characters and their bit reverses
	Set statfile="GenStatReport.txt"
	;
	; Define set of supported functions
	; Implementation note: Change the set of funcs to a subset to generate cases only for those funcs if necessary to
	; concentrate tests on a smaller set of functions or a single function.
	;
	Set funcs="$Ascii,$Char,$ZChar,$Extract,$ZExtract,$Find,$ZFind,$FNumber,$Get,$Justify,$ZJustify,$Length,$ZLength,$Name"
	Set funcs=funcs_",$Order,$Piece,$ZPiece,$QSubscript,$Select,$Stack,$Translate,$ZTranslate,$View,$ZBitAnd,$ZBitFind,$ZBitGet"
	Set funcs=funcs_",$ZBitOr,$ZBitXOr,$ZBitSet,$ZBitStr,$ZDate,$ZParse,$ZSearch,$ZSubstr,$ZTrnlnm"
	If $ZVersion'["VMS" Set funcs=funcs_",$ZConvert" If $ZVersion'["HP-PA" Set funcs=funcs_",$ZTrigger"	;avoid unsupported functions
	;Set funcs="$Ascii"
	;Set funcs="$Char,$ZChar"
	;Set funcs="$Extract,$ZExtract"
	;Set funcs="$Find,$ZFind"
	;Set funcs="$FNumber"
	;Set funcs="$Get"
	;Set funcs="$Justify,$ZJustify"
	;Set funcs="$Length,$ZLength"
	;Set funcs="$Name"
	;Set funcs="$Order"
	;Set funcs="$Piece,$ZPiece"
	;Set funcs="$QSubscript"
	;Set funcs="$Select"
	;Set funcs="$Stack"
	;Set funcs="$Translate,$ZTranslate"
	;Set funcs="$View"
	;Set funcs="$ZBitAnd"
	;Set funcs="$ZBitFind"
	;Set funcs="$ZBitGet"
	;Set funcs="$ZBitOr"
	;Set funcs="$ZBitXOr"
	;Set funcs="$ZBitSet"
	;Set funcs="$ZBitStr"
	;Set funcs="$ZConvert"
	;Set funcs="$ZDate"
	;Set funcs="$ZParse"
	;Set funcs="$ZSubstr"
	;Set funcs="$ZSearch"
	;Set funcs="$ZTrigger"
	;Set funcs="$ZTrnlnm"
	;Set funcs="$Extract,$ZExtract,$Piece,$ZPiece"
	Set fnccnt=$ZLength(funcs,",")
	;
	; Argument var for unsubscripted and subscripted referrals
	;
	Set vset(0)="%"
	Set vset(1)="%(1)"
	;
	; Variable access  or without indirection
	;
	Set vuse(0,0)="%"
	Set vuse(0,1)="@%i"
	Set vuse(1,0)="%(1)"
	Set vuse(1,1)="@%i@(1)"
	;
	; Functions supporting a SET attribute thusly marked
	;
	Set SetFunc("$Extract")=1
	Set SetFunc("$ZExtract")=1
	Set SetFunc("$Piece")=1
	Set SetFunc("$ZPiece")=1
	;
	; Functions we support more than 1 argument set (i.e. different runs generate different #'s of args for same function).
	;
	Set MultiArg("$Extract")="2|3"
	Set MultiArg("$ZExtract")="2|3"
	Set MultiArg("$Find")="2|3"
	Set MultiArg("$ZFind")="2|3"
	Set MultiArg("$Justify")="2|3"
	Set MultiArg("$ZJustify")="2|3"
	Set MultiArg("$Piece")="3|4"
	Set MultiArg("$ZPiece")="3|4"
	Set MultiArg("$Translate")="2|3"
	Set MultiArg("$ZTranslate")="2|3"
	Set MultiArg("$ZBitFind")="2|3"
	Set MultiArg("$ZParse")="2|3|4"
	Set MultiArg("$ZSubstr")="2|3"
	;
	; Functions test for which use both subscripted and unsubscripted vars. Causes test info line in generated code to show extra
	; fields for both var types.
	;
	Set SubUnSub("$Get")=1
	Set SubUnSub("$Order")=1
	;
	; Some tests don't have all that many variations and some (like $ZTrigger()) are incredibly slow. This array defines the odds
	; of rejecting some of those tests. A random number is generated with the value of each of the functions defined below. If the
	; value is not zero, we'll re-generate the test. So the higher the number, the fewer times it will be generated.
	;
	Set RegenFactor("$QSubscript")=3
	Set RegenFactor("$Stack")=3
	Set RegenFactor("$ZBitGet")=3
	Set RegenFactor("$ZBitStr")=4
	Set RegenFactor("$ZSearch")=4
	Set RegenFactor("$ZTrigger")=10
	Set RegenFactor("$ZTrnlnm")=3
	;
	; Open generated routine output file
	;
	Open outfile:New
	Use outfile
	Set outfileopen=1
	;
	; Write out test prologue code (between labels PrologueStart and PrologueEnd
	;
	For i=1:1 Set line=$Text(PrologueStart+i^@rtnname) Quit:("PrologueEnd"=line)  Set:(" "=$ZExtract(line,1)) $ZExtract(line,1)=TAB Write line,!
	Write TAB,"Set debug=",debug,!				; Write out same debug flag we used in generation
	Write TAB,"Set %rsep=""",%rsep,"""",!			; .. same with %rsep
	Write TAB,"Set %rsepchar=",$ZWrite(%rsepchar),!		; .. same with %rsepchar
	Write TAB,"ZSystem:(debug) ""rm -f ztrig*.txt >& /dev/null""",!	; Get rid of previous test files if running in debug
	;
	; Main test case generation loop
	;
	For testcase=1:1:numtests Do
	. Set pcsep=0					; Test case uses (used) a separator in call to $$GenRandStr() and various piece mod rtns
	. Set argcnt=0
	. Set funcnm=$ZPiece(funcs,",",$Random(fnccnt)+1)	; Function name
	. Do:((10<fnccnt)&(0<$Data(RegenFactor(funcnm))))	; Test regen if more than 10 funcs and this one is less-used
	. . Set redo=(0<$Random(RegenFactor(funcnm)))	; Only keep this selection if value is 0
	. . Quit:('redo)				; Continue if not re-generating the function name
	. . Set testcase=testcase-1			; Recover test # we were just starting
	. . ZGoto -2					; Resumes testcase loop redoing last selection
	. Set GenStat(funcnm)=$Get(GenStat(funcnm),0)+1	; Bump counter for this function
	. Set indirect=(0=$Random(4))			; Generate as indirect (25% of time - indirects seem to tend to pass more often than not)
	. Set indirect2=(0=$Random(5))			; Indirect on 2nd arg 20% of time
	. ;
	. ; To override indirect choice, uncomment the line below (0 = noindirect, 1=indirect).
	. ;
	. ;Set indirect=0
	. Set setvar=$Random(2)				; 0 = function, 1 = SET variant (for those functions thusly supported)
	. ;
	. ; Reset statement below for fixed generations: 0 for no SET funcs, 1 for all SET funcs. Note, after writing this
	. ; test it was determined SET $(PIECE,EXTRACT) don't behave the way the function version does so this is permanently set
	. ; for NO set-varient testing. The code is left in here in case someone wants to do something different with this code
	. ; in the future.
	. ;
	. Set setvar=0					; No SET variations for this test
	. Set subscriptd=$Random(2)                     ; 0 = unsubscripted, 1 = subscripted
	. Set defined=(0<$Random(5))			; Decide if initial value is to be defined or not (undef 20% of time)
	. Set argidx=$ZLength($Get(MultiArg(funcnm),""),"|")	; See if function to be tested with multiple arg counts
	. Set:(1=argidx) argidx=0			; If not a multi-arg function, set to 0 to indicate no arg considerations
	. Set:(argidx) argcnt=$ZPiece(MultiArg(funcnm),"|",$Random(argidx)+1)
	. Set varsetup=vset(subscriptd)
	. Set vartest=vuse(subscriptd,indirect)
	. Write !,TAB,";",!,TAB,"; Generated test #",testcase," for ",$Select($Get(SetFunc(funcnm),0)&setvar:"Set ",1:""),funcnm,"()"
	. Write:("$Get"=funcnm) "  DefinedVar: ",defined
	. Write "  Indirect: ",indirect
	. Write:($Get(SubUnSub(funcnm))) "  Indirect2: ",indirect2
	. Write:('$Get(SubUnSub(funcnm))) "  testvar: ",vartest
	. Write $Select(argcnt:"  Argcnt: "_argcnt,1:""),!,TAB,";",!
	. Write "Test",testcase,?7," Set tc=",testcase,! ; Easy to identify from zwrite which test failed.
	. Write TAB,"Write:(debug) !,""Starting testcase #",testcase,""",!",!
	. Write TAB,"Kill %,%r,%rx,%r1,%r2",!
	. Do @("GenTest"_$Piece(funcnm,"$",2))		; strip leading '$' from function name
	. Write TAB,"ZWrite:(debug&(0<$Data(%))) %",!
	. Write TAB,"ZWrite:(debug) %r,%r1,%r2",!	; When debugging tests, enabling this can be useful (modify debug in Prologue section)
	. Write TAB,"Kill ",varsetup,!			; Clear this tests's input out so no interference with next one.
	. Write:(pcsep) TAB,"Kill %psep",!
	;
	; Write out the epilogue that includes routines needed for the generated test cases.
	;
	Write !,TAB,";",!
	Write TAB,"; Write summary and we're done (Label below in case last test fails and needs a resume point)",!
	Write TAB,";",!
	Write "Test",testcase+1,?7," Write:(0<errcnt) !,""Total of "",errcnt,"" failures out of ",numtests," test cases - FAIL"",!",!
	Write TAB,"Write:(0=errcnt) !,""All ",numtests," tests completed - PASS"",!",!
	Write TAB,"Close:(ztrigoutopen) ztrigout",!
	Write TAB,"ZGoto 1:AllDone^"_$Text(+0),!!
	For i=1:1 Set line=$Text(EpilogueStart+i^@rtnname) Quit:("EpilogueEnd"=line)  Set:(" "=$ZExtract(line,1)) $ZExtract(line,1)=TAB Write line,!
Done
	Close:(outfileopen) outfile
	Set outfileopen=0
	Open statfile:New
	Use statfile
	Write "Generation counts for each function:",!!
	ZWrite GenStat
	Close statfile
	Use $P
	Write numtests," testcases generated into ",outfile,!
	Do:(rungenfile)
	. Write !,"Invoking generated script",!!
	. Kill (outfile)				; Isolate test from our vars except outfile which is needed to get it ago'n
	. ZGoto @("1:^"_$ZPiece(outfile,".",1))
	;
AllDone	Break

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Set of routines generating tests for various functions. Labels in the form GenTest<Funcname>. The variable funcnm contains
; the actual name of the function so one generation function can provide the generation for several different functions,
; providing they are similar enough, by just stacking the labels.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Routine to generate tests for $ASCII()
;
GenTestAscii
	New len								; NEW here but set in GenRandStr()
	New genlen,extrlist,extrcnt
	Set extrlist="$$ReverseRet,$$RandStrRet"
	Set extrcnt=$ZLength(extrlist,",")
	;
	; Generate test rtn output
	;
	Set genlen=$$GenRandStr(10)					; Writes initialization of setup var and %r(0)
	Write TAB,"Set (%r1,%r2)=""""",!
	Write TAB,"For i=1:1:$ZLength(",vartest,") Do",!
	Set extrrtn=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	Write "Src",testcase,TAB,". Set %r1=%r1_",funcnm,"(",vartest,",",extrrtn,"(i))",!
	Write TAB,". Set %r2=%r2_",funcnm,"(%r(i-1),i)",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $[Z]CHAR().
; Note: At this time, $[Z]CHAR() does a COERCE() on each argument which buffers it sufficiently that it never fails in these
;       tests but we test it anyway.
;
GenTestChar
GenTestZChar
	New extrlist,extrcnt,i,cnt,arglst1,arglst2,func,idx
	;
	; Note $Increment needs to be last in this list as it is only conditionally added as the last argument. This is because it always
	; updates the target var so to prevent that update from contaminating the result, it has to be last. After the last arg, we don't
	; care what the value of the target var is, only what the arguments pass to the function.
	;
	Set extrlist="$$AddOne,$$SubOne,$Increment"
	Set extrcnt=$ZLength(extrlist,",")
	Set cnt=$Random(5)+1						; Number of additional arguments to generate (after first)
	Set:(0=(cnt#2)) cnt=cnt+1					; Make sure value is odd so don't have +1-1 issue and artificial pass
	Write TAB,"Set (%r(0),",varsetup,")=",$Random(128-cnt)+1,!	; First arg is var we are going to modify. Keep range low so creates ascii chars
	Set arglst1=vartest						; Var always starts first argument list
	Set arglst2="%r(0)"						; %r(0) always starts 2nd argument list
	For i=1:1:cnt Do
	. ;
	. ; When choosing the argument extrinsic/function, $Increment is only possible on the last arg because it
	. ; unconditionally increments the target var. Since we have no way to reduce the target between argument
	. ; evaluations for the control case, only allow it in the last arg.
	. ;
	. Set idx=$Random(extrcnt-$Select(i=cnt:0,1:1))+1
	. Set func=$ZPiece(extrlist,",",idx)
	. If ("$Increment"'=func) Do					; NOT $Increment()
	. . Set arglst1=arglst1_","_func_"()"
	. . Set arglst2=arglst2_",%r("_i_")"
	. Else  Do							; IS $Increment() (can only happen as last arg)
	. . Set arglst1=arglst1_","_func_"("_vartest_")"
	. . Set arglst2=arglst2_",%r("_i_")"
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",arglst1,")",!
	Write:("$Increment"=func) TAB,"Set %r(",i,")=%r(",i-1,")+1",!
	Write TAB,"Set %r2=",funcnm,"(",arglst2,")",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $[Z]EXTRACT() with an option to generate SET versions of both
; Note: Uses the same routines as $[Z]Piece so build strings it operates on the same way.
;
GenTestExtract
GenTestZExtract
	New extrlist,extrcnt,i,arglst1,arglst2,func,randpc,len,genlen
	Set extrlist="$$RemPieceRet,$$AddPieceRet,$$ModPieceRet"
	Set extrcnt=$ZLength(extrlist,",")
	;
	; Generate argument list
	;
	Set genlen=$$GenRandStr(50,20,"|")				; Should be in output section but sets genlen needed in arg setup
	Set randpc=$Random(genlen)+1				  	; Note genlen in pieces here
	Set arglst1=vartest
	Set arglst2=$Select(setvar:"%r0",1:"%r(0)")
	For i=1:1:argcnt-1 Do
	. Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	. Set arglst1=arglst1_","_func_"(0,"_(i-1)_","_randpc_")"
	. Set arglst2=arglst2_",$ZPiece(%r("_i_"),%rsep,2)"
	. Set randpc=randpc+$Random(2)					; Bump for next arg if is one
	;
	; Now generate test rtn output
	;
	Write:('setvar) "Src",testcase,TAB,"Set %r1=",funcnm,"(",arglst1,")",!
	Write:(setvar) "Src",testcase,TAB,"Set ",funcnm,"(",arglst1,")=""Set"_funcnm_"""",!
	Write:(setvar) TAB,"Set %r1=",vartest,!
	Write:('setvar) TAB,"Set %r2=",funcnm,"(",arglst2,")",!
	Write:(setvar) TAB,"Set %r0=%r(0)",!
	Write:(setvar) TAB,"Set ",funcnm,"(",arglst2,")=""Set"_funcnm_"""",!
	Write:(setvar) TAB,"Set %r2=%r0",!
	Do GenCompErr
	Write:(setvar) TAB,"Kill %r0",!
	Quit

;
; Routine to generate tests for $FIND() and $ZFIND().
;
GenTestFind
GenTestZFind
	New extrlist,extrcnt,i,randpc,arglst1,arglst2,func,len,genlen
	Set extrlist="$$RemPieceRet,$$AddPieceRet,$$ModPieceRet"
	Set extrcnt=$ZLength(extrlist,",")
	;
	; Generate argument list
	;
	Set genlen=$$GenRandStr(50,20,"|")				; Should be in output section but sets genlen needed in arg setup
	Set randpc=$Random(genlen)+1					; Note genlen in pieces here
	Set arglst1=vartest
	Set arglst2="%r(0)"
	For i=1:1:argcnt-1 Do
	. Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	. Set arglst1=arglst1_","_func_"(3,"_(i-1)_","_randpc_")"
	. Set arglst2=arglst2_",$ZPiece(%r("_i_"),%rsep,2)"
	. Set randpc=randpc+$Random(3)+1				; Bump for next arg if is one
	;
	; Now generate test routine output
	;
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",arglst1,")",!
	Write TAB,"Set %r2=",funcnm,"(",arglst2,")",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $FNUMBER()
;
GenTestFNumber
	New extrlist,extrcnt,func1,func2,i,codelist,fmtcode,fmtval,fmtdig
	Set extrlist="$$AddOne,$$SubOne,$$MullTen,$$DivTen"
	Set extrcnt=$ZLength(extrlist,",")
	Set func1=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	Set func2=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	Set codelist="+-,TP"
	Set fmtcode=$ZExtract(codelist,$Random($ZLength(codelist))+1)
	Set fmtval=$Select($Random(2):-1,1:1)*$Random(999999999)_"."_$Random(999999999)
	Set fmtdig=$Random(9)+1
	;
	; Generate test rtn output
	;
	Write TAB,"Set (%r(0),",varsetup,")=",fmtval,!
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",vartest,",$$WrapFunc(""",func1,""",""",fmtcode,"""),$$WrapFunc(""",func2,""",",fmtdig,"))",!
	Write TAB,"Set %r2=$FNumber(%r(0),$ZPiece(%r(1),%rsep,2),$ZPiece(%r(2),%rsep,2))",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $GET(). Only use $Increment in defined case. Otherwise, even $Increment(x,0) defines
; the var as zero meaning the first arg is returned instead of the 2nd.
;
GenTestGet
	New extrlist,extrcnt,func,funcarg
	Set extrlist="$$SetAlt"
	Set:(defined) extrlist=extrlist_",$$Unset,$$AddOne,$$SubOne,$Increment"
	Set extrcnt=$ZLength(extrlist,",")
	Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	If ("$Increment"=func) Set funcarg=varsetup
	Else  Set funcarg=""
	;
	; Generate test rtn output
	;
	Write:(defined) TAB,"Set (%r(0),",varsetup,")=",$Random(999999999)-499999999,!
	Write:('defined) TAB,"Kill ",varsetup,!
	Write:("$$SetAlt"=func) TAB,"Set altarg=",$Select($Random(2):-1,1:1)*$Random(999999999)_"."_$Random(999999999),!
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",vartest,",",func,"(",funcarg,"))",!
	Write TAB,"Set %r2=$Select((0=($Data(%r(0))#2)):altarg,1:%r(0))",!
	Do GenCompErr
	Write:("$$SetAlt"=func) TAB,"Kill altarg",!
	Quit

;
; Routine to generate tests for $[Z]JUSTIFY()
;
GenTestJustify
GenTestZJustify
	New extrlist,extrcnt,func,fmtlen,funcarg
	Set extrlist="$$AddOne,$$SubOne,$$MullTen,$$DivTen,$Increment"
	Set extrcnt=$ZLength(extrlist,",")
	Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	Set fmtlen=$Random(8)+5
	;
	; Now generate test rtn output
	;
	Write TAB,"Set (%r(0),",varsetup,")=",$Select($Random(2):"-",1:""),$Random(999),".",$Random(99999),!
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",vartest,",$$WrapFunc(""",func,""",",fmtlen,"))",!
	Write TAB,"Set %r2=",funcnm,"(%r(0),$ZPiece(%r(1),%rsep,2))",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $[Z]Length()
;
GenTestLength
GenTestZLength
	New extrlist,extrcnt,genlen,func,rmax,rmin,randpc
	Set extrlist="$$RemPieceRet,$$AddPieceRet,$$ModPieceRet"
	Set extrcnt=$ZLength(extrlist,",")
	Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	;
	; Generate test rtn output
	;
	Set rmax=$Random(50)+50
	Set rmin=$Random(10)+10
	Set genlen=$$GenRandStr(rmax,rmin,"|")
	Set randpc=$Random($ZLength(GenStr,"|"))+1
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",vartest,",",func,"(4,1,",randpc,"))",!
	Write TAB,"Set %r2=",funcnm,"(%r(0),$ZPiece(%r(1),%rsep,2))",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $NAME().
; Unlike other tests, this one sets up both % and %(%). The alternations are thus more limited as well - basically indirect or not
; and one of the functions. This is because we need both a subscripted as well as unsubscripted var.
; Note: The "indirect" flag only determines indirectness for the
;
GenTestName
	New extrlist,extrcnt,func,idx,vartest2,funcisIncr,elemidx
	Set extrlist="$$AddOne,$$SubOne"
	Set extrcnt=$ZLength(extrlist,",")
	Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	Set idx=$Random(99)
	Set:('indirect) vartest="%"
	Set:(indirect) vartest="@%i@"
	Set:('indirect2) vartest2="%"
	Set:(indirect2) vartest2="@%i"
	;
	; Generate test rtn output
	;
	Write TAB,"Set (%r(0),%)=",idx,!
	Write TAB,"Set %(%)=1",!
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",vartest,"(",vartest2,"),$$WrapFunc(""",func,""",1))",!
	Write TAB,"Set %r2=",funcnm,"(",vartest,"(%r(0)),$ZPiece(%r(1),%rsep,2))",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $[Z]PIECE() with an option to generate SET versions of both
; Note: Uses the same routines as $[Z]Extract so build strings it operates on the same way.
;
GenTestPiece
GenTestZPiece
	New extrlist,extrcnt,i,randpc,arglst1,arglst2,func,len,genlen
	Set extrlist="$$RemPieceRet,$$AddPieceRet,$$ModPieceRet"
	Set extrcnt=$ZLength(extrlist,",")
	;
	; Generate argument list
	;
	Set genlen=$$GenRandStr(50,20,"|")				; Should be in output section but sets genlen needed in arg setup
	Set randpc=$Random(genlen)+1				  	; Note genlen in pieces here
	Set arglst1=vartest_",%psep"
	Set arglst2=$Select(setvar:"%r0",1:"%r(0)")_",%psep"
	For i=1:1:argcnt-2 Do
	. Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	. Set arglst1=arglst1_","_func_"(1,"_(i-1)_","_randpc_")"
	. Set arglst2=arglst2_",$ZPiece(%r("_i_"),%rsep,2)"
	. Set randpc=randpc+$Random(2)					; Bump for next arg if is one
	;
	; Now generate output
	;
	Write:('setvar) "Src",testcase,TAB,"Set %r1=",funcnm,"(",arglst1,")",!
	Write:(setvar) "Src",testcase,TAB,"Set ",funcnm,"(",arglst1,")=""Set"_funcnm_"""",!
	Write:(setvar) TAB,"Set %r1=",vartest,!
	Write:('setvar) TAB,"Set %r2=",funcnm,"(",arglst2,")",!
	Write:(setvar) TAB,"Set %r0=%r(0)",!
	Write:(setvar) TAB,"Set ",funcnm,"(",arglst2,")=""Set"_funcnm_"""",!
	Write:(setvar) TAB,"Set %r2=%r0",!
	Do GenCompErr
	Write:(setvar) TAB,"Kill %r0",!
	Quit

;
; Routine to generate tests for $ORDER(). Similar to $NAME() which used both a subscripted and unsubscripted var in the test, $ORDER()
; does something similar which reduces the number of test cases that could otherwise be generated.
;
GenTestOrder
	New i,extrlist,extrcnt,subnum,sub,direction,vartest2,chr
	Set direction=$Select($Random(2):1,1:-1)			; Select +1 or -1 $Order() direction
	Set subnum=$Random(2)						; 0 is numeric subscript, 1 is string subscript
	If (subnum) Do							; Numeric subscript
	. Set sub=$Random(127-1)+1
	. Set:(0<direction) extrlist="$$AddTwo"
	. Set:(0>direction) extrlist="$$SubTwo"
	Else  Do							; String subscript
	. Set chr=$ZExtract(alpha,$Random(alphalen-4)+3)		; Single char (no numerics) subscript - easy to modify
	. Set sub=""""_chr_""""
	. Set:(0<direction) extrlist="$$BumpUp2Char,$$RandIncrChar"
	. Set:(0>direction) extrlist="$$BumpDwn2Char,$$RandDecrChar"
	Set extrcnt=$ZLength(extrlist,",")
	Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	Set:('indirect) vartest="%"
	Set:(indirect) vartest="@%i@"
	Set:('indirect2) vartest2="%"
	Set:(indirect2) vartest2="@%i"
	;
	; Now generate output
	;
	Write TAB,"Set (%r(0),%)=",sub,!
	Do:(subnum)
	. For i=(sub-2):1:(sub+2) Write TAB,"Set %(",i,")=1",!
	Do:('subnum)
	. For i=($Ascii(chr)-2):1:($Ascii(chr)+2) Write TAB,"Set %(""",$ZChar(i),""")=1",!
	Write "Src",testcase,TAB,"Set %r1=$Order(",vartest,"(",vartest2,"),$$WrapFunc(""",func,""",",direction,"))",!
	Write TAB,"Set %r2=$Order(%(%r(0)),",direction,")",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $QSUBSCRIPT.
; Test variation is rather limited since the input string is just that - a string. Only way to mess up input string is to modify it as there
; are no variables to change other than the input string as the string is not resolved nor are imbedded vars resolved since the input string
; must be a canonic name (no variables).
;
GenTestQSubscript
	New ref
	Set ref=$$GenRandArrayRef()
	;
	; Note %r(0) contains the entire value (includes the 2nd piece which give how many subscripts exist) while varsetup needs
	; to contain only the first piece. Note because the input string needs to be quoted to assign it to these values, we use
	; $$ReQuote() to double the quotes internal to the string.
	;
	Write TAB,"Set %r(0)=",$$ReQuote(ref),!
	Write TAB,"Set ",varsetup,"=",$$ReQuote($ZPiece(ref,%rsep,1)),!
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",vartest,",$$WrapGenRandArrayRef())",!
	Write TAB,"Set %r2=",funcnm,"($ZPiece(%r(0),%rsep,1),$ZPiece(%r(1),%rsep,2))",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $SELECT().
;
GenTestSelect
	New extrlist,extrcnt,rfunc,func,comp,opcomp,arglst
	Set extrlist="$$AddOne,$$SubOne,$$AddTwo,$$SubTwo,$$MullTen,$$DivTen"
	Set extrtest=">       ,<       ,>       ,<       ,>        ,<       "	; Which direction expr test goes for each func in 1st expr
	Set extrcnt=$ZLength(extrlist,",")
	Set rfunc=$Random(extrcnt)+1
	Set func=$ZPiece(extrlist,",",rfunc)
	Set comp=$ZTranslate($ZPiece(extrtest,",",rfunc)," ","")
	Set opcomp(">")="<",opcomp("<")=">"
	Set arglst="("_vartest_comp_func_"):0,("_vartest_opcomp(comp)_func_"):1,1:-1"
	;
	; Generate output
	;
	Write TAB,"Set (%r(0),",varsetup,")=",$Random(999999999),!
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",arglst,")",!
	Write TAB,"Set %r2=1",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $STACK().
; Note: At the time this test was written, $STACK() does a COERCE() on the input argument which automatically rebuffers it
;       so this function does not currently fail. But we test it anyway.
;
GenTestStack
	New extrlist,extrcnt,func,maxlvl,i
	Set extrlist="$$AddOne,$$SubOne,$$AddNone"
	Set extrcnt=$ZLength(extrlist,",")
	Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	Set maxlvl=$Random(3)+3						; Range is lvls 3-5
	;
	; Generate output
	;
	Write TAB,"Set (%r(0),",varsetup,",stkmax)=",maxlvl,!
	Write TAB,"Xecute ""Set %r1=$$Stack""_($Stack+2)_""(",maxlvl,",",testcase,")""",!
	Write TAB,"Set %r2=""Stack"_(maxlvl)_"+2^""_$Text(+0)",!
	Do GenCompErr
	Write TAB,"Goto EndStackTest"_testcase,!			; Branch around generated routines
	Write TAB,";",!
	Write TAB,"; Stack test (callback from $$StackN()) where N is maxlvl",!
	Write TAB,";",!
	Write "StackTest",testcase,"(maxlvl,testcase)",!
	Write TAB,"Do:(debug)",!
	Write TAB,". ZShow ""S""",!
	Write TAB,". For i=$Stack(-1):-1:0 Write ""Stklvl "",i,"": "",$Stack(i,""PLACE""),!",!
	Write "Src",testcase,TAB,"Quit $Stack(",vartest,",$$WrapFunc(""",func,""",""PLACE""))",!
	Write "EndStackTest",testcase,!
	Write TAB,"Kill stkmax",!
	Quit

;
; Routine to generate tests for $[Z]TRANSLATE.
; Note: Tests both numeric and string input values
; Note: Only one modification function for this test which changes a random character in the source string of the proper type (char or string)
;
GenTestTranslate
GenTestZTranslate
	New func,arglst1,arglst2,numarg,genlen,i,trin,trout
	Set func="$$ModCharInString"
	;
	; Generate initial values and argument list
	;
	Set arglst1=vartest
	Set arglst2="%r(0)"
	Set numarg=$Random(2)						; 1 = numeric, 0 = string
	If (numarg) Do
	. Set GenStr=$Random(999999999)_"."_$Random(999999999)
	. Set genlen=$ZLength(GenStr)
	. Write TAB,"Set (%r(0),",varsetup,")=",GenStr,!
	. For i=1:1:10 Set trin=$ZExtract(GenStr,$Random(genlen)+1) Quit:(("."'=trin)&("-"'=trin))
	. Do:(i=10) GTMError($Text(+0)_": GenTest[Z]Translate: Could not find modable numeric char (1)")
	. Set arglst1=arglst1_",$$WrapFunc("""_func_""","""_trin_""")"
	. Set arglst2=arglst2_","""_trin_""""
	. Do:(3=argcnt)							; Need another argument
	. . For i=1:1:10 Set trout=$Random(10) Quit:(trout'=trin)
	. . Do:(i=10) GTMError($Text(+0)_": GenTest[Z]Translate: Could not find modable numeric char (2)")
	. . Set arglst1=arglst1_",$$WrapFunc("""_func_""","""_trout_""")"
	. . Set arglst2=arglst2_","""_trout_""""
	Else  Do
	. Set genlen=$$GenRandStr(50,20,,1)				; Should be in output section but sets genlen needed in arg setup
	. Set trin=$ZExtract(GenStr,$Random(genlen)+1)
	. Set arglst1=arglst1_",$$WrapFunc("""_func_""","""_trin_""")"
	. Set arglst2=arglst2_","""_trin_""""
	. Do:(3=argcnt)							; Need another argument
	. . For i=1:1:10 Set trout=$ZExtract(alpha,$Random(alphalen)+1) Quit:(trout'=trin)
	. . Do:(i=10) GTMError($Text(+0)_": GenTest[Z]Translate: Could not find modable numeric char (3)")
	. . Set arglst1=arglst1_",$$WrapFunc("""_func_""","""_trout_""")"
	. . Set arglst2=arglst2_","""_trout_""""
	;
	; Now generate output
	;
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",arglst1,")",!
	Write TAB,"Set %r2=",funcnm,"(",arglst2,")",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $VIEW().
;
GenTestView
	New oplst1,oplst2,primryop,newop
	Set oplst1="LV_REF,LV_CREF"					; $View operands that take an argument
	Set oplst2="BREAKMSG,ZDATE_FORM,SPSIZ,STKSIZ"			; View operands that don't take an argument
	Set primryop=$ZPiece(oplst1,",",$Random($ZLength(oplst1,","))+1)
	Set newop=$ZPiece(oplst2,",",$Random($ZLength(oplst2,","))+1)
	Write TAB,"Set (%r(0),",varsetup,")=""",primryop,"""",!
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",vartest,",$$ChangeTarg(""",newop,""",""%""))",!
	Write TAB,"Set %r2=",funcnm,"(%r(0),""%"")",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $ZBITAND(), $ZBITOR(), and $ZBITXOR()
;
GenTestZBitAnd
GenTestZBitOr
GenTestZBitXOr
	New extrlist,extrcnt,func,arg1,arg2
	Set extrlist="$$BitFlip,$$BitZero,$$BitOne,$$BitRand,$$BitReverse"
	Set extrcnt=$ZLength(extrlist,",")
	Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	Set arg1=$$GenRandBit(5,2)
	Set arg2=$$GenRandBit(5,2)
	Write TAB,"Set (%r(0),",varsetup,")=",$ZWrite(arg1),!
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",vartest,",$$WrapFunc(""",func,""",",$ZWrite(arg2),"))",!
	Write TAB,"Set %r2=",funcnm,"(%r(0),",$ZWrite(arg2),")",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $ZBITFIND()
; Note: For 2 argument find, we can use $$BitZero or $$BitOne to modify the bit we are actually looking for. In the 3 argument
;       version however, we are unlikely to be changing a bit that matters so stick to $$BitFlip (which will change the bit we want) or
;       $$BitRand which rewrites all the bits with a good chance of changing a bit we care about.
; Note: The 3rd arg in the 3 arg version is a simple arg as another extrinsic could easily undo what the 2nd arg did resulting in false
;       non-failures.
;
GenTestZBitFind
	New extrlist,extrcnt,func,initbitstr,fndbitval,arglst1,arglst2,bitidxarg
	Set fndbitval=$Random(2)					; Bit value to locate
	Set extrlist="$$BitFlip,$$BitRand,$$BitReverse"
	Do:(2=argcnt)							; Only two arg form - can use either $$BitOne or $$BitZero depending
	. Set:(0=fndbitval) extrlist=extrlist_",$$BitOne"		; Looking for first 0 bit, $$BitOne changes it to 1
	. Set:(1=fndbitval) extrlist=extrlist_",$$BitZero"		; Looking for first 1 bit, $$BitZero changes it to 0
	Set extrcnt=$ZLength(extrlist,",")
	Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	Set initbitstr=$$GenRandBit(15,10)
	Set arglst1=vartest_",$$WrapFunc("""_func_""","_fndbitval
	Set arglst2="%r(0),$ZPiece(%r(1),%rsep,2)"
	Set bitidxarg=$Random($ZBitLen(initbitstr)-10)+5		; Pick value between start+5 and end-5 for 3rd arg to $ZBitFind()
	;
	; If func is $$BitFlip() add another arg to the $$WrapFunc call but arg differs according to how many args $ZBitFind() is being called with:
	; - 2 arg versions flips first occurence of bit we are looking for.
	; - 3 arg version flips bit at search bit index.
	;
	Set:("$$BitFlip"=func) arglst1=arglst1_","_$Select(2=argcnt:$ZBitFind(initbitstr,fndbitval)-1,1:bitidxarg)
	Set arglst1=arglst1_")"
	Do:(3=argcnt)							; If 3 arg version, add bit index to arg lists
	. Set arglst1=arglst1_","_bitidxarg
	. Set arglst2=arglst2_","_bitidxarg
	;
	; Now generate output
	;
	Write TAB,"Set (%r(0),",varsetup,")=",$ZWrite(initbitstr),!
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",arglst1,")",!
	Write TAB,"Set %r2=",funcnm,"(",arglst2,")",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $ZBITGET()
; Note: Varies function list depending on whether bit to fetch is already 0 or 1 (function should have decent chance of modifying string such
;       that our results differ if evaluation order is incorrect).
; Note: Since the values we fetch have a 50% chance of being right, getting failures is largely a matter of generating LOTS of tests. Typical
;       failure rate is around 23% when $gtm_side_effects is 0.
;
GenTestZBitGet
	New extrlist,extrcnt,func,initval,bitidx,curbit,arglst1
	Set extrlist="$$BitFlip,$$BitRand,$$BitReverse"
	Set extrcnt=$ZLength(extrlist,",")
	Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	Set initval=$$GenRandBit(5,2)					; Initial value
	Set bitidx=$Random(($ZLength(GenBit)-1)*8)+1			; Index of bit to fetch
	Set curbit=$ZBitGet(GenBit,bitidx)				; Used to determine which functions
	Set arglst1=vartest_",$$WrapFunc("""_func_""","_bitidx
	Set:("$$BitFlip"=func) arglst1=arglst1_","_bitidx
	Set arglst1=arglst1_")"
	;
	; Now generate output
	;
	Write TAB,"Set (%r(0),",varsetup,")=",$ZWrite(initval),!
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",arglst1,")",!
	Write TAB,"Set %r2=",funcnm,"(%r(0),",bitidx,")",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $ZBITSET()
;
GenTestZBitSet
	New extrlist,extrcnt,func,initval,bitidx,curbit
	Set extrlist="$$BitFlip,$$BitZero,$$BitOne,$$BitRand,$$BitReverse"
	Set extrcnt=$ZLength(extrlist,",")
	Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	Set initval=$$GenRandBit(5,2)					; Initial value
	Set bitidx=$Random(($ZLength(GenBit)-1)*8)+1			; Index of bit to twiddle
	Set curbit=$ZBitGet(GenBit,bitidx)				; Current bit value, set value is opposite this
	Write TAB,"Set ",varsetup,"=",$ZWrite(initval),!
	Write TAB,"Set %r(0)=",$ZWrite(initval)_"_"""_%rsep_"""_"_bitidx,!
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",varsetup,",$$WrapFunc(""",func,""",",bitidx,"),$$WrapFunc(""",func,""",",'curbit,"))",!
	Write TAB,"Set %r2=",funcnm,"($ZPiece(%r(0),%rsep,1),",bitidx,",",'curbit,")",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $ZBITSTR()
; The initialization bit is determined by whether the value is odd/even
; This function is sort of uninteresting as it only generate a string of solid 0s or 1s depending on 2nd arg. Not many variations possible.
; Note: This function generates a coerce (COMINT) on the first arg which buffers it so always passes yet we test it anyway.
;
GenTestZBitStr
	New extrlist,extrcnt,func,len
	Set extrlist="$$AddOne,$$SubOne,$$MullTen"
	Set extrcnt=$ZLength(extrlist,",")
	Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	Set len=$Random(80)+21						; Number of bits to initialize
	Write TAB,"Set (%r(0),",varsetup,")=",len,!
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",vartest,",$$WrapFunc(""",func,""",(",vartest,"#2)))",!
	Write TAB,"Set %r2=",funcnm,"(%r(0),$ZPiece(%r(1),%rsep,2))",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $ZCONVERT().
; Note: Although $ZCONVERT() allows for 3 arguments, we are only testing the 2 argument version due to concentration on M mode.
; Note: But we do generate cases for T (title) conversion when we are running in UTF8 mode.
;
GenTestZConvert
	New extrlist,extrcnt,func,len
	Set extrlist="$$RemPieceRet,$$AddPieceRet,$$ModPieceRet"
	Set extrcnt=$ZLength(extrlist,",")
	Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	Set genlen=$$GenRandStr(50,20," ")				; Generates variable setup code. Space as sep char gives Title case more to work with
	Set randpc=$Random(genlen)+1				  	; Note genlen in pieces here
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",vartest,",",func,"(5,0,",randpc,"))",!
	Write TAB,"Set %r2=",funcnm,"(%r(0),$ZPiece(%r(1),%rsep,2))",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $ZDATE().
;
GenTestZDate
	New extrlist,extrcnt,func,fncarglst,altarg,dh
	Set extrlist="$$SetAlt,$$Unset"
	Set extrcnt=$ZLength(extrlist,",")
	Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	Set fncarglst="MM/DD/YEAR 24:60:SS,YEAR/MM/DD 12:60:SSAM"
	Set fncarg=$ZPiece(fncarglst,",",$Random($ZLength(fncarglst,","))+1)
	Set dh=$Horolog
	Set:("$$SetAlt"=func) altarg=$ZPiece(dh,",",1)-1
	;
	; Generate test rtn output
	;
	Write TAB,"Set (%r(0),",varsetup,")=""",dh,"""",!
	Write:("$$SetAlt"=func) TAB,"Set altarg=""",altarg,"""",!
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",vartest,",$$WrapFunc(""",func,""",""",fncarg,"""))",!
	Write TAB,"Set %r2=$ZDate(%r(0),$ZPiece(%r(1),%rsep,2))",!
	Do GenCompErr
	Write:("$$SetAlt"=func) TAB,"Kill altarg",!
	Quit

;
; Routine to generate tests for $ZPARSE().
; Note: While all tests have 5 parms, only 2, 3, or 4 of them will have extrinsics if they have a value at all with the 5th parm always
;       being "syntax_only" so it doesn't try to actually locate the weird file names we will create.
;
GenTestZParse
	New extrlist,extrcnt,arglst1,arglst2,genlen,func,i,argvals,rn
	Set extrlist="$$ModFName,$$ModFType,$$ModFPath"
	Set extrcnt=$ZLength(extrlist,",")
	Set arglst1=vartest
	Set arglst2="%r(0)"
	Set argvals(2)=""""""						; arguments to be generated - arg 2 is always null
	For i=3,4 Do
	. Set rn=$Random(3)
	. Set argvals(i)=""""_$Select((0=rn):$$RandStr(8,2),(1=rn):"z."_$$RandStr(8,2),1:"/"_$$RandStr(8,2)_"/")_""""
	For i=2:1:argcnt Do
	. Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	. Set arglst1=arglst1_",$$WrapFunc("""_func_""","_argvals(i)_")"
	. Set arglst2=arglst2_",$ZPiece(%r("_(i-1)_"),%rsep,2)"
	For i=1:1:5-argcnt Do
	. Set arglst1=arglst1_","
	. Set arglst2=arglst2_","
	Set arglst1=arglst1_"""SYNTAX_ONLY"""
	Set arglst2=arglst2_"""SYNTAX_ONLY"""
	;
	; Generate test rtn output
	;
	Set genlen=$$GenRandStr(8,2,,1)					; Generate initial file name thing
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",arglst1,")",!
	Write TAB,"Set %r2=",funcnm,"(",arglst2,")",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $ZSUBSTR().
; Note: Uses the same routines as $[Z]Piece so build strings it operates on the same way.
;
GenTestZSubstr
	New extrlist,extrcnt,i,arglst1,arglst2,func,randpc,len,genlen
	Set extrlist="$$RemPieceRet,$$AddPieceRet,$$ModPieceRet"
	Set extrcnt=$ZLength(extrlist,",")
	;
	; Generate argument list
	;
	Set genlen=$$GenRandStr(50,20,"|")				; Should be in output section but sets genlen needed in arg setup
	Set randpc=$Random(genlen)+1				  	; Note genlen in pieces here
	Set arglst1=vartest
	Set arglst2="%r(0)"
	Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	Set arglst1=arglst1_","_func_"(2,0,"_randpc_")"
	Set arglst2=arglst2_",$ZPiece(%r(1),%rsep,2)"
	Do:(3=argcnt)							; Add optional 3rd parm (length)
	. Set randpc=$Random(5)+1
	. Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	. Set arglst1=arglst1_","_func_"(2,1,"_randpc_")"
	. Set arglst2=arglst2_",$ZPiece(%r(2),%rsep,2)"
	;
	; Now generate test rtn output
	;
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",arglst1,")",!
	Write TAB,"Set %r2=",funcnm,"(",arglst2,")",!
	Do GenCompErr
	Quit

;
; Routine to generate tests for $ZSEARCH().
; Note: Since argument is limited to existing files, not a lot of interesting variations for this test.
; Note: Since we are re-using the same streams each time, need to re-prime the streams we use for each test so what we expect to be found is found.
;
GenTestZSearch
	New extrlist,extrcnt,func
	Set extrlist="$$SetAlt,$$Unset"
	Set extrcnt=$ZLength(extrlist,",")
	Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	;
	; Generate test rtn output
	;
	Write TAB,"Set (%r(0),",varsetup,")=$Text(+0)_"".m""",!
	Write:("$$SetAlt"=func) TAB,"Set altarg=$Text(+0)_"".o""",!
	Write TAB,"Set x=$ZSearch(""x.tst"",0),x=$ZSearch(""x.txt"",1)",!	; Reset streams 0,1 so they work correctly
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",vartest,",$$WrapFunc(""",func,""",0))",!
	Write TAB,"Set %r2=",funcnm,"(%r(0),1)",!
	Do GenCompErr
	Write:("$$SetAlt"=func) TAB,"Kill altarg",!
	Quit

;
; Routine to generate tests for $ZTRIGGER().
; Note: Test is a bit different from others because:
;    1. We need to have a database available.
;    2. The output from most flavors of the function generate no output.
;    3. No simple value can be compared.
; Note: To combat the above, output files are created for the test and control passes then compared.
; Note: Since this test is not available on VMS, we just use the diff routine to check the test case specific output files.
;
GenTestZTrigger
	New extrlist,extrcnt,func,funcarglst,funcarg,funcargidx,retval,altargidx,altarg
	Set extrlist="$$SetAlt,$$Unset"
	Set extrcnt=$ZLength(extrlist,",")
	Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	Set funcarglist="FILE,ITEM"						; Only these two generate stuff we can check
	Set funcargidx=$Random($ZLength(funcarglist,","))+1
	Set funcarg=$ZPiece(funcarglist,",",funcargidx)
	Set $ZPiece(funcarglist,",",funcargidx)=""				; Remove primary arg from list
	Do:("$$SetAlt"=func)
	. Set funcarglist=funcarglist_",SELECT"					; For an alternate case, SELECT is available
	. For i=1:1:maxattempts Set altargidx=$Random($ZLength(funcarglist,","))+1 Quit:(funcargidx'=altargidx)
	. Do:(maxattempts=i) GTMError($Text(+0)_": GenTestZTrigger: Could not find alternate function arg")
	. Set altarg=$ZPiece(funcarglist,",",altargidx)
	Set:("ITEM"=funcarg) retval="+^a(subs=:) -commands=SET -xecute=""Write """"^a("""",subs,"""") trigger driven"""",!"""
	Set:("FILE"=funcarg) retval="funcevalord.trg"
	Set:("SELECT"=funcarg) retval=""
	;
	; Generate test rtn output
	;
	Write TAB,"Do ZTriggerSetup(""r1"")",!
	Write TAB,"Set (%r(0),",varsetup,")=""",funcarg,"""",!
	Write:("$$SetAlt"=func) TAB,"Set altarg=""",altarg,"""",!
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",vartest,",$$WrapFunc(""",func,""",",$$ReQuote(retval),"))",!
	Write TAB,"Do ZTriggerCloseout(""r1"")",!
	Write TAB,"Do ZTriggerSetup(""r2"")",!
	Write TAB,"Set %r2=",funcnm,"(%r(0),$ZPiece(%r(1),%rsep,2))",!
	Write TAB,"Do ZTriggerCloseout(""r2"")",!
	Write TAB,"ZSystem ""diff -bcw ztrigout-",testcase,"-r1.txt ztrigout-",testcase,"-r2.txt >& ztrigdiff-",testcase,".txt""",!
	Write TAB,"Do:($ZSystem) NotEqualZTrigger",!
	Write TAB,"Write:($ZSystem) ""$ZSystem: "",$ZSystem,!",!
	Write TAB,"ZSystem:('$ZSystem) ""rm -f ztrig*-",testcase,"*.txt >& /dev/null""",!
	Write:("$$SetAlt"=func) TAB,"Kill altarg",!
	Quit

;
; Routine to generate tests for $ZTRNLNM().
;
GenTestZTrnlnm
	New extrlist,extrcnt,func,envarglist,envarglistcnt,envarg,envidx,altarg,i,altidx
	Set extrlist="$$SetAlt,$$Unset"
	Set extrcnt=$ZLength(extrlist,",")
	Set func=$ZPiece(extrlist,",",$Random(extrcnt)+1)
	Set envarglist="gtm_dist,gtm_ver,gtm_com,gt_cc_compiler,gt_ld_options_common"
	Set envarglstcnt=$ZLength(envarglist,",")
	Set envidx=$Random(envarglstcnt)+1
	Set envarg=$ZPiece(envarglist,",",envidx)
	Set $ZPiece(envarglist,",",envidx)=""							; Remove chosen option from list (now null)
	Do:("$$SetAlt"=func)
	. For i=1:1:maxattempts Set altidx=$Random(envarglstcnt)+1 Quit:(altidx'=envidx)	; Choose 2nd envarg that isn't the first one
	. Do:(maxattempts=i) GTMError($Text(+0)_": GenTestZTrnlnm: Could not locate an alternate 2ndary envarg")
	. Set altarg=$ZPiece(envarglist,",",altidx)
	;
	; Generate test rtn output
	;
	Write TAB,"Set (%r(0),",varsetup,")=""",envarg,"""",!
	Write:("$$SetAlt"=func) TAB,"Set altarg=""",altarg,"""",!
	Write "Src",testcase,TAB,"Set %r1=",funcnm,"(",vartest,",,,,,$$WrapFunc(""",func,""",""VALUE""))",!
	Write TAB,"Set %r2=",funcnm,"(%r(0))",!
	Do GenCompErr
	Write:("$$SetAlt"=func) TAB,"Kill altarg",!
	Quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Set of support routines for test generation
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Routine to generate a random string and store it in the target var defined by "varsetup". Also saved in %r(0).
; Note: Sets "len" var for later use so is not NEWed. Note len is not correct if imbedsep is specified (imbedded chars aren't counted).
; Note: minlen is optionally specified.
; Note: imbedsep is optionally specified and is an uncounted character to imbed randomly 1/10 characters.
; Note: The generated string is left in GenStr for use by caller if necessary.
; Note: Since %rsep is used in %r() to separate values, make sure no naturally occuring version by changing them to something else.
; Returns the actual length including any potential imbedded separator chars.
;
GenRandStr(maxlen,minlen,imbedsep,alphaonly)
	New i,imbed,selectstr,selectstrlen
	Set imbed=(""'=$Get(imbedsep,""))
	Set alphaonly=$Get(alphaonly,0)
	Set minlen=$Get(minlen,1)								; Defaults to 1 if not specified
	Set len=$Random(maxlen-(minlen-1))+minlen
	Set GenStr=""
	If ('alphaonly) Set *selectstr=alphanumerics,*selectstrlen=alphanumlen
	Else  Set *selectstr=alpha,*selectstrlen=alphalen
	For i=1:1:len Set GenStr=GenStr_$ZExtract(selectstr,($Random(selectstrlen)+1))_$Select('imbed:"",(0=$Random(10)):imbedsep,1:"")
	For  Set i=$ZFind(GenStr,%rsep) Quit:(0=i)  Set $ZExtract(GenStr,i-2,i)="~!"		; Change all values of %rsep to other chars
	;
	; Convert semi-random char to separator to make pcs>1
	;
	Set:(imbed&(1=$ZLength(GenStr,imbedsep))) $ZExtract(GenStr,$Random($ZLength(GenStr)-5)+4)=imbedsep
	Write TAB,"Set (%r(0),",varsetup,")=""",GenStr,"""",!
	Write:(imbed) TAB,"Set %psep=""",imbedsep,"""",!
	Set:(imbed) pcsep=1									; Indicate a piece separator has been used
	Quit $Select((0=$Data(imbedsep)):$ZLength(GenStr),1:$ZLength(GenStr,imbedsep))

;
; Routine to generate a random bit string of given length.
; Note: length parm is in bytes, not bits
; Note: Variable GenBit is available in caller if needed
;
GenRandBit(maxlen,minlen)
	New c,len
	Set len=$Random(maxlen-minlen)+minlen+1
	Set GenBit=$ZChar(0)
	; Use bytes 0-255 except the %rsep characters and their reverses
	View:$ZVersion'["VMS" "NOBADCHAR"
	For  Set c=$ZChar($Random(256)) If %rsepchar'[c Set GenBit=GenBit_c If '$Increment(len,-1) Quit
	View:$ZVersion'["VMS" "BADCHAR"
	Do:$ZFind(GenBit,%rsep) @($ZPiece($ETrap,"($")_"(""GenRandBit generated %rsep"")")
	Quit GenBit

;
; Routine to write out comparison check and write error message if it fails
;
GenCompErr
	Write TAB,"Do:(%r1'=%r2) NotEqual",!
	Quit

;
; Routine to put quotes around a string if not already there and if that is done, to scan for quotes
; in the string and if any are found, to double them up so they would resolve correctly.
;
ReQuote(str)
	New c,i,newstr
	Set newstr=""""
	For i=1:1:$ZLength(str) Do
	. Set c=$ZExtract(str,i)
	. Set:(""""=c) newstr=newstr_c
	. Set newstr=newstr_c
	Set newstr=newstr_""""
	Quit newstr

;
; Routine to shuffle a list
;
Shuffle(list)
	New len,i,j,newpc,newlist
	Set len=$ZLength(list,",")
	Set newlist=""
	For i=1:1:len Do
	. For j=1:1:maxattempts Set newpc=$Random(len)+1 Quit:(""=$ZPiece(newlist,",",newpc))
	. Do:(maxattempts=j) GTMError($Text(+0)_": Shuffle - could not find blank element to replace in "_j_" tries")
	. Set $ZPiece(newlist,",",newpc)=$ZPiece(list,",",i)
	Quit newlist

;
; Routine to write text on $P while doing IO to/from another device (i.e. save/restore io device setting pointer)
; (lifted from gtmpcat and slightly modified).
;
DoWrite(msg)
	New saveio
	Set saveio=$IO
	Use $P
	Write msg,!
	Use saveio
	Quit

;
; Do necessary for outputting debug messages
;
dbgzwrite(zwrarg,sfx)
	New saveio
	Do DoWrite("DbgZwrite ----------- "_$Select(""'=$Get(sfx,""):"("_sfx_")",1:"")_":")
	Set saveio=$IO
	Use $P
	ZWrite @zwrarg
	Use saveio
	Quit

;
; Output timestamped error message - generate dump.
;
GTMError(text)
	New dumpfile,saveIO,$ETrap
	Set $ETrap=""
	Close:(outfileopen) outfile	; Would delete it but might be useful to see last thing generated
	Do DoWrite($ZDate($Horolog,"24:60:SS")_" "_text)
	Set saveIO=$IO
	Set dumpfile="FuncEvalOrder-fail_zshowdmp_"_$ZDate($Horolog,"YEARMMDD-2460SS")_".txt"
	Open dumpfile:Newversion
	Use dumpfile
	ZShow "*"
	Close dumpfile
	Use saveIO
	Close:(outfileopen) outfile
	Write !,$ZDate($Horolog,"24:60:SS")_"FUNCEVALORD-F-TEST ZShow dump file generated: ",dumpfile,!
	Break:(debug)
	ZHalt 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This marks the end of this routine. The remaining code below code is mostly(*) unused by this routine but is used by
; the generated routine and is copied to it. It is defined in two parts - prologue code and epilogue code defined by
; the appropriate labels.
;
; (*) - The $$RandStr routine is used in GenTestZParse.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Prologue code to be written out at beginning of generated routine
;
PrologueStart
;
; Start of generated routine to test order of evaluations with M functions. This prologue contains various
; initializations and setups for the generated test cases.
;
	Set origlvl=$ZLevel
	Set $ETrap="Do RunTimeErr^"_$Text(+0)_"($ZStatus)"
	Set alphalowc="abcdefghijklmnopqrstuvwxyz"
	Set alphauppc="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	Set alpha=alphalowc_alphauppc
	Set alphalen=$ZLength(alpha)
	Set numerics=1234567890
	Set alphanumerics=alpha_numerics
	Set alphanumlen=$ZLength(alphanumerics)
	Set %i="%"			; Indirect reference
	Set errcnt=0
	Set lasttcfail=0
	Set ztrigoutopen=0
PrologueEnd

;
; Epilogue code to be written out at end of generated routine.
;
EpilogueStart
;
; End of generated routine and start of fixed routine additions. Contains support subroutines for
; the generated test cases.
;
; Routine driven when test case fails equality test
;
NotEqual
	Write:('debug) !
	Write "Test #",$Justify(tc,6),?13," failed - expected value (%r2): ",$ZWrite(%r2)
	Write "  computed (%r1): ",$ZWrite(%r1),!
	Write ?14,"Srcline: ",$ZPiece($Text(@("Src"_tc_"^"_$Text(+0)))," ",2,9999),!
	Set:(tc'=lasttcfail) errcnt=errcnt+1
	Set lasttcfail=tc
	ZWrite:('debug) %r
	ZWrite:('debug&(0'=$Data(%))) %
	Quit

;
; Routine called when $ZTrigger tests do not have equal results
;
NotEqualZTrigger
	Write:('debug) !
	Write "Test #",$Justify(tc,6),?13," failed - expected output from $ZTrigger() was not received - see ztrigdiff-",tc,"-r1.diff for explanation of differences",!
	Write ?14,"Srcline: ",$ZPiece($Text(@("Src"_tc_"^"_$Text(+0)))," ",2,9999),!
	Set:(tc'=lasttcfail) errcnt=errcnt+1
	Set lasttcfail=tc
	ZWrite:('debug) %r
	ZWrite:('debug&(0'=$Data(%))) %
	Quit

;
; Routine to deal with errors and restart processing at next test.
;
RunTimeErr(text)
	Use $P
	Close:(ztrigoutopen) ztrigout
	If $ZLength($Get(text)) Write !,text
	Do:($ZStatus["YDB-E-RANDARGNEG")
	. Write !,"Fatal error occurred (test bug): ",$ZStatus,!
	. ZSHow "*"
	. ZHalt 1
	New savetrap
	Set savetrap=$ETrap
	Set $ETrap=""			; Prevent nested errors
	Write:('debug) !
	Write "Testcase ",tc," failed: ",$ZStatus,!
	Set errcnt=$Get(errcnt,0)+1
	Set $ECode=""
	ZWrite:(0'=$Data(%r)) %r
	ZWrite:(0'=$Data(%)) %
	Set $ETrap=savetrap		; If this is done with NEW, as soon as this frame unwinds due to error, the old etrap kicks in which STILL
	    				; results in an error loop so don't restore UNLESS the above had no errors.
	ZShow "S"
	ZGoto @("origlvl:Test"_(tc+1)_"^"_$Text(+0))

;
; Function to wrap call to basically add some desirable operations to a requested function and return something different
;
WrapFunc(wrapfunc,retval,args)
	New x
	Set:("$Increment"=wrapfunc) %rx=$Get(%rx,0)+1,%r(%rx)=""	; Nothing set up if using $Increment()
	Xecute "Set x="_wrapfunc_"("_$Select("$Increment"=wrapfunc:$Select(10=$Data(%):"%(1)",1:"%"),1:$Select((0<$Data(args)):args,1:""))_")"
	Set %r(%rx)=%r(%rx)_%rsep_retval				; Add true return value so can pick it up later
	Quit retval

;
; Routine to modify the target variable with the reverse of the current value in a test but returns whatever its parameter is.
;
ReverseRet(ret)
	Set %r($Increment(%rx))=$Reverse(%r(%rx-1))
	If (10=$Data(%)) Set %(1)=$Reverse(%(1))
	Else  Set %=$Reverse(%)
	Quit ret

;
; Routine to modify the target variable with a random replacement string of the same length but returns whatever it parameter is.
;
RandStrRet(ret)
	New len,i,var,newval
	Set var=$Select(10=$Data(%):"%(1)",1:"%")
	Set len=$ZLength(@var)
	Set newval=""
	For i=1:1:len  Set newval=newval_$ZExtract(alphanumerics,$Random(alphanumlen)+1)
	Set (%r($Increment(%rx)),@var)=$ZSubstr(newval,1,len)
	Quit ret

;
; Routine to leave arg unchanged
;
AddNone()
	Set %r($Increment(%rx))=%r(%rx-1)
	If (10=$Data(%)) Quit %(1)
	Else  Quit %

;
; Routine to bump "%" or "%(1)" (depending on which is active) by 1.
;
AddOne()
	New ret
	Set %r($Increment(%rx))=%r(%rx-1)+1
	If (10=$Data(%)) Set (ret,%(1))=%(1)+1
	Else  Set (ret,%)=%+1
	Quit ret

;
; Routine to bump "%" or "%(1)" (depending on which is active) by -1.
;
SubOne()
	New ret
	Set %r($Increment(%rx))=%r(%rx-1)-1
	If (10=$Data(%)) Set (ret,%(1))=%(1)-1
	Else  Set (ret,%)=%-1
	Quit ret

;
; Routine to bump "%" or "%(1)" (depending on which is active) by 2.
;
AddTwo()
	New ret
	Set %r($Increment(%rx))=%r(%rx-1)+2
	If (10=$Data(%)) Set (ret,%(1))=%(1)+2
	Else  Set (ret,%)=%+2
	Quit ret

;
; Routine to bump "%" or "%(1)" (depending on which is active) by -2.
;
SubTwo()
	New ret
	Set %r($Increment(%rx))=%r(%rx-1)-2
	If (10=$Data(%)) Set (ret,%(1))=%(1)-2
	Else  Set (ret,%)=%-2
	Quit ret

;
; Routine to multiply "%" or "%(1)" (depending on which is active) by 10.
;
MullTen()
	New ret
	Set %r($Increment(%rx))=%r(%rx-1)*10
	If (10=$Data(%)) Set (ret,%(1))=%(1)*10
	Else  Set (ret,%)=%*10
	Quit ret

;
; Routine to divide "%" or "%(1)" (depending on which is active) by 10.
;
DivTen()
	New ret
	Set %r($Increment(%rx))=%r(%rx-1)/10
	If (10=$Data(%)) Set (ret,%(1))=%(1)/10
	Else  Set (ret,%)=%/10
	Quit ret

;
; Routine to take an input char and bump it by 1 to the next char. Function always used wrapped by $$WrapFunc().
; Note since is used by $Order test, only EVER deal with the % var thus changing the index.
;
BumpUp2Char()
	New newidx
	Set %r($Increment(%rx))=$ZChar($Ascii(%r(0))+2)
	Set newidx=$ZChar($Ascii(%)+2)
	Set %=newidx
	Quit newidx

;
; Routine to reverse $$BumpUpChar().
;
BumpDwn2Char()
	New newidx
	Set %r($Increment(%rx))=$ZChar($Ascii(%r(0))-2)
	Set newidx=$ZChar($Ascii(%)-2)
	Set %=newidx
	Quit newidx

;
; Routine similar to $$BumpUpChar() except instead of bumping by 2, bumps by a random value (keeping new char under 255).
;
RandIncrChar()
	New newchr,rndinc
	Set rndinc=$Random(127)+1					; Max increase to keep below 256.
	Set %r($Increment(%rx))=$ZChar($Ascii(%r(0))+rndinc)
	Set newchr=$ZChar($Ascii(%)+rndinc)
	Set %=newchr
	Quit newchr

;
; Routine similar to $$RandIncrChar() but goes down instead of up. To that end, need to take care new char num doesn't go negative.
; Note: if %r(0) and % are the same,
;
RandDecrChar()
	New newchr,rndinc,lowidx,indx1,indx2
	Set indx1=$Find(alphanumerics,%r(0))-1				; Index where input char is in alphanumerics
	Set indx2=$Find(alphanumerics,%)-1				; Index where original input char is in alphanumerics
	Set lowidx=$Select(indx1<indx2:indx1,1:indx2)			; Find lowest index (so don't go beyond 0)
	Set rndinc=$Random(lowidx-1)+1					; Chose random decrement that doesn't go below 0
	Set %r($Increment(%rx))=$ZExtract(alphanumerics,indx1-rndinc)	; Apply decrement to original input char
	Set newchr=$ZExtract(alphanumerics,indx2-rndinc)		; Apply decrement to current input char
	Set %=newchr
	Quit newchr

;
; The following 3 runtime routines all take the same arguments described below. They modify the input target string,
; and compute/save what they SHOULD have turned it into along with the value that was actually returned. Both of these
; are saved in %r0(%rx) separated by %rsep so they can be reliably split apart to compute the control value.
;
; Arguments:
;   type=0: $[Z]Extract(),  type=1: $[Z]Piece(),  type=2: $Substr(),  type=3: $[Z]Find(),  type=4: $[Z]Length()
;   where=0: 1st extrinsic,  where=1: 2nd extrinsic
;   piecenum - piece delimited by %psep to be removed.
; Return given [type,where]:
;   [0,0] - $[Z]Extract() - Byte where to start extraction
;   [0,1] - $[Z]Extract() - Byte to end extraction (generally only 5-10 bytes from start)
;   [1,0] - $[Z]Piece()   - Piece to start extraction
;   [1,1] - $[Z]Piece()   - Piece to end extraction (generally only 0 or 1 pieces from start)
;   [2,0] - $ZSubstr()    - Byte to start extraction
;   [2,1] - $ZSubstr()    - $[ZLength of extractions (generally only 5-10 bytes from start)
;   [3,0] - $[Z]Find()    - Char to look for in target string
;   [3,1] - $[Z}Find()    - Position where search starts
;   [4,0] - $[Z]Length()  - Separator character
;   [5,0] - $ZConvert()	  - Conversion command character
;

;
; Routine to modify a piece of the action var (using separator char %psep).
;
RemPieceRet(typepc,where,piecenum)
	New i,val,len,ret,var
	Set subs=(10=$Data(%))						; var is subscripted
	Set var=$Select(subs:"%(1)",1:"%")
	Set ret=$$DeviseReturnVal(typepc,where)
	;
	; Modify the input string (to the calling function)
	;
	If (subs) Do
	. Set $ZPiece(%(1),%psep,piecenum)=""
	. For  Set i=$ZFind(%(1),%psep_%psep) Quit:(0=i)  Set %(1)=$ZExtract(%(1),1,i-3)_$ZSubstr(%(1),i)
	. Set:(1=piecenum) %(1)=$ZSubstr(%(1),2)			; If piece #1 is removed, just remove the leftover separator
	. Set:(1<piecenum) %(1)=$$RemoveDupSeps(%(1))
	Else  Do
	. Set $ZPiece(%,%psep,piecenum)=""
	. Set:(1=piecenum) %=$ZSubstr(%,2)
	. Set:(1<piecenum) %=$$RemoveDupSeps(%)
	;
	; Do same as above except use string we know we should get
	;
	Set val=$ZPiece(%r($Get(%rx,0)),%rsep,1)
	Set $ZPiece(val,%psep,piecenum)=""
	Set:(1=piecenum) val=$ZSubStr(val,2)
	Set:(1<piecenum) val=$$RemoveDupSeps(val)
	Set %r($Increment(%rx))=val_%rsep_ret
	Quit ret

;
; Utility routine for above $$RemPieceRet() routine to return a version of input with adjacent separators removed.
;
RemoveDupSeps(str)
	New i,newstr
	Set newstr=str
	For  Set i=$ZFind(newstr,%psep_%psep) Quit:(0=i)  Set newstr=$ZExtract(newstr,1,i-3)_$ZSubstr(newstr,i)
	Quit newstr

;
; Routine to add a piece to the action var (using separator char %psep)
;
AddPieceRet(typepc,where,piecenum)
	New val,ret,var,subs
	Set subs=(10=$Data(%))			; var is subscripted
	Set var=$Select(subs:"%(1)",1:"%")
	Set ret=$$DeviseReturnVal(typepc,where)
	If (subs) Set $ZPiece(%(1),%psep,piecenum)="NewPieceAdded"_%psep
	Else  Set $ZPiece(%,%psep,piecenum)="NewPieceAdded"_%psep
	Set val=$ZPiece(%r($Get(%rx,0)),%rsep,1)
	Set $ZPiece(val,%psep,piecenum)="NewPieceAdded"_%psep
	Set %r($Increment(%rx))=val_%rsep_ret
	Quit ret

;
; Routine to modify an existing piece of the action var (using separate char %psep). Note the piece that gets modded
; also adds a separator effectively adding a piece in a different fashion than $$AddPieceRet
;
ModPieceRet(typepc,where,piecenum)
	New val,ret,var,subs
	Set subs=(10=$Data(%))			; var is subscripted
	Set var=$Select(subs:"%(1)",1:"%")
	Set ret=$$DeviseReturnVal(typepc,where)
	If (subs) Set $ZPiece(%(1),%psep,piecenum)="Piece"_%psep_"Modded"
	Else  Set $ZPiece(%,%psep,piecenum)="Piece"_%psep_"Modded"
	Set val=$ZPiece(%r($Get(%rx,0)),%rsep,1)
	Set $ZPiece(val,%psep,piecenum)="NewPieceAdded"_%psep
	Set %r($Increment(%rx))=val_%rsep_ret
	Quit ret

;
; Utility routine for $$xxxPieceRet() routines to decide what to return
;
DeviseReturnVal(typepc,where)
	New r0
	Set r0=$ZPiece(%r(0),%rsep,1)					; Always operate on original string
	Do:(0=typepc)							; $[Z]EXTRACT()
	. Set len=$ZLength(r0)
	. Set:(0=where) ret=$Random(len-10)+1				; 1st extrinsic - return a character starting point
	. Do:(1=where)							; 2nd extrinsic - return a character ending point
	. . New startchr,remlen
	. . Set startchr=$ZPiece(%r(%rx),%rsep,2)			; Start previously returned
	. . Set remlen=len-startchr
	. . Set ret=$Random(remlen)+startchr+1
	Do:(1=typepc)							; $[Z]PIECE()
	. Set len=$ZLength(r0,%psep)					; Note length is in pieces
	. Set:(0=where) ret=$Random(len-1)+1				; 1st extrinsic - return a starting piece
	. Do:(1=where)							; 2nd extrinsic - return an ending piece
	. . New startpc,rempcs
	. . Set startpc=$ZPiece(%r(%rx),%rsep,2)			; Start previously returned
	. . Set rempcs=len-startpc
	. . Set ret=$Random(rempcs)+startpc+1
	Do:(2=typepc)							; $ZSUBSTR()
	. Set len=$ZLength(r0)
	. Set:(0=where) ret=$Random(len-10)+1				; 1st extrinsic - return a character starting point
	. Do:(1=where)							; 2nd extrinsic - return a length
	. . New startchr,remlen
	. . Set startchr=$ZPiece(%r(%rx),%rsep,2)			; Start previously returned
	. . Set remlen=len-startchr
	. . Set ret=$Random(remlen)+1
	Do:(3=typepc)							; $[Z]FIND()
	. Set:(0=where) ret=%psep					; 1st extrinsic - search with our standard separator
	. Set:(1=where) len=$ZLength(r0),ret=$Random(len\2)+1		; 2nd extrinsic - where to start looking
	Do:(4=typepc)							; $[Z]LENGTH()
	. Set ret=%psep							; 1st (and only) extrinsic - return standard separator char
	Do:(5=typepc)							; $ZCONVERT()
	. New cmods
	. Set cmods="UL"_$Select(("M"=$ZChset):"",1:"T")		; Use T (title) only in UTF8 mode
	. Set ret=$ZExtract(cmods,$Random($ZLength(cmods))+1)		; 1st (and only) extrinsic - conversion command selection
	Write:(debug) "DeviseReturnVal output: ",ret," typepc=",typepc," where=",where,!
	Quit ret

;
; Routine to modify 1 character in a string or number replacing that char with a similar type (alpha or numeric).
;
ModCharInString()
	New var,str,typenum,i
	Set var=$Select((10=$Data(%)):"%(1)",1:"%")
	Set str=@var
	Set typenum=((str+0)=str)
	If (typenum) Do							; Generate a character position to mod but don't change sign or decimal point
	. New dig,digpos,newdig
	. For i=1:1:10 Set digpos=$Random($ZLength(str)+1),dig=$ZExtract(str,digpos) Quit:(("."'=dig)&("-"'=dig))
	. Do:(10=i)
	. . Write $Text(+0)," FAIL - ModCharInString could not find a suitable char to mod - internal error (1)",!
	. . ZHalt 1
	. For i=1:1:10 Set newdig=$Random(10) Quit:(newdig'=dig)	; Find a new digit not same as old (guarranteed change)
	. Do:(10=i)
	. . Write $Text(+0)," FAIL - ModCharInString could not find a suitable char to mod - internal error (2)",!
	. . ZHalt 1
	. Set $ZExtract(str,digpos)=newdig
	. Set %r($Increment(%rx))=str_%rsep_digpos_%rsep_dig
	Else  Do
	. New chr,newchr,chrpos
	. Set chrpos=$Random($ZLength(str)+1)
	. Set chr=$ZExtract(str,chrpos)
	. For i=1:1:10 Set newchr=$ZExtract(alpha,$Random(alphalen)+1) Quit:(chr'=newchr)
	. Do:(10=i)
	. . Write $Text(+0)," FAIL - ModCharInString could not find a suitable char to mod - internal error (3)",!
	. . ZHalt 1
	. Set $ZExtract(str,chrpos)=newchr
	. Set %r($Increment(%rx))=str_%rsep_chrpos_%rsep_chr
	Set @var=str
	Quit str

;
; Routine to reset the (numeric) value of the action var to an alternate value
;
SetAlt()
	Set %r($Increment(%rx))=altarg
	If (10=$Data(%)) Set %(1)=altarg
	Else  Set %=altarg
	Quit altarg

;
; Routine to unset (kill) the value of the action var
;
Unset()
	Set %r($Increment(%rx))="*killed*"
	If (10=$Data(%)) Kill %(1)
	Else  Kill %
	Quit "*undefined*"

;
; Runtime routine to wrap $$GenRandArrayRef() so that it modifies the input string
;
WrapGenRandArrayRef()
	New ref,retelem
	Set ref=$ZPiece($$GenRandArrayRef(),%rsep,1)			; Create new reference but ignore the subcnt portion
	Set retelem=$Random($ZPiece(%r(0),%rsep,2)+1)			; Return random element from original input string
	Set %r($Increment(%rx))=ref_%rsep_retelem			;
	If (10=$Data(%)) Set %(1)=ref
	Else  Set %=ref
	Quit retelem

;
; Routine to generate a random array reference. Used in generating routine to create initial input string and used in generated
; routine to modify that string.
;
GenRandArrayRef()
	New ref,i,j,numsub,subcnt
	Set ref=""
	For i=1:1:$Random(6)+1 Set ref=ref_$ZExtract(alpha,$Random(alphalen)+1) ; Build name
	Set ref=ref_"("
	Set subcnt=$Random(10)+1					; Number of subscripts
	For i=1:1:subcnt Do
	. Set numsub=$Random(2)						; Numeric (1) or string(0) subscript
	. Set:(numsub) ref=ref_($Random(501)-250)_","			; Add numeric subscript (range -250 to +250)
	. Do:('numsub) 							; Add string subscript up to 10 chars
	. . Set ref=ref_""""
	. . For j=1:1:$Random(10)+1 Set ref=ref_$ZExtract(alphanumerics,$Random(alphanumlen)+1)
	. . Set ref=ref_""","
	Set ref=$ZExtract(ref,1,$ZLength(ref)-1)_")"			; Remove trailing comma and add close paren
	For  Set i=$ZFind(ref,%rsep) Quit:(0=i)  Set $ZExtract(ref,i-2,i)="~!"	; Change all values of %rsep to other chars
	Quit ref_%rsep_numsub

;
; Routine to change the target var to a var of our choosing (2nd arg)
;
ChangeTarg(newval,ret)
	Set %r($Increment(%rx))=newval_%rsep_ret
	If (10=$Data(%)) Set %(1)=newval
	Else  Set %=newval
	Quit ret

;
; Routine to flip a bit in a target bit string. If bitidx not specified, bit selection is random.
;
BitFlip(bitidx)
	New bitpos,var,bitval,val
	Set var=$Select((10=$Data(%)):"%(1)",1:"%")
	Set val=@var
	Set bitpos=$Select((0<$Data(bitidx)):bitidx,1:$Random($ZBitLen(val))+1)
	Set bitval=$ZBitGet(val,bitpos)
	Set val=$ZBitSet(val,bitpos,'bitpos)
	Xecute:$ZFind(val,%rsep) ($ZPiece($ETrap,"($")_"(""BitFlip generated %rsep"")")
	Set (@var,%r($Increment(%rx)))=val
	Quit val

;
; Routine to set the 1st 1 bit to 0 in the target bit string. If no 1 bit exists, turns string to alternating 0s and 1s, starting with a 0.
;
BitZero()
	New bitpos,var,zbitidx,val,len
	Set var=$Select((10=$Data(%)):"%(1)",1:"%")
	Set val=@var
	Set len=$ZBitLen(val)/8
	Set zbitidx=$ZBitFind(val,1)-1
	Set:(0<zbitidx) val=$ZBitSet(val,zbitidx,0)
	Set:(0'<zbitidx) val=$ZChar(0)_$$RepeatChar($ZChar(55),len)	; 0B01010101
	Xecute:$ZFind(val,%rsep) ($ZPiece($ETrap,"($")_"(""BitZero generated %rsep"")")
	Set (@var,%r($Increment(%rx)))=val
	Quit val

;
; Routine to set the 1st 0 bit to 1 in the target bit string. If no - bit exists, turns string to alternating 1s and 0s, starting with a 1.
;
BitOne()
	New bitpos,var,zbitidx,val,len
	Set var=$Select((10=$Data(%)):"%(1)",1:"%")
	Set val=@var
	Set len=$ZBitLen(val)/8						; All strings in our tests are 8 bit multiples
	Set zbitidx=$ZBitFind(val,0)-1
	Set:(0<zbitidx) val=$ZBitSet(val,zbitidx,1)
	Set:(0'<zbitidx) val=$ZChar(0)_$$RepeatChar($ZChar(170),len)	; 0B10101010
	Xecute:$ZFind(val,%rsep) ($ZPiece($ETrap,"($")_"(""BitOne generated %rsep"")")
	Set (@var,%r($Increment(%rx)))=val
	Quit val

;
; Routine to reset the entire string to a random collection of bits of same length
;
BitRand()
	New c,var,val,len
	Set var=$Select((10=$Data(%)):"%(1)",1:"%")
	Set len=$ZBitLen(@var)/8					; All strings in our tests are 8 bit multiples
	Set val=$ZChar(0)						; Bit string prefix
	; Use bytes 0-255 except the %rsep characters and their reverses
	View:$ZVersion'["VMS" "NOBADCHAR"
	For  Set c=$ZChar($Random(256)) If %rsepchar'[c Set val=val_c If '$Increment(len,-1) Quit
	View:$ZVersion'["VMS" "BADCHAR"
	Xecute:$ZFind(val,%rsep) ($ZPiece($ETrap,"($")_"(""BitRand generated %rsep"")")
	Set (@var,%r($Increment(%rx)))=val
	Quit val

;
; Routine to reverse the bit string.
;
BitReverse()
	New newbitstr,bitlen,i,var,val
	Set var=$Select((10=$Data(%)):"%(1)",1:"%")
	Set val=@var
	Set bitlen=$ZBitLen(val)
	Set newbitstr=$ZBitStr(bitlen,0)				; Create string of same size
	For i=1:1:bitlen Set newbitstr=$ZBitSet(newbitstr,(bitlen-i+1),$ZBitGet(val,i))
	Xecute:$ZFind(val,%rsep) ($ZPiece($ETrap,"($")_"(""BitRand generated %rsep"")")
	Set (@var,%r($Increment(%rx)))=val
	Quit val

;
; Returns a series of duplicates of a given char
;
RepeatChar(chr,times)
	New chrstr
	Set chrstr=chr
	For times=times-1:-1:1 Set chrstr=chrstr_chr
	Quit chrstr

;
; $ZPARSE() testing - modify file name in target argument
;
ModFName()
	Set %r($Increment(%rx))=$$RandStr(8,2)
	If (10=$Data(%)) Set %(1)=%r(%rx)
	Else  Set %=%r(%rx)
	Quit %r(%rx)

;
; $ZPARSE() testing - modify file type in target argument
;
ModFType()
	Set %r($Increment(%rx))="x."_$$RandStr(8,2)
	If (10=$Data(%)) Set %(1)=%r(%rx)
	Else  Set %=%r(%rx)
	Quit %r(%rx)

;
; $ZPARSE() testing - modify file name in target argument
;
ModFPath()
	Set %r($Increment(%rx))="/"_$$RandStr(8,2)_"/"
	If (10=$Data(%)) Set %(1)=%r(%rx)
	Else  Set %=%r(%rx)
	Quit %r(%rx)

;
; Generate random string - alphas only
;
RandStr(maxlen,minlen)
	New newstr,i
	Set len=$Random(maxlen-(minlen-1))+1+(minlen-0)
	Set newstr=""
	For i=1:1:len Set newstr=newstr_$ZExtract(alpha,($Random(alphalen)+1))
	Quit newstr

;
; Routine to provide test setup for $ZTrigger tests. Items covered:
;   1. Open output file based on testcase # and "which" parm (r1 or r2)
;   2. Use file redirecting IO for test.
;   3. Clean out all triggers
;
ZTriggerSetup(which)
	New x
	Close:(ztrigoutopen) ztrigout
	; Remove any existing triggers and redirect output to a separate file that is not used towards
	; a diff (like ztrigout-*-r1.txt and ztrigout-*-r2.txt) as post-V61000 trigger deletion prints
	; # of triggers deleted whereas previously trigger deletion used to print same message whether it
	; is a no-op or actually deletes triggers. So we dont want this change to affect the diff
	; since the two files are otherwise identical.
	Set ztrigout="ztrigout-"_tc_"-"_which_"_tmp.txt"
	Open ztrigout:New
	Use ztrigout
	Xecute:$ZVersion'["VMS"&($ZVersion'["HP-PA") "Set x=$ZTrigger(""Item"",""-*"")"
	Close ztrigout
	Set ztrigout="ztrigout-"_tc_"-"_which_".txt"
	Open ztrigout:New
	Use ztrigout
	Set ztrigoutopen=1
	Quit

;
; Routine to finish up an open $ZTrigger() test output file. Items covered:
;   1. Run $ZTrigger("SELECT") into the output file to verify any contents (should be some).
;   2. Close the file clearing the open flag.
;   3. Reset current output to $P.
;   4. Run the file through sed so the varying cycle # can be removed from the SELECT display enabling it to be comparied via diff.
;      Note this involves rewriting the file that comes out of the pipe as one cannot put redirects in a pipe command.
;
ZTriggerCloseout(which)
	New x,p1,lines
	Xecute:$ZVersion'["VMS"&($ZVersion'["HP-PA") "Set x=$ZTrigger(""SELECT"")"
	Close ztrigout
	Set p1="p1"
	Open p1:(shell="/usr/local/bin/tcsh":command="/bin/sed 's/cycle: [0-9]*//g' "_ztrigout)::"PIPE"
	Use p1
	For  Read x($Increment(lines)) Quit:$ZEof
	Close p1
	Open ztrigout:(New)
	Use ztrigout
	For x=1:1:lines-1 Write x(x),!
	Close ztrigout
	Use $P
	Quit

;
; Set of routines to run up stack so we have something to test.
;
Stack1(lvl,tc)
	Write:(debug) "** Stack1 - level: ",$Stack,"  input lvl: ",lvl,!
	If (stkmax'<$Stack) Quit $$Stack2(lvl,tc)
	Else  Quit @("$$StackTest"_tc_"(lvl,tc)")
Stack2(lvl,tc)
	Write:(debug) "** Stack2 - level: ",$Stack,"  input lvl: ",lvl,!
	If (stkmax'<$Stack) Quit $$Stack3(lvl,tc)
	Else  Quit @("$$StackTest"_tc_"(lvl,tc)")
Stack3(lvl,tc)
	Write:(debug) "** Stack3 - level: ",$Stack,"  input lvl: ",lvl,!
	If (stkmax'<$Stack) Quit $$Stack4(lvl,tc)
	Else  Quit @("$$StackTest"_tc_"(lvl,tc)")
Stack4(lvl,tc)
	Write:(debug) "** Stack4 - level: ",$Stack,"  input lvl: ",lvl,!
	If (stkmax'<$Stack) Quit $$Stack5(lvl,tc)
	Else  Quit @("$$StackTest"_tc_"(lvl,tc)")
Stack5(lvl,tc)
	Write:(debug) "** Stack5 - level: ",$Stack,"  input lvl: ",lvl,!
	If (stkmax'<$Stack) Quit $$Stack6(lvl,tc)
	Else  Quit @("$$StackTest"_tc_"(lvl,tc)")
Stack6(lvl,tc)
	Write:(debug) "** Stack6 - level: ",$Stack,"  input lvl: ",lvl,!
	Quit @("$$StackTest"_tc_"(lvl,tc)")
EpilogueEnd
