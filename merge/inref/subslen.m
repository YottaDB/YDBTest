;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2002, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
subslen;
lcl;
	NEW $ZTRAP
	SET $ZTRAP="GOTO errcont^errcont"
	s aaa(1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0)="30 subs in aaa"
	s aaa(1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,1)="34 subs in bbb"
	zshow "v"
	w !,"m bbb(1,2,3,4)=aaa",!
	m bbb(1,2,3,4)=aaa
	zshow "v"
	if $data(bbb)  w !,"subslen for local test FAILED",!
	else  w !,"subslen for local test PASSED",!
gbl;	NEW $ZTRAP
	SET $ZTRAP="GOTO errcont^errcont"
	s ^a($j(9,25),$j(9,25))="a_9_9"
	s ^a($j(8,25),$j(8,25))="a_8_8"
	s ^b($j(9,25),$j(9,25))="b_9_9"
	s ^b($j(8,25),$j(8,25))="b_9_8"
	s ^b($j(9,25))="b_925"
	s ^b($j(8,25))="b_825"
	ZWR ^a,^b
	w !,"MERGE ^a($j(""new"",25))=^b",!
	MERGE ^a($j("new",25))=^b
	ZWR ^a,^b
	Q
gtm7867	;
	NEW $ZTRAP
	SET $ZTRAP="GOTO errcont^errcont"
	set ^a(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18)=1
	; Test merge LCL=^GBL
	merge b(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18)=^a
	; Test merge ^GBL=^GBL
	merge ^b(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18)=^a
	merge ^c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18)=^a
	set a(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18)=1
	; Test merge LCL=LCL
	merge b(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18)=a
	; Test merge ^GBL=LCL
	merge ^b(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18)=a
	merge ^c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18)=a
	;
	quit
