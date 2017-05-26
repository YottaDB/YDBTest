; This script is used by GTM6813 subtest and tests various DO invocations of routines
; with fall-thru/non-fall-thru header labels.
dofallthrus
	set $etrap=""
	set $ztrap="goto incrtrap^incrtrap"
	set incrtrapNODISP=1
	set incrtrapPOST="write ""FAIL: "",$$^error(savestat),!"

	; calling without a label

	do doline
	write "Calling do ^foo(0,1):",!,"    foo",!,"        ;",!,"    label(x,y)",!
	do ^routine1(0,1)

	do doline
	write "Calling do ^foo(0,1):",!,"    foo",!,"    label(x,y)",!
	do ^routine2(0,1)

	do doline
	write "Calling do ^foo(0,1):",!,"    foo",!,"        set x=1",!,"    label(x,y)",!
	do ^routine3(0,1)

	do doline
	write "Calling do ^foo(0,1):",!,"    foo",!,"        quit",!,"    label(x,y)",!
	do ^routine4(0,1)

	do doline
	write "Calling do ^foo(0,1):",!,"    foo()",!,"        quit",!,"    label(x,y)",!
	do ^routine5(0,1)

	do doline
	write "Calling do ^foo(0,1):",!,"    f",!,"        ;",!,"    label(x,y)",!
	do ^routine6(0,1)

	do doline
	write "Calling do ^foo(0,1):",!,"    f",!,"    label(x,y)",!
	do ^routine7(0,1)

	do doline
	write "Calling do ^foo(0,1):",!,"    f",!,"        set x=1",!,"    label(x,y)",!
	do ^routine8(0,1)

	do doline
	write "Calling do ^foo(0,1):",!,"    f",!,"        quit",!,"    label(x,y)",!
	do ^routine9(0,1)

	do doline
	write "Calling do ^foo(0,1):",!,"    f()",!,"        quit",!,"    label(x,y)",!
	do ^routine10(0,1)

	; calling with a label

	do doline
	write "Calling do foo^foo(0,1):",!,"    foo",!,"        ;",!,"    label(x,y)",!
	do routine1^routine1(0,1)

	do doline
	write "Calling do foo^foo(0,1):",!,"    foo",!,"    label(x,y)",!
	do routine2^routine2(0,1)

	do doline
	write "Calling do foo^foo(0,1):",!,"    foo",!,"        set x=1",!,"    label(x,y)",!
	do routine3^routine3(0,1)

	do doline
	write "Calling do foo^foo(0,1):",!,"    foo",!,"        quit",!,"    label(x,y)",!
	do routine4^routine4(0,1)

	do doline
	write "Calling do foo^foo(0,1):",!,"    foo()",!,"        quit",!,"    label(x,y)",!
	do routine5^routine5(0,1)

	do doline
	write "Calling do f^foo(0,1):",!,"    f",!,"        ;",!,"    label(x,y)",!
	do rtn6^routine6(0,1)

	do doline
	write "Calling do f^foo(0,1):",!,"    f",!,"    label(x,y)",!
	do rtn7^routine7(0,1)

	do doline
	write "Calling do f^foo(0,1):",!,"    f",!,"        set x=1",!,"    label(x,y)",!
	do rtn8^routine8(0,1)

	do doline
	write "Calling do f^foo(0,1):",!,"    f",!,"        quit",!,"    label(x,y)",!
	do rtn9^routine9(0,1)

	do doline
	write "Calling do f^foo(0,1):",!,"    f()",!,"        quit",!,"    label(x,y)",!
	do rtn10^routine10(0,1)
	quit

doline
	write !,"---------------------------------------------------------------------------------------------------",!,!
	quit

etrap
	write "FAIL: ",$$error^error($zstatus),!
	set $ecode=""
	quit
