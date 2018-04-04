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
; Set a global variable
;
;	Parameter
;	  gvn		global variable to set.
;	  val		value to assign to the global variable
;
;	Return value
;	  1		success
;	  0		failure
;
set(gvn,val)
	new ref,rsp,rval
	i $E(gvn,1,1)'="^" zm GTMERR("YDB-E-NOTGBL"):gvn
	s ref=$$gvn2ref^cvt(gvn)
	s val=$$str2LS^cvt(val)
	do send^tcp(OpType("Set"),$C(0)_$$str2LS^cvt(ref)_val)
	s rsp=$$receive^tcp()
	s response=$$ref2gvn^cvt(ref)
;	w "response = ",response,!
	s rval=1
	i Resp("Class")=1 Do
	. w "Set failed- ",Resp("Type"),": ",Error(Resp("Type")),!
	. i Resp("Fatal") Do
	. . do close^tcp,^connect(Server("ip"),Server("port"),Server("agent"),Server("pw"))
	. s rval=0
	q rval


