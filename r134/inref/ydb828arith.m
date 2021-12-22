;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb828arith; Test operands with NUMOFLOW errors do not cause %YDB-F-SIGINTDIV errors
	;
	; This test generates random arithmetic operations using randomly generated operands
	; that more often than not exceed the numeric range supported by YottaDB.
	; In this case, we expect a NUMOFLOW error (but we used to see %YDB-F-SIGINTDIV errors
	; and core files previously). Hence the error trap is set to ignore any errors other than
	; fatal errors which will generate core files and the test framework will catch that.
	;
	set oper($incr(oper))="+"
	set oper($incr(oper))="-"
	set oper($incr(oper))="*"
	set oper($incr(oper))="**"
	set oper($incr(oper))="/"
	set oper($incr(oper))="\"
	set oper($incr(oper))="#"
	; Run test for at least 5 seconds and 100 iterations
	for i=1:1:100  do
	. new num1,num2
	. set num1=$$gennumber
	. set num2=$$gennumber
	. set xstr="set x="_num1_oper($random(oper)+1)_num2
	. do execute(xstr)
	write "PASS",!
	quit

execute(xstr)
	new $etrap
	set $etrap="do etrap"
	xecute xstr
	quit

etrap	;
	; Only allow the following errors as expected. Any other error is unexpected and we halt the program in that case.
	;	%YDB-E-NUMOFLOW, Numeric overflow
	;	%YDB-E-DIVZERO, Attempt to divide by zero
	;	%YDB-E-NEGFRACPWR, Invalid operation: fractional power of negative number
	if ($zstatus["YDB-E-NUMOFLOW")!($zstatus["YDB-E-DIVZERO")!($zstatus["YDB-E-NEGFRACPWR") set $ecode=""
	else  zshow "*" halt
	quit

gennumber()	;
	new i
	set mantissalen=$random(60)+1
	set decimal=$random(2)
	if decimal set decimalposition=$random(mantissalen)+1
	set mantissa=""
	for i=1:1:mantissalen do
	. set:decimal&(i=decimalposition) mantissa=mantissa_"."
	. set mantissa=mantissa_$random(10)
	set sign=$random(3)
	set:sign=1 mantissa="-"_mantissa
	set:sign=2 mantissa="+"_mantissa
	set enotation=$random(2)
	if enotation do
	. set exponent=$random(200)-100
	. set mantissa=mantissa_"E"_exponent
	quit mantissa
