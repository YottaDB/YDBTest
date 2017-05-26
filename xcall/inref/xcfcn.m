;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2013, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
xcfcn	; xcfcn - test external calls to value-returning functions
	new $estack
	do nogbls^incretrap
	Set incretrap("PRE")="write ""%""_$piece($zstatus,""%"",2),!"
	Set incretrap("NODISP")=1
	Set $etrap="do incretrap^incretrap"
	New longval,ulongval,intval,uintval,statval1,statval2,voidval
	Set longval=$&fcnlong()
	If '$Data(longval) Set longval="longval is undefined"
	Set ulongval=$&fcnulong()
	If '$Data(ulongval) Set ulongval="ulongval is undefined"
	Set intval=$&fcnint()
	If '$Data(intval) Set intval="intval is undefined"
	Set uintval=$&fcnuint()
	If '$Data(uintval) Set uintval="uintval is undefined"
	Set statval1=$&fcnstat1()		; should be 0 => success
	If '$Data(statval1) Set statval1="statval1 is undefined"
	Set statval2=$&fcnstat2()		; should be -1 => M error
	If '$Data(statval2) Set statval2="statval2 is undefined"
	Write "Value from fcnlong: """,longval,"""",!
	Write "Value from fcnulong: """,ulongval,"""",!
	Write "Value from fcnint: """,intval,"""",!
	Write "Value from fcnuint: """,uintval,"""",!
	Write "Value from fcnstat1: """,statval1,"""",!
	Write "Value from fcnstat2: """,statval2,"""",!
	Set $etrap=""
	Set voidval=$&void()			; voidval should be undefined
	;
	; We should have got an error while calling $&void() above and we should not come here.
	;
	If '$Data(voidval) Set voidval="voidval is undefined"
	Write "Value from void: """,voidval,"""",!
	Quit
