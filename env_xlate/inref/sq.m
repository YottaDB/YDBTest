;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sq	;
t0	w ^["/a/b/c","sphere"]GBL
t1	d tsq("/a/b/c","emotehost","GBL")
t2	d tsq("/b/c","sphere","GBL")
t3	d tsq("a/a/b/c","sphere","GBL")
tg	d tsq("/a/b/c","sphere","GBL")
	d tsq("/a/b/c","sphere","GBL")
	q
tsq(a,b,c) ;
	s x="^["""_a_""","""_b_"""]"_c
	w x,"= ",!
	w @x,!

