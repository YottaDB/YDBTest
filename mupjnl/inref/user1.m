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
p1	;
	h 1
	Set unix=$ZVersion'["VMS"
	s ^A=1,^VB=2,^C=3,^XA=1,^YAY=1
	s ^A(1,"str")="some string"
	s ^A(1,"str2")="some string2"
	s ^A(2,"str")="some other string"
	s (^A(1,1,1),^A(1,2,3),^A(1,1,3))=1
	F i=1:1:5 S ^A(i)="A"_i
	F i=1:1:5 S ^B(i)="B"_i
	TS
	F i=1:1:5 S ^C(i)="C"_i
	TC
	F i=1:1:5 S ^CC(i)="C2"_i
	F i=1:1:5 S ^BB(i)="B2"_i
	F i=1:1:5 S ^AA(i)="A2"_i
	s fn="job1.pid"
	o fn
	u fn
	if unix w $J
	e  w $$FUNC^%DH($J,0),!,$ZGETJPI("","PRCNAM"),!
	c fn
	q
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
p3	;
	Set unix=$ZVersion'["VMS"
	K ^AA(5)
	S ^AA(5)="changed"
	; ensure that at least one second passes so that the buffers will be flushed, and
	; the epoch timer will be started (so that there is a deterministic number of epochs, i.e. end of data
	; at every run:
	VIEW "EPOCH"
	s fn="job3.pid"
	o fn
	u fn
	if unix w $J
	e  w $$FUNC^%DH($J,0),!,$ZGETJPI("","PRCNAM"),!
	c fn
	q
