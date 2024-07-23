;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb777	;
	set null("")=1
	set null(0)=0
	set null(1)=0
	set null("a")=0
	set null($ZYSQLNULL)=0
	;
	write " do ^sstep",!
	set subs="" for  do  set subs=$order(null(subs))  quit:subs=""
	. for boolexpr="s=""""","""""=s","s'=""""","""""'=s" do
	. . for j=0:1:4 do
	. . . if j=0 set boolexpr="("_boolexpr_")"
	. . . else   set boolexpr="'"_boolexpr
	. . . for k=1:1:2 do
	. . . . write " set s=",$zwrite(subs)
	. . . . write " set actual=-1"
	. . . . if k=1 do
	. . . . . write " set:"_boolexpr_" actual=100"
	. . . . else  do
	. . . . .  write " set actual="_boolexpr
	. . . . write " zwrite actual",!
	write " quit",!!
	quit

