;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
base	; base routine
	; invokes/references foo or foo^bar twice
	; on the second invocation, should access newer version of ^bar
	;
	Write "... base routine",!
	Write $Text(+0),!
	Write $Text(base+0),!
	ZSHow "S"
	Write "... linking bar from current directory",!
	ZLink "bar"
	Write "... first invocation",!
	;
	; reference foo or first version foo^bar
###REPLACE:ENTRYREF:1 ;; !!! insert entryref command here !!!
	Write "... change $zroutines; expect subsequent invocation to pick up new code"
	Set savezro=$ZROutines
	Set $ZROutines="./patch"
	Write "... second invocation",!
	;
	; reference foo or second version foo^bar
###REPLACE:ENTRYREF:2 ;; !!! insert entryref command here !!!
	Write "... back to base routine",!
	Write $Text(+0),!
	Write $Text(bar1+0),!
	ZSHow "S"
	Set $ZROutines=savezro
	Quit
	;
foo(x)	; base routine (foo)
	;
	Write "... base routine (foo)",!
	Write $Text(+0),!
	Write $Text(foo+0),!
	ZSHow "S"
	Quit:$Quit "" Quit
