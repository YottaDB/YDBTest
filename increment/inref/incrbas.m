;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incrbas ; ------------------------------------------------------------------------------------------
	;   Master driver program to test $INCREMENT functionality.
	; ------------------------------------------------------------------------------------------
	set stagestr="incrbas"
	set $ztrap="goto incrtrap"
	set allstage="increrr1,increrr2,incr01,incr02"
	set allstage=allstage_",incr03a,incr03b,incr03c,incr03d,incr03e"
	set allstage=allstage_",incr04a,incr04b,incr04c,incr04d,incr04e,incr04f,incr04g,incr04h,incr04i"
	set allstage=allstage_",incr05a,incr05b,incr05c,incr05d,incr05e,incr05f"
	set allstage=allstage_",incr06a,incr06b,incr06c,incr06d,incr06e"
	do sstep	; single stepping on for readability of reference file
	set newstage="--------------------------------------------------------------------------------------"
	set substagestr=" ----------------------------------------------------- "
	set spacestr="               "
	;
	set numtests=$length(allstage,",")
	for mainindx=1:1:numtests  do
	.	set stagestr=$piece(allstage,",",mainindx)  ;write newstage
	.	for gvnorlvn="lvn","gvn"  do
	.	.	write substagestr,!,spacestr,stagestr," : ",gvnorlvn,!,substagestr
	.	.	do @stagestr
	quit

sstep	;
	set $zstep="set %zsaveio=$io use $p w:$x ! write stagestr,"":"" zp @$zpos  use %zsaveio zstep into"
	zb sstep+3:"zstep into"
	set %zsaveio=$io use $p write !,"Stepping STARTED",!  use %zsaveio
	quit

sstop   ;
	set $zstep=""
	set %zsaveio=$io use $p write !,"Stepping STOPPED",!  use %zsaveio
	quit

incrtrap; ------------------------------------------------------------------------------------------
	;   Error handler. Prints current error and continues processing from the next M-line
	; ------------------------------------------------------------------------------------------
	do sstop
	if $tlevel trollback
	new savestat,mystat,prog,line,newprog
	set savestat=$zstatus
	set mystat=$piece(savestat,",",2,100)
	set prog=$piece($zstatus,",",2,2)
	set line=$piece($piece(prog,"+",2,2),"^",1,1)
	set line=line+1
	set newprog=$piece(prog,"+",1)_"+"_line_"^"_$piece(prog,"^",2,3)
	write "ZSTATUS=",mystat,!
	set newprog=$zlevel_":"_newprog
	do sstep
	zgoto @newprog

setglvn(glvname,value);
	set @glvname=value
	if gvnorlvn="gvn"  set @glvname="^"_@glvname
	kill @@glvname	; start afresh
	quit

increrr1; ------------------------------------------------------------------------------------
	;    Test that $INC is not a valid function name
	; ------------------------------------------------------------------------------------
	new glvn
	do setglvn("glvn","x")
	set @glvn=16
	write $INC(@glvn,6)	; Expected: INVFCN error because of incomplete function name
	kill @glvn
	quit

increrr2; ------------------------------------------------------------------------------------
	;    Test that $ZINK is not a valid function name
	; ------------------------------------------------------------------------------------
	new glvn
	do setglvn("glvn","X")
	set @glvn=0
	write $ZINK(@glvn,7)	; Expected: INVFCN error because of incomplete function name
	kill @glvn
	quit

incr01	; ------------------------------------------------------------------------------------------
	;   Test that $I, $INCR, $ZINCR, $INCREMENT and $ZINCREMENT are synonyms of the same thing
	; ------------------------------------------------------------------------------------------
	new glvn
	do setglvn("glvn","x1")
	set @glvn=1
	write $I(@glvn,1)		; Expected:  2
	write $INCR(@glvn,2)		; Expected:  4
	write $INCREMENT(@glvn,4)	; Expected:  8
	write $ZINCR(@glvn,3)		; Expected: 11
	write $ZINCREMENT(@glvn,5)	; Expected: 16
	zwrite @glvn			; Expected: 16
	kill @glvn
	quit

incr02	; ------------------------------------------------------------------------------------
	;    Test that expr defaults to 1 if not specified
	; ------------------------------------------------------------------------------------
	new glvn
	do setglvn("glvn","X5f")
	set @glvn=4
	write $incr(@glvn,3)		; Expected:  7
	write $i(@glvn)			; Expected:  8
	write $i(@glvn,@glvn)		; Expected: 16
	write $incr(@glvn)		; Expected: 17
	zwrite @glvn			; Expected: 17
	kill @glvn
	quit

incr03	; ------------------------------------------------------------------------------------
	;    Test of First argument "glvn" in various forms
	; ------------------------------------------------------------------------------------

incr03a	; ------------------------------------------------------------------------------------
	;    Test of First argument glvn is local or global variable : Simple tests
	; ------------------------------------------------------------------------------------
	new glvn1,glvn2,glvn3,indx
	do setglvn("glvn1","variablex8ace")
	do setglvn("glvn2","variableyMr6L")
	do setglvn("glvn3","variablezHypg")
	set @glvn1=11
	set @glvn2=222
	set @glvn3=3333
	set @glvn3=$incr(@glvn2,@glvn1)
	zwrite @glvn1		; Expected:  11
	zwrite @glvn2		; Expected: 233
	zwrite @glvn3		; Expected: 233
	;
	for indx=1:1:10  do
	.	write "@glvn1 = ",@glvn1," : $incr(@glvn1,@glvn1) = "
	.	write $incr(@glvn1,@glvn1)	; Expected: <11,22>, <22,44>, ... <5632,11264>
	zwrite @glvn1		; Expected: 11264
	kill @glvn1,@glvn2,@glvn3
	quit

incr03b	; -----------------------------------------------------------------------------------------
	;    Test that glvn is coerced to a numeric value even if it contains non-numeric characters
	; -----------------------------------------------------------------------------------------
	new glvn
	do setglvn("glvn","xAb2long")
	set @glvn="abcd89"  write $incr(@glvn)		; Expected:  1
	zwrite @glvn					; Expected:  1
	set @glvn="23abcd"  write $incr(@glvn)		; Expected: 24
	zwrite @glvn					; Expected: 24
	set @glvn="-74.5f8" write $incr(@glvn,"12ab3")	; Expected: -62.5
	zwrite @glvn					; Expected: -62.5
	kill @glvn
	quit

incr03c	; ------------------------------------------------------------------------------------
	;    Test of glvn got from indirection on the result of another intrinsic function
	; ------------------------------------------------------------------------------------
	new piecestr,tmp,glvn
	do setglvn("glvn","AMindicator")			; set glvn="AMindicator" or glvn="^AMindicator"
	do setglvn(glvn,"PMvariable")			; set AMindicator="PMvariable"    or ^AMindicator="^PMvariable"
	set @@glvn=11				; set PMvariable=11      or ^PMvariable=11
	set piecestr="N,"_glvn_",E"
	write $incr(@@$piece(piecestr,",",2))	; Expected: 12
	zwrite @glvn				; Expected: "PMvariable" or "^PMvariable"
	zwrite @@glvn				; Expected: 12
	set tmp=@glvn
	write $incr(@$piece(piecestr,",",2))	; Expected: 1
	zwrite @glvn				; Expected: 1
	zwrite @tmp				; Expected: 12
	kill @tmp,@glvn
	quit

incr03d	; ------------------------------------------------------------------------------------
	;    Test of glvn got from indirection on string containing nested functions
	; ------------------------------------------------------------------------------------
	new c,C
	kill ^variable
	do setglvn("c(1)","x")
	set @c(1)=1
	set ^variable(123)=$c(66),C(1,6)="c(1)"
	write $incr(@@@$piece($char(65,66,67),^variable(123),$find("abc","a"))@(1,6),9)	; Expected: 10
	zwrite C									; Expected: "c(1)"
	zwrite c									; Expected: "x" or "^x"
	zwrite @c(1)									; Expected: 10
	kill @c(1),^variable
	quit

incr03e	; ------------------------------------------------------------------------------------
	;    Test of glvn (with and without subscripts) with NOUNDEF and UNDEF view qualifiers
	; ------------------------------------------------------------------------------------
	new undefstr,stgstr1
	for undefstr="NOUNDEF","UNDEF"  do
	.	view undefstr
	.	for stgstr1="incr03e1","incr03e2"  do
	.	.	write substagestr,!,spacestr,stgstr1," : ",gvnorlvn," : ",undefstr,!,substagestr
	.	.	do @stgstr1
	quit

incr03e1; ------------------------------------------------------------------------------------
	;    Test of glvn without subscripts that is undefined
	; ------------------------------------------------------------------------------------
	new glvn
	do setglvn("glvn","xZjDXhBVfzTd")
	set @glvn@(1)="abcd"
	write $incr(@glvn)	; Expected: 1
	write $incr(@glvn)	; Expected: 2
	zwrite @glvn		; Expected: (xZjDXhBVfzTd(1)="abcd" or ^xZjDXhBVfzTd(1)="abcd") AND (xZjDXhBVfzTd=2 or ^xZjDXhBVfzTd=2)
	zkill @glvn		; kill "xZjDXhBVfzTd" (or ^xZjDXhBVfzTd) without killing "xZjDXhBVfzTd(1)" (or "^xZjDXhBVfzTd(1)")
	write $incr(@glvn)	; Expected: 1
	write $incr(@glvn)	; Expected: 2
	zwrite @glvn		; Expected: (xZjDXhBVfzTd(1)="abcd" or ^xZjDXhBVfzTd(1)="abcd") AND (xZjDXhBVfzTd=2 or ^xZjDXhBVfzTd=2)
	kill @glvn		; kill "xZjDXhBVfzTd" and "xZjDXhBVfzTd(1)" (or ^xZjDXhBVfzTd and ^xZjDXhBVfzTd(1))
	write $incr(@glvn)	; Expected: 1
	zwrite @glvn		; Expected: xZjDXhBVfzTd=1 (or ^xZjDXhBVfzTd=1) and nothing else
	kill @glvn
	quit

incr03e2; ------------------------------------------------------------------------------------
	;    Test of glvn with subscripts that is undefined
	; ------------------------------------------------------------------------------------
	new glvn
	do setglvn("glvn","xZjDXhBVfzTd")
	set @glvn="abcd"
	write $incr(@glvn@(1),-5)	; Expected: -5
	zwrite @glvn			; Expected: (xZjDXhBVfzTd="abcd" or ^xZjDXhBVfzTd="abcd") AND (xZjDXhBVfzTd(1)=5 or ^xZjDXhBVfzTd(1)=5)
	zkill @glvn			; kill "xZjDXhBVfzTd" (or ^xZjDXhBVfzTd) without killing xZjDXhBVfzTd(1) (or ^xZjDXhBVfzTd(1))
	write $incr(@glvn@(1),8)	; Expected: 3
	zwrite @glvn			; Expected: (xZjDXhBVfzTd(1)=3 (or ^xZjDXhBVfzTd(1)=3) and nothing else)
	write $incr(@glvn,23)		; Expected: 23
	zwrite @glvn			; Expected: (xZjDXhBVfzTd=23,xZjDXhBVfzTd(1)=3 (or ^xZjDXhBVfzTd=23,^xZjDXhBVfzTd(1)=3) and nothing else)
	write $incr(@glvn@(1,"abcd"))	; Expected: 1
	zwrite @glvn			; Expected: (xZjDXhBVfzTd=23,xZjDXhBVfzTd(1)=3,xZjDXhBVfzTd(1,"abcd")=1 (or ^xZjDXhBVfzTd=23,^xZjDXhBVfzTd(1)=3,^xZjDXhBVfzTd(1,"abcd")=1) and nothing else)
	zkill @glvn@(1)
	write $incr(@glvn@(1,"abcd"))	; Expected: 2
	write $incr(@glvn@(1),-5)	; Expected: -5
	zwrite @glvn			; Expected: (xZjDXhBVfzTd=23,xZjDXhBVfzTd(1)=-5,xZjDXhBVfzTd(1,"abcd")=2 (or ^xZjDXhBVfzTd=23,^xZjDXhBVfzTd(1)=-5,^xZjDXhBVfzTd(1,"abcd")=2) and nothing else)
	kill @glvn
	quit

incr04	; ------------------------------------------------------------------------------------
	;    Test of second argument "expr" in various forms
	; ------------------------------------------------------------------------------------

incr04a	; ------------------------------------------------------------------------------------
	;    "expr" various simple cases
	; ------------------------------------------------------------------------------------
	new glvn
	do setglvn("glvn","xpressionforms")
	set @glvn=123
	write $incr(@glvn,1)		; Expected: 124
	write $incr(@glvn,-1)		; Expected: 123
	write $incr(@glvn,100)		; Expected: 223
	write $incr(@glvn,-200)		; Expected:  23
	write $incr(@glvn,"1abcd")	; Expected:  24
	write $incr(@glvn,"-3X;")	; Expected:  21
	write $incr(@glvn,"X235")	; Expected:  21
	write $incr(@glvn,"wxyz")	; Expected:  21
	zwrite @glvn			; Expected: xpressionforms=21 (or ^xpressionforms=21) and nothing else
	kill @glvn
	quit

incr04b	; ------------------------------------------------------------------------------------
	;    "expr" is an empty string
	; ------------------------------------------------------------------------------------
	new glvn
	do setglvn("glvn","xpressionform(1,""23"")")
	set @glvn=12
	write $incr(@glvn,"")		; Expected: 12
	zwrite @glvn			; Expected: xpressionform(1,"23")=12 (or ^xpressionform(1,"23")=12) and nothing else
	kill @glvn
	quit

incr04c	; ------------------------------------------------------------------------------------
	;    "expr" is a number (or string) represented in Exponential notation
	; ------------------------------------------------------------------------------------
	new glvn
	do setglvn("glvn","xpressionform(""23"")")
	set @glvn=-123456789E15
	write $incr(@glvn,1E25)		; Expected: 9876543211000000000000000
	zwrite @glvn			; Expected: xpressionform("23")=9876543211000000000000000 (or ^xpressionform(23))
	write $incr(@glvn,"1E25")	; Expected: 19876543211000000000000000
	zwrite @glvn			; Expected: xpressionform("23")=19876543211000000000000000 (or ^xpressionform(23))
	set @glvn="1E-4"
	write $incr(@glvn,"1E-5abc")	; Expected: .00011
	write $incr(@glvn,-1E-5)	; Expected: .0001
	write $incr(@glvn,-5.12355678)	; Expected: -5.12345678
	write $incr(@glvn,-1E-5a)	; Expected: RPARENMISSING error because of trailing "a" in -1E-5a
	zwrite @glvn			; Expected: -5.12345678
	kill @glvn
	quit

incr04d	; ------------------------------------------------------------------------------------
	;    "expr" is a lvn
	; ------------------------------------------------------------------------------------
	new glvn,incrlocal
	do setglvn("glvn","TOKEN")
	set @glvn=17
	set incrlocal=37
	write $incr(@glvn,incrlocal)		; Expected: 54
	set incrlocal(1,"abcd")=-29
	write $incr(@glvn,incrlocal(1,"abcd"))	; Expected: 25
	zwrite @glvn				; Expected: TOKEN=25 (or ^TOKEN=25)
	zwrite incrlocal			; Expected: incrlocal=37,incrlocal(1,"abcd")=-29
	kill @glvn
	quit

incr04e	; ------------------------------------------------------------------------------------
	;    "expr" is a gvn
	; ------------------------------------------------------------------------------------
	new glvn
	do setglvn("glvn","TOKEN")
	set @glvn=17
	kill ^incrlocal
	set ^incrlocal=-37
	write $incr(@glvn,^incrlocal)		; Expected: -20
	set ^incrlocal("abcd",1)=-29
	write $incr(@glvn,^incrlocal("abcd",1))	; Expected: -49
	zwrite @glvn				; Expected: TOKEN=-49 (or ^TOKEN=-49)
	zwrite ^incrlocal			; Expected: ^incrlocal=-37,^incrlocal("abcd",1)=-29
	kill ^incrlocal
	kill @glvn
	quit

incr04f	; ------------------------------------------------------------------------------------
	;    "expr" is a svn
	; ------------------------------------------------------------------------------------
	new glvn
	do setglvn("glvn","sVNvariable") ; the code below assumes $test will be 0 if glvn is local and 1 if glvn is global
	set @glvn=17
	write $incr(@glvn,$test)		; Expected: 17 (if local) and 18 (if global)
	write $incr(@glvn,$tlevel)		; Expected: 17 (if local) and 18 (if global)
	write $incr(@glvn,$zinterrupt)		; Expected: 17 (if local) and 18 (if global)
	write $incr(@glvn,$zininterrupt)	; Expected: 17 (if local) and 18 (if global)
	zwrite @glvn				; Expected: sVNvariable=17 (or ^sVNvariable=18) and nothing else
	kill @glvn
	quit

incr04g	; ------------------------------------------------------------------------------------
	;    "expr" contains $INCREMENT function
	; ------------------------------------------------------------------------------------
	new glvn,y
	kill ^z
	do setglvn("glvn","Increment")
	set @glvn=3
	set y=7
	set ^z=17
	write $incr(@glvn,y)				; Expected:  10
	write $incr(@glvn,$incr(@glvn,^z))		; Expected:  54
	write $incr(@glvn,$incr(@glvn,$incr(^z,y)))	; Expected: 156
	zwrite @glvn					; Expected: Increment=156 (or ^Increment=156)
	zwrite y					; Expected: y=7
	zwrite ^z					; Expected: ^z=24
	kill @glvn
	kill ^z
	quit

incr04h	; ------------------------------------------------------------------------------------
	;    "expr" is a full-fledged expression
	; ------------------------------------------------------------------------------------
	new glvn,var1,var2
	do setglvn("glvn","loongname0123456789012345678901twothree(1,2,3,5)")
	set @glvn=10
	set var1=23
	set var2=45
	write $incr(@glvn,$get(var1)-$data(var2)+(var2*var1/9))		; Expected: 147
	set var2(1)="abcd"
	write $incr(@glvn,$get(var1)-$data(var2)+var2)			; Expected: 204
	zwrite @glvn							; Expected: 204
	zwrite var1							; Expected: var1=23 (or ^var1=23)
	zwrite var2							; Expected: var2=45,var2(1)="abcd" (or ^var2=45,^var2(1)="abcd")
	kill @glvn
	quit

incr04i	; ------------------------------------------------------------------------------------
	;    Test that an expression involving $incr gets evaluated from left to right
	; ------------------------------------------------------------------------------------
	new glvn1,glvn2,glvn3
	do setglvn("glvn1","abCdefghijk(1,""xstr"",4)")
	do setglvn("glvn2","efGhjklmnop(""ymNd"",4,2)")
	do setglvn("glvn3","Gchefghijkl(""Kpdn"",45.5)")
	set @glvn1=1,@glvn2=2,@glvn3=3
	write $incr(@glvn1,@glvn2)+$incr(@glvn2,@glvn3)+$incr(@glvn3,@glvn1)+$incr(@glvn1,@glvn3)+$incr(@glvn2,@glvn1)+$incr(@glvn3,@glvn2)
	zwrite @glvn1	; Expected:  9
	zwrite @glvn2	; Expected: 14
	zwrite @glvn3	; Expected: 20
	kill @glvn1
	kill @glvn2
	kill @glvn3
	quit

incr05	; ------------------------------------------------------------------------------------
	;    Test of various forms of indirection on "glvn" and "expr"
	; ------------------------------------------------------------------------------------

incr05a	; ------------------------------------------------------------------------------------
	;    "glvn" is a lvn derived from multiple indirections
	; ------------------------------------------------------------------------------------
	new globalnameB,globalnameNA
	do setglvn("globalnameB(3)","globalnameA(1,3)")
	set @globalnameB(3)@(4,67)="globalnameNA(2,3)",globalnameNA(2,3)=11
	write $incr(@@globalnameB(3)@(4,67))	; Expected: 12
	zwrite @globalnameB(3)@(4,67)		; Expected: globalnameA(1,3,4,67)="globalnameNA(2,3)" (or ^globalnameA(1,3,4,67)="globalnameNA(2,3)")
	zwrite globalnameNA			; Expected: globalnameNA(2,3)=12
	kill @globalnameB(3)
	kill globalnameB
	kill globalnameNA
	quit
	;

incr05b	; ------------------------------------------------------------------------------------
	;    "glvn" is a gvn derived from multiple indirections
	; ------------------------------------------------------------------------------------
	new glvn
	do setglvn("glvn","longvariableV3GET(9)")
	set @glvn="^longvariableV3GET(3,5)",^longvariableV3GET(3,5,"BOOK",1)=22
	write $incr(@(@glvn)@("BOOK",1))	; Expected: 23
	zwrite ^longvariableV3GET(3,*)			; Expected: ^longvariableV3GET(3,5,"BOOK",1)=23
	kill @glvn
	kill ^longvariableV3GET
	quit
	;
incr05c	; ------------------------------------------------------------------------------------
	;    "expr" is derived from indirection
	; ------------------------------------------------------------------------------------
	new glvn,A,B,C
	do setglvn("glvn","VV")
	set @glvn=-25
	set A="B(1,C(8))",C(8)="88",B(1,88)="188",@glvn@(188)=33
	write $incr(@glvn,@glvn@(@A))		; Expected: 8
	write @glvn				; Expected: 8
	kill @glvn
	quit
	;
incr05d	; ------------------------------------------------------------------------------------
	;    "expr" is derived from nested single indirections
	; ------------------------------------------------------------------------------------
	new glvn,A,B,VV
	do setglvn("glvn","AA")
	set @glvn=1
	set B="1",VV="@VV(B)",VV(1)="VV(B,B+B)",VV(1,2)="1.5"
	write $incr(@glvn,$get(A,@VV))		; Expected: 2.5
	zwrite @glvn				; Expected: 2.5
	kill @glvn
	quit
	;
incr05e	; ------------------------------------------------------------------------------------
	;    "expr" is derived from nested double indirections (i.e. @name@ syntax)
	; ------------------------------------------------------------------------------------
	new glvn,BB
	kill ^VV
	do setglvn("glvn","AA")
	set @glvn=1
	set ^VV(1,2,3,4,12,456)="1234567",^VV="@BB@(3,4)",^VV(1,2,3,4,12,4)="44"
	set BB="^VV(1,2)"
	write $incr(@glvn,@^VV@(12,456))	; Expected: 1234568
	zwrite @glvn				; Expected: AA=1234568 (or ^AA=1234568)
	kill @glvn
	kill ^VV
	quit
	;
incr05f	; ---------------------------------------------------------------------------------------------------
	;    "expr" is derived from double indirections including subscripts (i.e. @name(1)@ syntax)
	; ---------------------------------------------------------------------------------------------------
	new glvn
	kill ^VV
	do setglvn("glvn","AA")
	set @glvn=1
	set ^VV(3,4,12,456)="12345",^VV(0)="^(3,4)",^VV(3,4,12,4)="44"
	write $incr(@glvn,@^VV(0)@(12,456))	; Expected: 12346
	zwrite @glvn				; Expected: AA=12346 (or ^AA=12346)
	kill @glvn
	kill ^VV
	quit
	;

incr06	; ------------------------------------------------------------------------------------
	;    Test that naked reference is properly set
	; ------------------------------------------------------------------------------------

incr06a	; ------------------------------------------------------------------------------------
	;    "expr" contains global references
	; ------------------------------------------------------------------------------------
	new glvn
	do setglvn("glvn","globalreference(1)")
	set @glvn=1
	kill ^m,^k
	set ^m(2)=3
	set ^k(3)=2
	write $incr(@glvn,^m(2)+^k(3))	; Expected: 6
	write $name(^(4))		; Expected: ^k(4) (if lvn) and ^globalreference(4) (if gvn)
	write @glvn			; Expected 6
	kill @glvn
	kill ^m,^k
	quit

incr06b	; ------------------------------------------------------------------------------------
	;    "expr" contains local references
	; ------------------------------------------------------------------------------------
	new glvn,a
	do setglvn("glvn","localreference(1)")
	set @glvn=22
	set a=33
	kill ^m(1)
	write $incr(@glvn,a)	; Expected: 55
	write $name(^(4))	; Expected: ^m(4) (if lvn) and ^localreference(4) (if gvn)
	write @glvn		; Expected: 55
	kill @glvn
	kill ^m
	quit

incr06c	; ------------------------------------------------------------------------------------
	;    "expr" is a naked reference
	; ------------------------------------------------------------------------------------
	new glvn
	do setglvn("glvn","A")
	set @glvn@(0)=0
	set @glvn@(10)=10
	set ^VV("A",1,2,3)=123
	set ^VV("A",1,2,4)="A124"
	set ^VV("A",4)="A4"
	write $incr(@glvn@($data(^VV("A",1,2))),^(1,2,3))	; Expected: 133
	write $name(^(4))					; Expected: ^VV("A",1,4) (if lvn) and ^A(4) (if gvn)
	write @glvn@(10)					; Expected: 133
	kill @glvn
	kill ^VV
	quit

incr06d	; ------------------------------------------------------------------------------------
	;    "glvn" contains naked references and "expr" does not
	; ------------------------------------------------------------------------------------
	new glvn
	do setglvn("glvn","X")
	kill ^longvariableV3GET
	;
	set @glvn@(4)=glvn_"4"
	set ^longvariableV3GET(4)=4,^longvariableV3GET(2,3)=23
	set @glvn@(23)=523,@glvn@(123)=5123
	set ^longvariableV3GET(1,2,3)=123,^longvariableV3GET(1,2,4)=124,^longvariableV3GET(1,3)=13,^longvariableV3GET(1,4)=14
	;
	write $incr(@glvn@(^(2,3)))_" "_^(4)	; Expected: "5124 124" (if lvn) or "5124 ^X4" (if gvn)
	write @glvn@(123)			; Expected: 5124
	kill @glvn
	kill ^longvariableV3GET
	quit

incr06e	; ------------------------------------------------------------------------------------
	;    "glvn" contains naked references and "expr" does too
	;    test that "expr" gets evaluated ahead of "glvn"
	; ------------------------------------------------------------------------------------
	new glvn
	do setglvn("glvn","X")
	kill ^longvariableV3GET
	kill ^longvariableV4GET
	;
	set @glvn@(4)=glvn_"4"
	set ^longvariableV3GET(4)=4,^longvariableV3GET(2,3)=23
	set @glvn@(23)=523,@glvn@(123)=5123
	set @glvn@(3123)=53123,@glvn@(4123)=54123
	set ^longvariableV4GET(1,2,3)=4123,^longvariableV4GET(1,2,4)=4124,^longvariableV4GET(1,3)=413,^longvariableV4GET(1,4)=414
	set ^longvariableV4GET(1,3123)=413123,^longvariableV4GET(2,3)=423
	set ^longvariableV3GET(1,2,3)=3123,^longvariableV3GET(1,2,4)=3124,^longvariableV3GET(1,3)=313,^longvariableV3GET(1,4)=314
	;
	write $incr(@glvn@(^(2,3)),^longvariableV4GET(1,^(2,3)))_" "_^(4)	; Expected: "467246 4124" (if lvn) or "467246 ^X4" (if gvn)
	write @glvn@(4123)					; Expected: 467246
	kill @glvn
	kill ^longvariableV3GET
	kill ^longvariableV4GET
	quit

