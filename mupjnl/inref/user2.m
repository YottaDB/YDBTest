;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2003-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
p2	;
	h 1
	Set unix=$ZVersion'["VMS"
	TS
	F i=1:1:5 S ^A(i)="AA"_i
	ZKILL ^A(4)
	TC
	F i=1:1:5 S ^B(i)="BA"_i
	ZKILL ^B(4)
	F i=1:1:5 S ^C(i)="CA"_i
	F i=1:1:5 S ^CCC(i)="CA2"_i
	F i=1:1:5 S ^BBB(i)="BA2"_i
	F i=1:1:5 S ^AAA(i)="AA2"_i
	K ^C(4)
	s fn="job2.pid"
	if unix s fil="fn"
	e  s fil="fn:(group=""RWED"":world=""RWED"")"
	o @fil
	u fn
	if unix w $J
	e  w $$FUNC^%DH($J,0),!,$ZGETJPI("","PRCNAM"),!
	c fn
	q
	h
