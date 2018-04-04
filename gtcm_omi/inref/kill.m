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
; Kill a global variable
;
;	Parameter
;	  gvn		global variable to unlock.
;
;	Return value
;	  non-zero	successful
;	  0		unlock failed
;
kill(gvn)
	n ref,rval,rsp
	i $E(gvn,1,1)'="^" zm GTMERR("YDB-E-NOTGBL"):gvn
	s ref=$$gvn2ref^cvt(gvn)
	s rval=1
	do send^tcp(OpType("Kill"),$C(0)_$$str2LS^cvt(ref))
	s rsp=$$receive^tcp()
	s response=$$ref2gvn^cvt(ref)
;	w "response = ",response,!
	i Resp("Class")=1 Do
	. w "Kill failed- ",Resp("Type"),": ",Error(Resp("Type")),!
	. i Resp("Fatal") Do
	. . do close^tcp,^connect(Server("ip"),Server("port"),Server("agent"),Server("pw"))
	. s rval=0
	q rval


