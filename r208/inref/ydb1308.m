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
; Test an indirect reference compiled after an earlier indirect reference with a nested indirection, with
; gtm_side_effects set to 1, is compiled as it would be without that earlier one [YDB#1308]
;
; z is undefined, so $DATA(z(p,n)) is 0 even though the subscript variable p is undefined: the subscripts are
; not evaluated as the base variable does not exist. Label short runs the example in YDB#1308. The other labels
; are variations of it, which check $DATA(@ref) with ref="z(p,n)", after the earlier reference named by the label.
;
ydb1308	;
	quit

nofirst	; no earlier reference
	do check("nofirst","")
	quit

nested	; an earlier x(@y) whose nested indirection @y succeeds
	new a set a=1
	do check("nested","x(@y)")
	quit

nestederr	; an earlier x(@y) whose nested indirection @y issues LVUNDEF (the case in YDB#1308)
	do check("nestederr","x(@y)")
	quit

nested2	; an earlier x(1,@y) whose nested indirection @y succeeds
	new a set a=1
	do check("nested2","x(1,@y)")
	quit

plain	; an earlier x(a) without a nested indirection
	new a set a=1
	do check("plain","x(a)")
	quit

short	; the example in YDB#1308, with the two $DATA() values joined:
	;	set y="y" write $data(@"x(@y)"),$data(@"z(p,1)"),!
	new y,v,err
	do shtry
	write $select((""=err)&("00"=v):"PASS",1:"WRONG")," : short : $data(@""x(@y)"")_$data(@""z(p,1)"") with y=""y"" : "
	write $select(""'=err:err,1:v)," (expected 00)",!
	quit

shtry	; $ETRAP is set before the first reference, since setting it compiles its code, which would clear the
	; state that the first reference leaves in the compiler
	new $etrap set err="",v=""
	set $etrap="set err=$piece($zstatus,"","",3),$ecode="""" quit"
	set y="y",v=$data(@"x(@y)")_$data(@"z(p,1)")
	quit

check(what,first)
	new ref,y,n,v,err
	set y="a",n=1
	if ""'=first set ref=first do try write "# ",what," : $data(@ref) with ref=",ref," : ",$select(""'=err:"an error",1:v),!
	set ref="z(p,n)" do try
	write $select((""=err)&(0=v):"PASS",1:"WRONG")," : ",what," : $data(@ref) with ref=",ref," : "
	write $select(""'=err:err,1:v)," (expected 0)",!
	quit

try	new $etrap set err="",v=""
	set $etrap="set err=$piece($zstatus,"","",3),$ecode="""" quit"
	set v=$data(@ref)
	quit
