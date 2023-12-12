;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GTM-9429 - Verify features such as $QLENGTH() and $QSUBSCRIPT() do tighter checking for canonic references
;
gtm9429
	set label=$zcmdline
	do:(""=label)
	. write !,"# GTM9429 - FAIL - missing table label argument",!
	. zhalt 1
	set endtag=" ; end"		; Note $text() turns tabs to spaces
	set label="testcases"_label
	for i=1:1 do  quit:tc=endtag
	. set tc=$text(@label+i)
	. quit:tc=endtag
	. set tc=$zpiece(tc," ",3,99)
	. write !,"# Test case ",i,": ",tc,!
	. do
	. . new $etrap
	. . set $etrap="set $ecode="""" zwrite $zstatus"
	. . set @("val="_tc)
	. . write "Output value: ",val,!
	quit

;
; List of testcases. Just list the $qlength or $qsubscript expr and the test takes care of the rest.
;
testcasesNonUTF8
	; $qlength("a(.)")
	; $qlength("a(-.)")
	; $qlength("a(1,-)")
	; $qlength("a($zchar(,1))")
	; $qsubscript("a(.)",1)
	; $qsubscript("a(-.)",1)
	; $qsubscript("a(1,-)",1)
	; $qsubscript("a($zch(,1))",1)
	; end

testcasesUTF8
	; $qlength("a($char(,6032))")
	; $qsubscript("a($c(,6032))",1)	; Note this test was mentioned at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/560#note_1607761611
	; end
