;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test that a glvn pool slot left unfilled by an error while an indirect reference is saved does not crash the
; process when the glvn pool later needs more space for subscripts [YDB#1319]
;
; Each entry point raises DIVZERO while it evaluates the subscript of an indirect reference to a(1/z) with z=0.
; Its $ETRAP handler runs before the frame of the failed reference ends, so the unfilled slot is still in the pool,
; and saves three indirect references with many subscripts in one SET, which needs more than the 64 subscripts the
; glvn pool starts with. Label znoop is the example in YDB#1319, and the others are variations of it.
;
ydb1319	;
	quit

znoop	; the example in YDB#1319 (routine ZNOOP), with its handler checking the outcome
	set z=0,$etrap="do znooph^ydb1319" set @"a(1/z)"=1
	quit

znooph	set s="1" for i=2:1:22 set s=s_",1"
	set (@("x("_s_")"),@("y("_s_")"),@("w("_s_")"))=1
	write $select(($ecode[",M9,")&(1=@("x("_s_")"))&(1=@("y("_s_")"))&(1=@("w("_s_")")):"PASS",1:"WRONG")
	write " : znoop : DIVZERO raised, then $ETRAP set x, y and w with 22 subscripts each",!
	set $ecode="" quit

zpre	; stage 1 with default settings, after freeing an I/O buffer that held 0x55 bytes ("U")
	; The glvn pool can get that memory, and then the count in its never-used slot is large without any
	; MALLOC_PERTURB_ setting. Whether it does depends on the build.
	new f set f="zpre.out"
	open f:newversion use f write $translate($justify("",65000)," ","U") close f:delete
	set z=0,$etrap="do zpreh^ydb1319" set @"a(1/z)"=1
	quit

zpreh	set s="1" for i=2:1:22 set s=s_",1"
	set (@("x("_s_")"),@("y("_s_")"),@("w("_s_")"))=1
	write $select(($ecode[",M9,")&(1=@("x("_s_")"))&(1=@("y("_s_")"))&(1=@("w("_s_")")):"PASS",1:"WRONG")
	write " : zpre : DIVZERO raised, then $ETRAP set x, y and w with 22 subscripts each",!
	set $ecode="" quit

setind	; SET @ref=...
	new z,ref
	set z=0,ref="a(1/z)"
	set $etrap="do grow^ydb1319(""setind"")"
	set @ref=1
	write "WRONG : setind : SET @ref=1 did not raise DIVZERO",!
	quit

ordind	; $ORDER(@ref,-1)
	new z,ref,y
	set z=0,ref="a(1/z)"
	set $etrap="do grow^ydb1319(""ordind"")"
	set y=$order(@ref,-1)
	write "WRONG : ordind : $ORDER(@ref,-1) did not raise DIVZERO",!
	quit

mrgind	; MERGE @ref=...
	new z,ref,b
	set z=0,ref="a(1/z)",b(1)=1
	set $etrap="do grow^ydb1319(""mrgind"")"
	merge @ref=b
	write "WRONG : mrgind : MERGE @ref=b did not raise DIVZERO",!
	quit

grow(how)	; $ETRAP handler: save three indirect references with 30 subscripts each in one SET
	new s,i,x,y,w,ok
	if $ecode'[",M9," write "WRONG : ",how," : expected DIVZERO, got $ECODE=",$ecode," $ZSTATUS=",$zstatus,! set $ecode="" quit
	set s="" for i=1:1:30 set s=s_","_i
	set s=$extract(s,2,$length(s))
	set x="x("_s_")",y="y("_s_")",w="w("_s_")"
	set (@x,@y,@w)=how
	set ok=(@x=how)&(@y=how)&(@w=how)
	write $select(ok:"PASS",1:"WRONG")," : ",how," : DIVZERO raised, then $ETRAP set x(1,...,30), y(1,...,30) and w(1,...,30)"
	write $select(ok:"",1:" but they do not all hold "_how),!
	set $ecode=""
	quit
