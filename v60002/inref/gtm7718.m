;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2013, 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7718	;
	write "Begin HANG accuracy test",!
	for denom=3,4,100,1000,10000 for num=1:1:10 do
	.	write "Maybe start an io flush timer. I better not cause HANG to finish prematurely.",!
	.	; HANG rounds the argument to the nearest 1ms
	.	set desired=(num/denom)*1000000\1000/1000
	.	set actual=$$timedhang(desired)
	.	zwrite desired,actual
	.	if (actual<desired)&(desired'<.001) write "FAIL : HANG finished prematurely : See gtm7718.expected",!
	write "Test complete",!
	quit

timedhang(x)
	new errno,tvsec1,tvusec1,tvsec2,tvusec2,a,b
	if $&ydbposix.gettimeofday(.tvsec1,.tvusec1,.errno)
	hang x
	if $&ydbposix.gettimeofday(.tvsec2,.tvusec2,.errno)
	set a=tvsec1+(tvusec1*1E-6)
	set b=tvsec2+(tvusec2*1E-6)
	quit b-a
