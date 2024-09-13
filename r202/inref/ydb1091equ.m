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

ydb1091equ	;
	set null("")=1
	set null(0)=0
	set null(1)=0
	set null("a")=0
	set null($ZYSQLNULL)=0
	;
	write " do ^sstep",!
	set subs1="" for  do  set subs1=$order(null(subs1))  quit:subs1=""
	. set subs2="" for  do  set subs2=$order(null(subs2))  quit:subs2=""
	. . for boolexpr="subs1=subs2","subs2=subs1","subs1'=subs2","subs2'=subs1" do
	. . . for j=0:1:4 do
	. . . . if j=0 set boolexpr="("_boolexpr_")"
	. . . . else   set boolexpr="'"_boolexpr
	. . . . for k=1:1:2 do
	. . . . . write " set subs1=",$zwrite(subs1),",subs2=",$zwrite(subs2)
	. . . . . write " set actual=-1"
	. . . . . if k=1 do
	. . . . . . write " set:"_boolexpr_" actual=100"
	. . . . . else  do
	. . . . . .  write " set actual="_boolexpr
	. . . . . write " zwrite actual",!
	write " quit",!!
	quit

