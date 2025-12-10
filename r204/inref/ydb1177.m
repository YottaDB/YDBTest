;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T1 ;
	; See MR description at https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782
	kill ^x
	set y=0
	set ^x(y,1)=1
	set ^x(y,2)=2
	quit

T2 ;
	; See https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2900580851
	kill ^x
	for i=1:1:10 set ^x(i,1)=1,^x(i,2)=2
	write !
	quit

T3 ;
	; See naked8.m at https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2900585936
	kill ^x
	set a=1,^x(a,1)=2,a=3
	set ^x(a,1)=3
	zwrite ^x
	write !
	quit

T4 ;
	; See naked8a in https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2906212967
	kill ^x
	set a=1,b=2,^x(a,1)=2 merge a=b
	set ^x(a,1)=3
	zwrite ^x
	quit

T6 ;
	; See naked10.m at https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2900750298
	kill ^x
	zshow "*":^x(1,1)
	set ^x(1,2)=2
	zwrite ^x
	write !
	quit

T7 ;
	; See naked11 in https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2903391035
	kill ^x,^y
	set ^y(1)=1
	if $data(x) set x=$get(^x(2))
	set x=$get(^x(3))

	quit

T8 ;
	; See naked12 in https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2903524681
	kill ^x,^y
	set ^y(1,2)=1,x=1,^x(1,3)=1
	set x=$select(x:1,1:$incr(^x(1,2)))
	set x=^x(1,3)

	quit

T9 ;
	; See https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2925315026
	set $zpiece(^x(1),";",1)=$$FUNC^%DATE("10/20/80")
	write $get(^x(2))
	quit

T10 ;
	; See bullet list at https://gitlab.com/YottaDB/DB/YDB/-/issues/1177#todo-list
	set y=1
	set ^x(y,1)=1  write ^x(y,1)
	quit

T11     ;
	; See https://gitlab.com/YottaDB/DB/YDB/-/issues/1177#note_2964158415
	set $ztrap="GOTO errcont"
	set ^a(111)=1
	merge ^a(111,2)=^a(111)
	zwrite $reference
	zwrite ^a(111)
	zwrite $reference
	set x=^a(111,2)
	quit

errcont;
	zwrite $zstatus
	set ^errcnt=1
	set prog=$P($zstatus,",",2,2)
	set line=$P($P(prog,"+",2,2),"^",1,1)
	set line=line+1
	set newprog=$P(prog,"+",1)_"+"_line_"^"_$P(prog,"^",2,3)
	set newprog=$ZLEVEL_":"_newprog
	zgoto @newprog
