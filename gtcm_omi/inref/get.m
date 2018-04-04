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
; get-	get the value of a global variable from the GT.CM server
;
;	Parameter
;	  gvn		global variable to retrieve.
;
;	Return value
;	  value of global variable.
;
;	Error handling
;	  If the global variable is not found we raise the "%YDB-E-NOTGBL"
;	  error.  Unless the caller has an error handler this will
;	  result in termination of the program.
;
get(gvn)
	n ref,rsp,define,value
	i $E(gvn,1,1)'="^" zm GTMERR("YDB-E-NOTGBL"):gvn
	s ref=$$gvn2ref^cvt(gvn)
	do send^tcp(OpType("Get"),$$str2LS^cvt(ref))
	s rsp=$$receive^tcp()
	s response=$$ref2gvn^cvt(ref)
;    w "response = ",response,!
	i $l(rsp)=0 w "Get failed: TCP/IP I/O error",! b  do close^tcp q ""
	s define=$a(rsp)
	s value=$$LS2str^cvt($E(rsp,2,$l(rsp)))
	i Resp("Class")=1 Do
	. w "Get failed- ",Resp("Type"),": ",Error(Resp("Type")),!
	. i Resp("Fatal") Do
	. . do close^tcp,^connect(Server("ip"),Server("port"),Server("agent"),Server("pw"))
	. s value=""
	i define=0 k ref,rsp,define,value zm GTMERR("YDB-E-GVUNDEF"):gvn q ""
;	w "returned value = ",value,!
	q value


