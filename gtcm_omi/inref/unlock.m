;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
; Unlock a global variable
;
;
;	Parameter
;	  gvn		global variable to unlock.
;
;	Return value
;	  non-zero	successful
;	  0		unlock failed
;
unlock(gvn)
	new rval,ref,val,rsp
	s rval=1
	i $E(gvn,1,1)'="^" zm GTMERR("YDB-E-NOTGBL"):gvn q 0
	s ref=$$gvn2ref^cvt(gvn)
	s val=$$str2SS^cvt($J)
	do send^tcp(OpType("Unlock"),$$str2LS^cvt(ref)_val)
	s rsp=$$receive^tcp()
;	i $l(rsp)=0 w "Unlock failed: TCP/IP I/O error",! do close^tcp s rval=0 q 0
	i Resp("Class")=1 Do
	. w "Unlock failed- ",Resp("Type"),": ",Error(Resp("Type")),!
	. i Resp("Fatal") Do
	. . do close^tcp,^connect(Server("ip"),Server("port"),Server("agent"),Server("pw"))
	. s rval=0
	q rval


