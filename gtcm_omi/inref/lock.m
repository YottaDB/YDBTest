;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Lock a global variable
;
; If a lock has already been taken out this routine retries
; indefinitely, once per second.
;
;	Parameter
;	  gvn		global variable to lock.
;
;	Return value
;	  non-zero	lock granted.
;	  0		lock not granted.
;
lock(gvn)
	n ref,val,msg,granted,rsp
	i $E(gvn,1,1)'="^" zm GTMERR("YDB-E-NOTGBL"):gvn
	s ref=$$gvn2ref^cvt(gvn)
	s val=$$str2SS^cvt($J)
	s msg=$$str2LS^cvt(ref)_val
	For  Do  q:granted'=0
	. do send^tcp(OpType("Lock"),msg)
	. s rsp=$$receive^tcp()
	. s granted=$a(rsp)
	. i $l(rsp)=0 w "Lock failed: TCP/IP I/O error",! do close^tcp b  q
	. i Resp("Class")=1 Do
	. . w "Lock failed- ",Resp("Type"),": ",Error(Resp("Type")),!
	. . i Resp("Fatal") do close^tcp s granted=0 b
	. i granted=0 h 1
	q granted


