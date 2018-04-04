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
; Perform "Set $PIECE(..)=value"
;
;	Parameter
;	  gvn		global variable to set.
;	  val		value to assign to the global variable.
;	  start		beginning piece to return.
;	  end		last piece to return.
;	  delim		string determining the piece "boundaries"
;
;	Return value
;	  1		success
;	  0		failure
;
setpiece(gvn,val,start,end,delim)
	new data,rval
	i $E(gvn,1,1)'="^" zm GTMERR("YDB-E-NOTGBL"):gvn
	s data=$$^get(gvn)
	s $P(data,delim,start,end)=val
	s rval=$$^set(gvn,data)
	q rval


