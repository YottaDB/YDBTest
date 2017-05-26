;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2012, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; opevalord - generate opevalordtst to check non-Boolean binary order of evaluation, then run it
;
; Test to operator evaluation order when one argument is a local var and the other argument
; is an extrinsic that modifies the first argument (GTM-3907).
;

;
; Initialization
;
	Set numtests=500				; Number of random tests to generate
	Set rungenfile=1				; Invoke the generated file
	;
	Set rtnname=$Text(+0)
	Set $ETrap="Do GTMError^"_rtnname_"($ZStatus)"	; Uses stripped down error handler from gtmpcat
	Set alphalowc="abcdefghijklmnopqrstuvwxyz"
	Set alphauppc="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	Set alpha=alphalowc_alphauppc
	Set alphalen=$ZLength(alpha)
	Set outfile="opevlordtst.m"
	Set outfileopen=0
	Set TAB=$ZChar(9)
;
; Define operators to test
;
; Format of operator arrays:
;
;   mop(<index>)     : Text containing the actual operator to test
;   moptype(<index>) : Contain "num" or "str" to define the type of the two or more arguments
;
; Note some operators appear once for each type ("=" and "'=").
;
	Set mop(1)="*",moptype(1)="num"
	Set mop(2)="**",moptype(2)="num"
	Set mop(3)="/",moptype(3)="num"
	Set mop(4)="\",moptype(4)="num"
	Set mop(5)="#",moptype(5)="num"
	Set mop(6)="<",moptype(6)="num"
	Set mop(7)=">",moptype(7)="num"
	Set mop(8)="=",moptype(8)="num"
	Set mop(9)="'<",moptype(9)="num"
	Set mop(10)=">=",moptype(10)="num"
	Set mop(11)="'>",moptype(11)="num"
	Set mop(12)="<=",moptype(12)="num"
	Set mop(13)="'=",moptype(13)="num"
	Set mop(14)="[",moptype(14)="str"
	Set mop(15)="]",moptype(15)="str"
	Set mop(16)="]]",moptype(16)="str"
	Set mop(17)="=",moptype(17)="str"
	Set mop(18)="'[",moptype(18)="str"
	Set mop(19)="']",moptype(19)="str"
	Set mop(20)="']]",moptype(20)="str"
	Set mop(21)="'=",moptype(21)="str"
	Set mop(22)="_",moptype(22)="str",concatop=22	; Special as can take more than one arg
	Set mopcnt=22
;
; Set of secondary modifiers. All expressions will be of the form "<arg1><op><arg2>" except concatenate which can
; have multiple arguments. In all cases, <arg1> is a local variable or indirect pointing to a locat variable. Also,
; at least <arg2> is an extrinsic that modifies arg1 or is an $Increment() function.
;
	Set binarg(1)="$Increment",incrfun=1	; $Increment can take 2 args so note which one it is
	Set binarg(2)="$$AddOne"
	Set binarg(3)="$$DoubleNum"
	Set binarg(4)="$$SubOne"
	Set binargcnt=4
	Set strarg(1)="$$DoubleStr"
	Set strarg(2)="$$BumpChar"
	Set strarg(3)="$$CaseRev"
	Set strargcnt=3
;
; Open output routine and ready it for expression generation
;
	Open outfile:New
	Use outfile
	Set outfileopen=1
;
; Write some initial setup statement(s)
;
	Write TAB,"Set $ETrap=""ZShow """"*"""" ZHalt 1""",!
	Write TAB,"Set alphalowc=""abcdefghijklmnopqrstuvwxyz""",!
	Write TAB,"Set alphauppc=""ABCDEFGHIJKLMNOPQRSTUVWXYZ""",!
	Write TAB,"Set alpha=alphalowc_alphauppc",!
	Write TAB,"Set iarg1=""arg1""",!		; Setup indirect args
	Write TAB,"Set iarg3=""arg3""",!
	Write TAB,"Set errcnt=0",!
	Write !!
;
; Generate statements. Note that "arg2" noted below is the function called with some version of the arg1 value. The other args
; are independent values used for $Increment and/or the concatenation operator.
;
	For i=1:1:numtests Do
	. Set opidx=$Random(mopcnt)+1
	. Set op=mop(opidx)
	. Set optypnum=("num"=moptype(opidx))	; TRUE if type is "num", else FALSE
	. Set arg1=$Select(optypnum:$$RandomNumber(op),1:$$RandomString())
	. Set arg2idx=$Random($Select(optypnum:binargcnt,1:strargcnt))+1
	. Do:"|**|/|\|#"[("|"_op)			; avoid DIVZERO errors
	. . if ("$$SubOne"=binarg(arg2idx)) Set:$Select("**"=op:0=arg1,1:1=arg1) arg2idx=arg2idx-$Random(2)-1 Quit
	. . if (-1=arg1)&("$$AddOne"=binarg(arg2idx)) Set arg2idx=arg2idx+$Random(2)+1 Quit
	. Set arg2=$Select(optypnum:binarg(arg2idx),1:strarg(arg2idx))
	. Set arg2indr=$Random(2)			; Decide if arg2 is used as an indirect or not
	. Set isincr=(optypnum&(incrfun=arg2idx))	; Identify $Increment usage so don't pass by reference
	. Set isconcat=('optypnum&(concatop=opidx))	; identify concatenation operator
	. Set parenexpr=$Random(2)			; Whether to put side-effect expr in a sub-expression
	. ;
	. ; $Increment can take 2 args. Decide if we should do that if we are doing $Increment. Note the 2nd
	. ;
	. Do:(isincr)
	. . Set twoparms=$Random(2)
	. . Do:(twoparms)
	. . . Set arg3=$$RandomNumber(op)
	. . . If ("|**|/|\|#"[("|"_op))&(arg3=arg1),$Increment(arg3,$random(2)+1)	; avoid DIVZERO errors
	. . . Set:("**"=op)&(0>arg3)&'arg1 arg3=-arg3
	. . . Set arg3indr=$Random(2)
	. ;
	. ; Generate the actual statements for this subtest. Note we generate two statements in parallel. Expression 1 is the
	. ; the actual test expression while expression 2 is similar but constructed to always create each value in temporaries
	. ; so as to completely avoid any order of evaluation issues. The value of expression 2 is the value verified against.
	. ;
	. Write TAB,"; *** Test #",i," parenexpr=",parenexpr,"  isincr=",isincr,"  isconcat=",isconcat,!
	. Write TAB,"Set (arg1,arg1sav)=",arg1,!
	. Set expr1=$Select(parenexpr:$Select(optypnum:$$RandomNumber(op)_"+(",1:$$RandomString()_"_("),1:"")
	. Set expr2=expr1
	. Set expr1=expr1_"arg1"_op_arg2_"("_$Select(isincr:"",1:".")			; Pass arg1 as pass-by-reference if not $Increment
	. Set expr2=expr2_"(arg1"_$Select(optypnum:"+0)",1:"_"""")")_op_arg2_"("_$Select(isincr:"",1:".")
	. Set expr1=expr1_$Select(arg2indr:"@i",1:"")_"arg1"				; Pass indirect or not
	. Set expr2=expr2_$Select(arg2indr:"@i",1:"")_"arg1"
	. Do:(isincr&twoparms)
	. . Write TAB,"Set arg3=",arg3,!
	. . Set expr1=expr1_","_$Select(arg3indr:"@i",1:"")_"arg3"
	. . Set expr2=expr2_","_$Select(arg3indr:"@i",1:"")_"arg3"
	. Set expr1=expr1_")"
	. Set expr2=expr2_")"
	. Do:(isconcat)					; Add some more concat args - both numbers and strings are viable
	. . For j=1:1:$Random(3)+1 Do
	. . . Set token=$Select($Random(2):$$RandomString(),1:$$RandomNumber(op))
	. . . Set expr1=expr1_"_"_token
	. . . Set expr2=expr2_"_"_token
	. Do:(parenexpr)
	. . Set expr1=expr1_")"
	. . Set expr2=expr2_")"
	. Write TAB,"Set rslt1=",expr1,!
	. Write TAB,"Set arg1=arg1sav",!	; Reset back to original value
	. Write TAB,"Set rslt2=",expr2,!
	. Write TAB,"Do CheckRslts(",i,",.rslt1,.rslt2,""",$$ReQuote(expr1),""",arg1sav)",!
	Write !!
	Write TAB,"Write !!,""Total of "",errcnt,"" errors out of ",numtests," test expressions"",!",!
	Write TAB,"Quit",!!
	;
	; Write out the functions to be used
	;
	Set line=""
	For l=1:1  Do  Quit:("EndAddedFunctions"=line)
	. Set line=$Text(AddedFunctions+l^@rtnname)
	. Quit:("EndAddedFunctions"=line)
	. Set:(" "=$ZExtract(line,1)) $ZExtract(line,1)=TAB	; Restore tab that $Text() removes
	. Write line,!
	Close outfile
	Use $P
	Write "Generated ",numtests," order evaluation tests",!
	Do:(rungenfile)
	. Write !,"Invoking generated test: ",outfile,!!
	. New (outfile)
	. Do @("^"_$ZPiece(outfile,".",1))
	Quit

;
; Set of routines randomly chosen that modify their argument in some way returning the modified value.
; Arguments to these routines should be passed by reference (use dot syntax). Note below routines are
; added to the output program (between labels AddedFunctions and EndAddedFunctions).
;
AddedFunctions
;
; Routine to verify results
;
CheckRslts(tst,v1,v2,expr,arg1)
	Quit:(v1=v2)		; Nothing to do if values are equal
	New isnum		; Else, write an appropriate failure message
	Set isnum=(0=$ZFind(alpha,$ZExtract(arg1,1)))	; Printing number or string? Need to put quotes around a string.
	Write "Fail #",$Increment(failcnt)," - Test ",tst," failed comparison - expected (",v2,") but computed (",v1
	Write ") for expression ",expr," with arg1=",$Select(isnum:arg1,1:""""_arg1_""""),!
	Set errcnt=errcnt+1
	Quit

;
; Routine to add 1 to a numeric value (M flavor of $Increment().
;
AddOne(x)
	Set x=x+1
	Quit x

;
; Routine to subtract one from a numeric value
;
SubOne(x)
	Set x=x-1
	Quit x

;
; Routine to double a numeric value
;
DoubleNum(x)
	Set x=x*2
	Quit x

;
; Routine to double the character(s) of a string
;
DoubleStr(x)
	Set x=x_x
	Quit x

;
; Routine to bump the first character of a string by one
;
BumpChar(x)
	New c,cn
	Set c=$ZExtract(x,1)
	Set cn=$ZFind(alpha,c)
	If (cn'>$ZLength(alpha)) Set c=$ZExtract(alpha,cn)
	Else  Set c=$ZExtract(alpha,1)
	Set $ZExtract(x,1)=c
	Quit x

;
; Routine to reverse the case of the first character of a string (lower->upper or upper->lower)
;
CaseRev(x)
	New c,cn,fromstr,toostr
	Set c=$ZExtract(x,1)
	Set cn=$Ascii(c)
	If (cn>$Ascii("z")) Set fromstr=alphauppc,toostr=alphalowc
	Else  Set fromstr=alphalowc,toostr=alphauppc
	Set $ZExtract(x,1)=$Translate($ZExtract(x,1),fromstr,toostr)
	Quit x
EndAddedFunctions

;
; Routine to generate a random value to use in an expression with side-effects with a range potentially
; limited by the operator in use (e.g. keep it small for exponentiation).
;
RandomNumber(op)
	If ("**"=op) Quit $Random(11)-5		; For exponents, limit value to -5 to +5
	Quit $Random(2**31-1)-(2**30-1)		; Others, limit range to -1G to +1G - notation works around a parser issue in VMS

;
; Generate random string from 1 to 10 bytes in length
;
RandomString()
	New str,i
	Set str=""
	For i=1:1:$Random(10)+1 Set str=str_$ZExtract(alpha,$Random(alphalen)+1)
	Quit """"_str_""""

;
; Requote a given string - effectively double any quotes we see since this string is being put out as text
;
ReQuote(str)
	New i,j,newstr
	Set newstr=""
	For i=1:1:$ZLength(str) Do
	. Set newstr=newstr_$Select(""""=$ZExtract(str,i):"""""",1:$ZExtract(str,i))
	Quit newstr

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
; Output timestamped error message - generate dump.
;
GTMError(text)
	New dumpfile,saveIO,$ETrap
	Set $ETrap=""
	Close:(outfileopen) outfile	; Would delete it but might be useful to see last thing generated
	Do DoWrite($ZDate($Horolog,"24:60:SS")_text)
	Set saveIO=$IO
	Set dumpfile="EvalOrder-fail.zshowdmp-"_$ZDate($Horolog,"YEARMMDD-2460SS")_".txt"
	Open dumpfile:New
	Use dumpfile
	ZShow "*"
	Close dumpfile
	Use saveIO
	ZHalt 1
