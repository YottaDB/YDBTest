;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	write "# -------------------------------------------------------------------------------",!
	write "# Test of https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1665#note_2438087704",!
	write "# -------------------------------------------------------------------------------",!
	write "# Run [write $zyco("" write 1"")] : Tests that $ZYCO() is accepted as function name",!
	write $zyco(" write 1"),!
	write "# Run [write $zycompile("" write 1"")] : Tests that $ZYCOMPILE() is accepted as function name",!
	write $zycompile(" write 1"),!
	write "# Run [write $zycompile("" do"")] : Tests that $ZYCOMPILE() is accepted as function name",!
	write $zycompile(" do"),!
	write "# Run [write $zycompile("" set $zwrtac="""""""""")] : Tests INVSVN error is returned and no assert fail",!
	write $zycompile(" set $zwrtac="""""),!
	write "# Run [write $zycompile("" set ($iv)=1"")] : Tests INVSVN error is returned and no assert fail",!
	write $zycompile(" set ($iv)=1"),!
	write "# Run [write $zycompile("" set $ztriggerop=1"")] : Tests INVSVN error is returned and no assert fail",!
	write $zycompile(" set $ztriggerop=1"),!
	write "# Run [write $zycompile("" zwrite $zfoobar"")] : Tests INVSVN error is returned and no assert fail",!
	write $zycompile(" zwrite $zfoobar"),!
	write "# Run [write $zycompile("" new $ztimeout"")] : Tests SVNONEW error is returned and no assert fail",!
	write $zycompile(" new $ztimeout"),!
	write "# Run [write (0!((-(+(-(""1E47""))))))] : Tests NUMOFLOW error is returned and no assert fail",!
	write $zycompile(" write (0!((-(+(-(""1E47""))))))"),!

	write "# -------------------------------------------------------------------------------",!
	write "# Test of https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1665#note_2438180472",!
	write "# -------------------------------------------------------------------------------",!
	write "# Run [write $zycompile("" d label zwrite $zfoobar"")] : Tests INVSVN error is returned, not empty string",!
	write $zycompile(" d label zwrite $zfoobar")

	write "# -------------------------------------------------------------------------------",!
	write "# Test of https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1665#note_2438257063",!
	write "# -------------------------------------------------------------------------------",!
	write "# Run [write $zycompile("" d label"")] : Tests empty string is returned, not a LABELMISSING error",!
	write $zycompile(" d label")

	write "# -------------------------------------------------------------------------------",!
	write "# Test that any substring other than $ZYCO or $ZYCOMPILE issues an error",!
	write "# -------------------------------------------------------------------------------",!
	set $etrap="set $ecode="""" do incrtrap^incrtrap"	; needed to transfer control to next M line after error in "xecute" command
	for cmd="zycom","zycomp","zycompi","zycompil","zycompiler" do
	. set xstr="write $"_cmd_"("" write 1"")"
	. write "# Run [",xstr,"] : Tests INVFCN error is returned",!
	. xecute xstr
	quit

