;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper program for the memleak2 test to ensure no memory leaks in recursive relink operations. The program takes as arguments the
; depth and breadth of recursion, and the number of modules to produce during recursive relink invocations.
memleak2
	; Get the configuration parameters.
        set depth=+$piece($zcmdline," ",1)
        set breadth=+$piece($zcmdline," ",2)
        set nx=$piece($zcmdline," ",3)

	; Create a routine for copying.
	set file="x0.m"
	open file:newversion
	use file
	for i=0:1 set line=$text(x+i) quit:(""=line)  write line,!
	close file

	; Create alternative versions.
        for i=1:1:nx do
        .	set file="x"_i_".m"
        .	if $&gtmposix.cp("x0.m",file,.errno)
        .	open file:append
        .	use file
        .	write $c(9)_"; this is version "_$translate($justify(i,3)," ","0")_" of x.m",!
        .	close file

	; Prepare the base version of the routine.
        set iteration=0
        view "LINK":"RECURSIVE"
        if $&gtmposix.cp("x0.m","x.m",.errno) write "copyFile(x0.m x.m)"
        zcompile "x.m"
        zrupdate "x.o"

	; Initialize lv nodes we will need so they aren't charged against us
	for i=1:1:iteration set usedstor(iteration)=-1 set:(1<iteration) diffstor(iteration)=-1

	; Purge the sources loaded until now.
	zgoto 0:loop

loop	; CAUTION: Falling into the loop.
        if ($increment(iteration)>5) zwr diffstor quit
        do ^x(iteration,nx,depth,breadth)
        set usedstor(iteration)=$zusedstor
	if (1<iteration) do
	.	set diffstor(iteration)=usedstor(iteration)-usedstor(iteration-1)
	.	write:(0<diffstor(iteration)) "TEST-E-FAIL, Memory usage increased from "_usedstor(iteration-1)_" to "_usedstor(iteration),!
        write "Iteration "_iteration_" : $zusedstor="_$zusedstor,!
        zgoto 0:loop
        quit

; The principal element of a recursive chain (copied into a stand-alone routine).
x(curi,maxi,depth,breadth)
        new newi,iters,errno
        quit:($zlevel>depth)
        for iters=1:1:breadth do
        .	set newi=curi+1
        .	set:(newi>maxi) newi=1
        .	if $&gtmposix.cp("x"_newi_".m","x.m",.errno)
        .	zcompile "x.m"
        .	zrupdate "x.o"
        .	do ^x(newi,maxi,depth,breadth)
        .	set curi=newi
        quit
