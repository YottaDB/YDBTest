;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;
; Test for GTM-9277 - A number of expressions have been identified as being susceptible to this issue. Generally,
; this issue shows up when an intrinsic function is driven where a crafted boolean expression's value is being
; passed as an argument to the implementing C function as an integer instead of as an internal mval. The boolean
; expression is crafted such that the last term of the expression has side-effects. This means it is either an
; extrinsic, an $increment() function, or an indirect reference.
;
gtm9277
	;
	; Initialize some variables used in the generated expressions below
	;
	set FALSE=0,iFALSE="FALSE"
	set TRUE=1,iTRUE="TRUE"
	;
	; Following are calls to test the expression listed which drives the named C routine inside tbhe
	; YottaDB runtime.
	;
	; Each expression is tested in 3 ways:
	;  1. As the value in a SET expression (e.g. SET x=<expr>)
	;  2. As the conditional expression in an IF statement (e.g. IF (expr))
	;  3. As the preconditional expression on a command (in this case we use KILL) (e.g. KILL:(expr) x)
	;
	; Each expression is then XECUTEd to make sure the compiler can deal with it.
	;
	; Note this is not an exhaustive list of the types of calls that explode in the fashion that these do
	; on pre-V63013 based versions. There were some involving some uses of $ZATRANSFORM() that were bypassed
	; because the transformation routines required to use some $ZATRANSFORM() uses are non-trivial to setup.
	; In addition, one case involving using an expression for $zpiece() with a single character delimiter
	; (which gets passed to op_zp1.c as an integer) did NOT fail so was removed.
	;
	; Note this test is written "brute force" instead of more elegant approach in an attempt to make it more
	; usable to the "fuzz testing" facilities we run to identify areas of the code base with problems.
	;
	write !,"# Testing expression: $ascii(""abc"",(1&@iTRUE))",!				; Testing op_fnascii()
	set x=($ascii("abc",(1&@iTRUE)))
	if ($ascii("abc",(1&@iTRUE)))
	kill:($ascii("abc",(1&@iTRUE))) x

	write !,"# Testing expression: $char((TRUE&$$Always1))",!				; Testing op_fnchar()
	set x=($char((TRUE&$$Always1)))
	if ($char((TRUE&$$Always1)))
	kill:($char((TRUE&$$Always1))) x

	write !,"# Testing expression: $find(""abcd"",""b"",(FALSE!$increment(zz)))",!		; Testing op_fnfind()
	set x=($find("abcd","b",(FALSE!$increment(zz))))
	if ($find("abcd","b",(FALSE!$increment(zz))))
	kill:($find("abcd","b",(FALSE!$increment(zz)))) x

	write !,"# Testing expression: $fnumber(42,""P"",(TRUE&@iTRUE))",!			; Testing op_fnfnumber()
	set x=($fnumber(42,"P",(TRUE&@iTRUE)))
	if ($fnumber(42,"P",(TRUE&@iTRUE)))
	kill:($fnumber(42,"P",(TRUE&@iTRUE))) x

        write !,"# Testing expression: ($justify($job,(FALSE!$$Always0)))",!			; Testing op_fnj2()
        set x=($justify($job,(FALSE!$$Always0)))
        if ($justify($job,(FALSE!$$Always0)))
        kill:($justify($job,(FALSE!$$Always0))) x

        write !,"# Testing expression: ($piece(""abcd"",""c"",(0!$increment(y))))",!		; Testing op_fnpiece()
        set x=($piece("abcd","c",(0!$increment(y))))
        if ($piece("abcd","c",(0!$increment(y))))
        kill:($piece("abcd","c",(0!$increment(y)))) x

        write !,"# Testing expression: ($qsubscript(""a(1,2,3)"",($$Always1!$$Always0)))",!	; Testing op_fnqsubscript()
        set x=($qsubscript("a(1,2,3)",($$Always1!$$Always0)))
        if ($qsubscript("a(1,2,3)",($$Always1!$$Always0)))
        kill:($qsubscript("a(1,2,3)",($$Always1!$$Always0))) x

        write !,"# Testing expression: ($random(($$Always1!@iFALSE)))",!			; Testing op_fnrandom()
        set x=($random(($$Always1!@iFALSE)))
        if ($random(($$Always1!@iFALSE)))
        kill:($random(($$Always1!@iFALSE))) x

        write !,"# Testing expression: ($stack((@iTRUE&$increment(y))))",!			; Testing op_fnstack1()
        set x=($stack((@iTRUE&$increment(y))))
        if ($stack((@iTRUE&$increment(y))))
        kill:($stack((@iTRUE&$increment(y)))) x

        write !,"# Testing expression: ($zatransform(""abc"",(1&$$Always1)))",!			; Testing op_fnzatransform()
        set x=($zatransform("abc",(1&$$Always1)))
        if ($zatransform("abc",(1&$$Always1)))
        kill:($zatransform("abc",(1&$$Always1))) x

        write !,"# Testing expression: ($zbitfind($char(0)_""101"",(@iFALSE!$increment(zz))))",! ; Testing op_fnzbitfind()
        set x=($zbitfind($char(0)_"101",(@iFALSE!$increment(zz))))
        if ($zbitfind($char(0)_"101",(@iFALSE!$increment(zz))))
        kill:($zbitfind($char(0)_"101",(@iFALSE!$increment(zz)))) x

        write !,"# Testing expression: ($zbitfind($char(0)_""101"",0,(@iTRUE&$$Always1)))",!	; Testing op_fnzbitfind()
        set x=($zbitfind($char(0)_"101",0,(@iTRUE&$$Always1)))
        if ($zbitfind($char(0)_"101",0,(@iTRUE&$$Always1)))
        kill:($zbitfind($char(0)_"101",0,(@iTRUE&$$Always1))) x

        write !,"# Testing expression: ($zbitget($char(0)_""101"",(1!@iFALSE)))",!		; Testing op_fnzbitget()
        set x=($zbitget($char(0)_"101",(1!@iFALSE)))
        if ($zbitget($char(0)_"101",(1!@iFALSE)))
        kill:($zbitget($char(0)_"101",(1!@iFALSE))) x

        write !,"# Testing expression: ($zbitset($char(0)_""101"",(TRUE&@iTRUE),0))",!		; Testing op_fnzbitset()
        set x=($zbitset($char(0)_"101",(TRUE&@iTRUE),0))
        if ($zbitset($char(0)_"101",(TRUE&@iTRUE),0))
        kill:($zbitset($char(0)_"101",(TRUE&@iTRUE),0)) x

        write !,"# Testing expression: ($zbitset($char(0)_""101"",3,(@iTRUE!$increment(zz))))",! ; Testing op_fnzbitset()
        set x=($zbitset($char(0)_"101",3,(@iTRUE!$increment(zz))))
        if ($zbitset($char(0)_"101",3,(@iTRUE!$increment(zz))))
        kill:($zbitset($char(0)_"101",3,(@iTRUE!$increment(zz)))) x

        write !,"# Testing expression: ($zbitstr(($$Always0!$$Always1)))",!			; Testing op_fnzbitstr()
        set x=($zbitstr(($$Always0!$$Always1)))
        if ($zbitstr(($$Always0!$$Always1)))
        kill:($zbitstr(($$Always0!$$Always1))) x

        write !,"# Testing expression: ($zbitstr(6,($$Always0!@iTRUE)))",!			; Testing op_fnzbitstr()
        set x=($zbitstr(6,($$Always0!@iTRUE)))
        if ($zbitstr(6,($$Always0!@iTRUE)))
        kill:($zbitstr(6,($$Always0!@iTRUE))) x

        write !,"# Testing expression: ($zextract(""abcd"",(1!$$Always0)))",!			; Testing op_fnzextract()
        set x=($zextract("abcd",(1!$$Always0)))
        if ($zextract("abcd",(1!$$Always0)))
        kill:($zextract("abcd",(1!$$Always0))) x

        write !,"# Testing expression: ($zextract(""abcd"",1,(0!$increment(zz))))",!		; Testing op_fnzextract()
        set x=($zextract("abcd",1,(0!$increment(zz))))
        if ($zextract("abcd",1,(0!$increment(zz))))
        kill:($zextract("abcd",1,(0!$increment(zz)))) x

        write !,"# Testing expression: ($zgetjpi((@iTRUE!$$Always0),""stime""))",!		; Testing op_fngetjpi()
        set x=($zgetjpi((@iTRUE!$$Always0),"stime"))
        if ($zgetjpi((@iTRUE!$$Always0),"stime"))
        kill:($zgetjpi((@iTRUE!$$Always0),"stime")) x

        write !,"# Testing expression: ($zpeek(""CSAREG:DEFAULT"",(0!$increment(zz)),10))",!	; Testing op_fnzpeek()
        set x=($zpeek("CSAREG:DEFAULT",(0!$increment(zz)),10))
        if ($zpeek("CSAREG:DEFAULT",(0!$increment(zz)),10))
        kill:($zpeek("CSAREG:DEFAULT",(0!$increment(zz)),10)) x

        write !,"# Testing expression: ($zpeek(""FHREG:DEFAULT"",0,(1!@iTRUE)))",!		; Testing op_fnzpeek()
        set x=($zpeek("FHREG:DEFAULT",0,(1!@iTRUE)))
        if ($zpeek("FHREG:DEFAULT",0,(1!@iTRUE)))
        kill:($zpeek("FHREG:DEFAULT",0,(1!@iTRUE))) x

        write !,"# Testing expression: ($zpiece(""abcd"",""b"",1,(1!@iFALSE)))",!		; Testing op_fnzp1()
        set x=($zpiece("abcd","b",1,(1!@iFALSE)))
        if ($zpiece("abcd","b",1,(1!@iFALSE)))
        kill:($zpiece("abcd","b",1,(1!@iFALSE))) x

        write !,"# Testing expression: ($zsigproc((TRUE!@iFALSE),0))",!				; Testing op_fnzsigproc()
        set x=($zsigproc((TRUE!@iFALSE),0))
        if ($zsigproc((TRUE!@iFALSE),0))
        kill:($zsigproc((TRUE!@iFALSE),0)) x

        write !,"# Testing expression: ($zsubstr(""abcd"",(0!$$Always1)))",!			; Testing op_fnzsubstr()
        set x=($zsubstr("abcd",(0!$$Always1)))
        if ($zsubstr("abcd",(0!$$Always1)))
        kill:($zsubstr("abcd",(0!$$Always1))) x

        write !,"# Testing expression: ($zsubstr(""abcd"",1,(1&$increment(zz))))",!		; Testing op_fnzsubstr()
        set x=($zsubstr("abcd",1,(1&$increment(zz))))
        if ($zsubstr("abcd",1,(1&$increment(zz))))
        kill:($zsubstr("abcd",1,(1&$increment(zz)))) x

	write !,"# Completed gtm9277 successfully!",!
	quit

;
; Extrinsic routines used by the expressions being tested
;
Always0()
	quit 0
Always1()
	quit 1
