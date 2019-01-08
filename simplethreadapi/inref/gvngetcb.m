;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2019 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to test global variable fetching with or without subscripts via ydb_get_st() simple API interface
;
gvngetcb
	set GENVARCNT=3000						; Count of variables to generate
	set MAXSUBS=10							; Keep within key size
	set $etrap="use $principal write ""Error occurred: "",!! zshow ""*"" quit"
	write "gvngetcb: Generating ",GENVARCNT," variables",!
	set mfile="gengvnget.m"
	open mfile:(newversion)
	use mfile
	do								; Vars NEWed/created in this block go away after
	. new vars,varname,varref,subcnt,subidx
	. for vars=1:1:GENVARCNT do
	. . set varref="^%Y"						; Avoid "^%Y*" named vars
	. . for  quit:("^%Y"'=$zextract(varref,1,3))  set varref="^"_$$getvarname^lvnsetstress()	; Good name generator
	. . if ($random(10)) do						; 10% chance for no subscripts
	. . . ;
	. . . ; Generate some number of subscripts
	. . . ;
	. . . set subcnt=$random(MAXSUBS)+1				; Randomize subscript count
	. . . set varref=varref_"("
	. . . for subidx=1:1:subcnt do
	. . . . set:(1<subidx) varref=varref_","
	. . . . set sub=""
	. . . . for  quit:(""'=sub)  set sub=$$getsubs^lvnsetstress()	; Spin till sub is non-NULL as not allowed
	. . . . set varref=varref_$zwrite(sub)
	. . . set varref=varref_")"
	. . write " set ",varref,"=",42,!
	. kill GENVARCNT,MAXSUBS					; Makes for clean zshow of locals
	close mfile
	do ^gengvnget
	;
	; Add one more record with the maximum subscripts for good measure
	;
	set ^MaNySuBs(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)=4242
	set %outfn="gvngetcb-M-extract.txt"
	write "gvngetcb: Variables generated - writing them to file ",%outfn,!
	zsystem "$gtm_dist/mupip extract -format=zwr "_%outfn_" >& mupip-extract-out.txt"
	write "gvngetcb: Variables written - driving external call for call-backs via ydb_get_st() in the SimpleThreadAPI",!
	;
	; Now drive external call that will call back in via ydb_get_st() to fetch these same vars/values
	; and will write its own file that we will compare afterwards.
	;
	do &gvngetcb
	write !,"gvngetcb: Complete",!
	quit
