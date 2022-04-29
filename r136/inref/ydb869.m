;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test boolean expressions involving huge numeric literals issue NUMOFLOW error (and not SIG-11)
;
ydb869
	write "## Tests that use Unary ' operator (OC_COM) : Complement operation",!
	write x='"1E47"
	write 0='"1E47"
	set x=(1!$s($$^truZQUIT='"1E47":0,1:1))
	set (z,$iv)=(1!$s($$^truZQUIT='"1E47":"ok",1:1))
	if i>1,$zbitfind(b2,'+"1E47"=i w !,"oops"
	write '+"1E47"=1
	;
	write "## Tests that use Unary + operator (OC_FORCENUM)",!
	write x=+"1E47"
	write 0=+"1E47"
	set x=(1!$s($$^truZQUIT=+"1E47":0,1:1))
	set (z,$iv)=(1!$s($$^truZQUIT=+"1E47":"ok",1:1))
	if i>1,$zbitfind(b2,+"1E47"=i w !,"oops"
	write +"1E47"=1
	;
	write "## Tests that use Unary - operator (OC_NEG)",!
	write x=-"1E47"
	write 0=-"1E47"
	set x=(1!$s($$^truZQUIT=-"1E47":0,1:1))
	set (z,$iv)=(1!$s($$^truZQUIT=-"1E47":"ok",1:1))
	if i>1,$zbitfind(b2,-"1E47"=i w !,"oops"
	write -"1E47"=1
	quit

