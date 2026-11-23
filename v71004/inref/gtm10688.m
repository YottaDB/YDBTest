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
gtm10688	;
	; Test that SET $ZTRAP and the EXCEPTION device parameter of OPEN and USE keep the right value when a
	; garbage collection of the stringpool happens while the value is validated (compiled).
	new x,e,f,before,after
	write "# Test 1 : SET $ZTRAP",!
	; Build the value at run time so that the value is in the stringpool (and not a literal in the routine)
	set x=$$pool("write ""ZTRAP invoked : "",$piece($zstatus,"","",3),! goto test2^gtm10688")
	set before=$$used(1)
	set $ztrap=x
	set after=$$used(0)
	do check("Garbage collection happened inside SET $ZTRAP",after<before)
	do check("$ZTRAP has the value that was set",$ztrap=x)
	write "# Divide by zero. Expect ZTRAP to be invoked with a DIVZERO error",!
	write 1/0
	write "FAIL : $ZTRAP was not invoked",!
test2	;
	set $ztrap=""
	write "# Test 2 : OPEN with the EXCEPTION device parameter",!
	set f="gtm10688.txt"
	open f:newversion  close f	; create an empty file
	set e=$$pool("use $principal write ""EXCEPTION invoked : "",$piece($zstatus,"","",3),! close f goto test3^gtm10688")
	set before=$$used(1)
	open f:(readonly:exception=e)
	set after=$$used(0)
	do check("Garbage collection happened inside OPEN",after<before)
	do check("EXCEPTION has the value that was set",$$exception(f,e))
	write "# Read from the empty file. Expect EXCEPTION to be invoked with an IOEOF error",!
	use f  read x
	use $principal
	write "FAIL : EXCEPTION was not invoked",!
test3	;
	write "# Test 3 : USE with the EXCEPTION device parameter",!
	open f:readonly
	set e=$$pool("use $principal write ""EXCEPTION invoked : "",$piece($zstatus,"","",3),! close f goto done^gtm10688")
	set before=$$used(1)
	use f:exception=e
	set after=$$used(0)
	use $principal
	do check("Garbage collection happened inside USE",after<before)
	do check("EXCEPTION has the value that was set",$$exception(f,e))
	write "# Read from the empty file. Expect EXCEPTION to be invoked with an IOEOF error",!
	use f  read x
	use $principal
	write "FAIL : EXCEPTION was not invoked",!
done	;
	quit

pool(str)	; return a copy of "str" that lives in the stringpool
	quit $piece(str_"|","|",1)

check(desc,ok)	;
	write desc," : ",$select(ok:"PASS",1:"FAIL"),!
	quit

exception(f,e)	; return 1 if ZSHOW "D" shows "e" as the EXCEPTION of device "f", else 0
	new dev,i,ret
	zshow "D":dev
	set ret=0,i=""
	for  set i=$order(dev("D",i)) quit:i=""  if $piece(dev("D",i)," ",1)=f,dev("D",i)[("EXCE="""_e_"""") set ret=1
	quit ret

used(fill)	; return the number of bytes in use in the stringpool. If "fill" is 1, first fill the stringpool with
	; garbage so that a garbage collection that happens after this call makes the returned number smaller.
	new i,junk
	if fill for i=1:1:50 set junk=$justify("",1000)
	quit $piece($view("SPSIZE"),",",2)
