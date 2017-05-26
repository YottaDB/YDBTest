;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; General procedure:
; 	To verify that a new version is being invoked, we compare output with code that explicitly calls a *different* routine.
; Simple example:
; 	Suppose we want to verify that "Do ^rtn Do ^rtn" invokes version 1, then version 2 of ^rtn. Well, we compare with the
;	output of "Do ^rtn1 Do ^rtn2", where ^rtn1 is (nearly) identical to version 1 and ^rtn2 (nearly) identical to version 2.
;
; Subtest must supply the following:
; 1. template file, which invokes or references routines ^bar/^bar1/^bar2
; 2. version 1 ^bar ~ ^bar1
; 3. version 2 ^bar ~ ^bar2
; * All files must have a "foo" label. We'll be referencing either "foo" or "foo^bar".
; * The template file should make two references, and between them should do something (e.g. ZLINK, ZRUPDATE) to make sure
; version 2 is invoked upon the second reference.
;
;			new behavior	comparison
;
; setzroutines.csh subtest
;			autorelink	auto-ZLINK
;			-		-
; template file:	base.m
; version 1:		bar.m
; version 2:		bar.edit	(alt name bar2.edit)
;
; recursive.csh subtest
;			recursive	nonrecursive
;			-		-
; template file:	bar.m		(alt name bar0.m)
; version 2:		bar.edit
;

;
; Test command at comText offset
;
commandTest(offset,template,base,ref1,ref2)
	New comstr
	Set comstr=$Piece($Text(comText+offset),";",2)
	Quit:"skip"=comstr 1
	Quit:""=comstr 0
	ZWRite comstr
	Set %=$$genCodeFromTemplate(comstr,template,base,ref1,ref2)
	Quit 1

;
; Generate bar0.m and bar.m, both of which invoke ^bar (from bar.edit) for
; external entryrefs.
; Verify that non-recursive (bar0) and recursive (bar) cases behave comparably.
;
; Fill in template with comstr, ref1, and ref2 (if applicable) to form base.m
; Compare two different cases: one by taking the first colon-separated parts of base, ref1, and ref2;
; 	one by taking the second parts.
;
genCodeFromTemplate(comstr,template,base,ref1,ref2)
	New line,file1,file2,diff,base1,base2
	Set %=$$mfile2lv^mutil(.line,template)
	Set %=$$replaceString^mutil(.line,"###REPLACE:ENTRYREF",comstr)

	Set file1="cmp"_offset_".out"
	Set file2="newbehavior"_offset_".out"
	Set base1=$Piece(base,":",1)
	Set base2=$Piece(base,":",2)

	Set ref1a=$Piece(ref1,":",1)
	Set ref1b=$Piece(ref1,":",2)
	Set ref2a=$Piece(ref2,":",1)
	Set ref2b=$Piece(ref2,":",2)
	; replace "bar" with "bar1" or "bar2"
	Set comstr1a=$$replaceStr(comstr,"bar",ref1a)
	Set comstr1b=$$replaceStr(comstr,"bar",ref1b)
	Set comstr2a=$$replaceStr(comstr,"bar",ref2a)
	Set comstr2b=$$replaceStr(comstr,"bar",ref2b)

	; Do normal, then Do new behavior (e.g. recursive)
	Do execTest(.line,template,base1,file1,comstr1a,comstr2a),execTest(.line,template,base2,file2,comstr1b,comstr2b)
	; now compare the files
	If $$mfile2lv^mutil(.line1,file1)
	;If $$replaceString^mutil(.line1,"bar0","bar")	; so basertn is comparable
	;If $$replaceString^mutil(.line1,base1,base2)
	;If $$replaceString^mutil(.line1,ref1a,ref1b)
	;If $$replaceString^mutil(.line1,ref2a,ref2b)
	If $$mfile2lv^mutil(.line2,file2)

	; Before we take the diff, replace labels in second to match first
	If $$replaceString^mutil(.line1,base2,base1)
	If $$replaceString^mutil(.line2,ref1b,ref1a)
	If $$replaceString^mutil(.line2,ref2b,ref2a)

	If $$diffFile^mutil(.diff,.line1,.line2) Do
	.	Write "FAIL",!
	.	ZWRite offset,comstr,diff
	.	zsy "ls -l" halt
	Quit ""

;
; Write <basertn>.m; link and invoke <basertn>; save output to <outfile>
;
execTest(line,template,basertn,outfile,comstr1,comstr2)
	New mfile
	Set mfile=basertn_".m"
	Set %=$$mfile2lv^mutil(.line,template)
	Set %=$$replaceString^mutil(.line,"###REPLACE:ENTRYREF:1",comstr1)
	Set %=$$replaceString^mutil(.line,"###REPLACE:ENTRYREF:2",comstr2)
	Set %=$$lv2mfile^mutil(.line,mfile)
	ZCompile mfile
	ZLink basertn
	Open outfile:(NEWVERSION)
	Use outfile
	Do ^@basertn
	Close outfile
	Quit
;
; Find <old> substring in comstr and replace with <new>
; <old> may occur zero or one times
;
replaceStr(comstr,old,new)
	New p
	Set p(1)=$Piece(comstr,old,1)
	Set p(2)=$Piece(comstr,old,2)
	Quit:p(1)_p(2)=comstr comstr
	Quit p(1)_new_p(2)

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
	; Set %=$$@"foo"(213)
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
