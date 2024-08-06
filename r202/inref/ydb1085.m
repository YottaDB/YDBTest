;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

hello	; entry point, print args ($zcmdline)
	;
	write " $ZCMDLINE"
	if $zcmdline="" write " is empty (disabled)",! quit
	write "=""",$zcmdline,""" (enabled)",!
	quit

xhalt	; entry point, perform a HALT command
	;
	set $etrap="goto nhalt"
	write " HALT...",!
halt	halt
nhalt	set st=$zstatus
	write " ...HALT failed: ",$piece(st,",",3,4),!
	quit

perm	; entry point, create right+GID permutations for
	; right, $zcommandline, halt, direct, dse
	; - if right is "none", don't permutate GIDs
	; - skip items with more than one invalid GIDs (index=3)
	;
	set gids(1)=$piece($zcmdline," ",1)
	set gids(2)=$piece($zcmdline," ",2)
	set gids(3)=$piece($zcmdline," ",3)
	;
	set rights(1)="none"
	set rights(2)="ro"
	set rights(3)="rw"
	;
	for iright=1:1:3 do
	.set right=rights(iright)
	.if right="none" write "none;",! quit
	.for icmd=1:1:3 do
	..set gcmd=gids(icmd)
	..for ihalt=1:1:3 do
	...set ghalt=gids(ihalt)
	...for idir=1:1:3 do
	....set gdir=gids(idir)
	....for idse=1:1:3 do
	.....set dse=gids(idse)
	.....;
	.....set count=0
	.....if icmd=3 set count=count+1
	.....if ihalt=3 set count=count+1
	.....if idir=3 set count=count+1
	.....if idse=3 set count=count+1
	.....if count>1 quit
	.....;
	.....write right,";"
	.....write "ZCMDLINE:",gcmd,";"
	.....write "HALT:",ghalt,";"
	.....write "DIRECT_MODE:",gdir,";"
	.....write "DSE:",dse,!
