;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
merge	;basic test for merge
	s ^a=1
	s ^a(1)=11
	s ^a(2)=12
	s ^a(1,1)=111
	s ^a(1,2)=112
	m ^["/a/b/c","sphere"]A=^a
	m ^b=^["/a/b/c","sphere"]A
	;zwr ^["/a/b/c","sphere"]A ;ZWR does not work with ext.ref.
	zwr ^b
	; if ^b was right, then ^[...]A must have been right
	q
