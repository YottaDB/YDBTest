;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2013-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
recurlink

;
; Generate a sequence of test cases from template M files and the
; entryref commands listed under label comText.
;
begin
	New offset
	View "NOUNDEF"
	For offset=1:1 Quit:'$$commandTest(offset)
	Write "Tests complete.",!
	Quit

;
; Test command at comText offset
;
commandTest(offset)
	New comstr
	Set comstr=$Piece($Text(comText+offset),";",2)
	Quit:"skip"=comstr 1
	Quit:""=comstr 0
	ZWRite comstr
	Set %=$$genCodeFromTemplate(comstr)
	Quit 1

;
; Generate bar0.m and bar.m, both of which invoke ^bar (from bar.edit) for
; external entryrefs.
; Verify that non-recursive (bar0) and recursive (bar) cases behave comparably.
;
genCodeFromTemplate(comstr)
	New line,file1,file2,diff
	Set %=$$mfile2lv^mutil(.line,"template.m")
	Set %=$$replaceString^mutil(.line,"###REPLACE:ENTRYREF",comstr)

	Set file1="norecursive"_offset_".out"
	Set file2="recursive"_offset_".out"
	; Do normal, then Do recursive
	Do execTest(.line,"norecursive","bar0",file1),execTest(.line,"recursive","bar",file2)
	; now compare the files
	If $$mfile2lv^mutil(.line1,file1)
	If $$replaceString^mutil(.line1,"bar0","bar")	; so basertn is comparable
	If $$mfile2lv^mutil(.line2,file2)
	If $$diffFile^mutil(.diff,.line1,.line2) Do
	.	Write "FAIL",!
	.	ZWRite offset,comstr,diff
	Quit ""

;
; Write <basertn>.m; link and invoke <basertn>; save output to <outfile>
;
execTest(line,keyword,basertn,outfile)
	New mfile
	Set mfile=basertn_".m"
	;View "LINK":keyword
	Set %=$$lv2mfile^mutil(.line,mfile)
	ZCompile mfile
	ZLink basertn
	Open outfile:(NEWVERSION)
	Use outfile
	Do ^@basertn
	Close outfile
	Quit

;
; Command section
;
comText	;
	; Do foo^bar
	; Do foo^@"bar"
	; Do @"foo"^bar
	; Do @"foo"^@"bar"
	; Do @"foo^bar"
	; Xecute "Do foo^bar"
	; Do foo
	; Do foo(213)
	; Do @"foo(213)"
	; Set %=$$foo
	; Set %=$$foo^bar
	; Set %=$$foo(213)
	; Set %=$$foo^bar(213)
	; Set %=$$@"foo"
	;skip; Set %=$$@"foo^bar"	; not actually allowed by M standard
	; Set %=$$@"foo"(213)
	;skip; Set %=$$@"foo^bar"(213)	; not actually allowed by M standard
	; Set %=$$@"foo"^@"bar"(213)
	; Goto foo
	; Goto foo^bar
	; Goto @"foo"^bar
	; ZGoto $ZLevel:foo
	; ZGoto $ZLevel:foo^bar
	; Write $Text(+11),!
	; Write $Text(+0),!
	; Write $Text(+11^bar),!
	; Write $Text(+0^bar),!
	; Write $Text(+11^@"bar"),!
	; Write $Text(+0^@"bar"),!
	; ZPrint
	; ZPrint ^bar
	; ZPrint ^@"bar"
	; ZPrint @"^bar"
	; Xecute "ZPrint ^bar"
	;
	; Empty line above signals end of test cases
