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
; Perform a $QUERY on a global variable
;
;	Parameter
;	  gvn		global variable to retrieve.
;
;	Return value
;	  result of $QUERY
;
query(gvn)
	new ref,rsp,value
	i $E(gvn,1,1)'="^" zm GTMERR("YDB-E-NOTGBL"):gvn
	s ref=$$gvn2ref^cvt(gvn)
	do send^tcp(OpType("Query"),$$str2LS^cvt(ref))
	s rsp=$$receive^tcp()
	i $l(rsp)=0 w "Query failed: TCP/IP I/O error",! do close^tcp q ""
	s value=$$LS2str^cvt(rsp)
	i Resp("Class")=1 Do
	. w "Query failed- ",Resp("Type"),": ",Error(Resp("Type")),!
	. i Resp("Fatal") Do
	. . do close^tcp,^connect(Server("ip"),Server("port"),Server("agent"),Server("pw"))
	. s value=""
	e  s value=$$ref2gvn^cvt(value)
	q value


