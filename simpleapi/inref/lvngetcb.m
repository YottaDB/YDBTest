;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to test local variable fetching with or without subscripts via ydb_get_s() simple API interface
;
lvngetcb
	set GENVARCNT=3000						; Count of variables to generate
	set MAXSUBS=31
	write "lvngetcb: Generating ",GENVARCNT," variables",!
	do								; Vars NEWed/created in this block go away after
	. new vars,varname,varref,subcnt,subidx
	. for vars=1:1:GENVARCNT do
	. . set (varname,varref)=$$getvarname^lvnsetstress()		; Good name generator
	. . if ($random(10)) do						; 10% chance for no subscripts
	. . . ;
	. . . ; Generate some number of subscripts
	. . . ;
	. . . set subcnt=$random(MAXSUBS)+1				; Randomize subscript count
	. . . set varref=varref_"("
	. . . for subidx=1:1:subcnt do
	. . . . set:(1<subidx) varref=varref_","
	. . . . set varref=varref_$zwrite($$getsubs^lvnsetstress())
	. . . set varref=varref_")"
	. . set @varref=42
	. kill GENVARCNT,MAXSUBS					; Makes for clean zshow of locals
	write "lvngetcb: Variables generated - ZSHOWing them to internal array",!
	zshow "v":%lvvardump
	;
	; Now write the vars and values out to a file for later comparison. All vars from here on out start with "%"
	; to minimize interference with the varnames created above - some of those may start with % but most won't.
	;
	set %outfn="lvngetcb-M-extract.txt"
	write "lvngetcb: Variables generated - writing out to ",%outfn,!
	open %outfn:new
	use %outfn
	for %indx=1:1 set %line=$get(%lvvardump("V",%indx),"") quit:(""=%line)  write %line,!
	close %outfn
	write "lvngetcb: Variables written - driving external call for call-backs via ydb_get_s() in the simpleAPI",!
	;
	; Now drive external call that will call back in via ydb_get_s() to fetch these same vars/values
	; and will write its own file that we will compare afterwards.
	;
	do &lvngetcb
	write !,"lvngetcb: Complete",!
	quit
