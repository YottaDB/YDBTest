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

set	; Test of Set command - may be incomplete
;	File modified by Hallgarth on 15-APR-1986 14:54:22.96
;	File modified by Hallgarth on 15-APR-1986 14:50:08.31
	New
	New $ZTRAP

	k
	s x=1
	s x="test"
	s z=2,w=0,x=23
	s:z>w x=2
	w x,!
	s ^ax(1,1)="test"
	w ^ax(1,1),!
	s ^ax(1,2)="^ax(1,1)"
	w @^ax(1,2),!
	s ^r(1,2)=@^ax(1,2)
	w ^r(1,2),!
	s $x=23,y=3 w $j($x,4),$j(y,4),!
	s $y=12 w $y,!
	zwrite
	s $ztrap="do t"
