;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2002, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
errors;
	NEW $ZTRAP
	SET $ZTRAP="GOTO errcont^errcont",abc(5)=1
	MERGE abc=abc(1,"aa",12.34,99910)
	MERGE abc(1,"aa",12.34,99910)=abc
	MERGE def(1,"aa",12.34,99910)=abc
	MERGE abc(1,"aa",12.34,99910)=def
	MERGE abc(1,"aa",12.34,99910)=def(99,"ZZ",123456789,9.0909)
	MERGE def(99,"ZZ",123456789,9.0909)=abc(99,"ZZ",123456789,9.0909)
	MERGE abc(99,"ZZ",123456789,9.0909)=abc(99,"ZZ",123456789,9.0909)
	set abc("aaa","bbb","ccc")=1
	set abc("aaa","bbb","ccc","ddd")=1
	M abc("aaa","bbb","ccc","ddd")=abc("aaa","bbb","ccc")
	M abc("aaa","bbb")=abc("aaa","bbb","ccc")
	M ^abc("aaa","bbb","ccc","ddd")=^abc("aaa","bbb","ccc")
	M ^abc("aaa","bbb")=^abc("aaa","bbb","ccc")
	M abc("aaa","bbb","ccc","ddd")=^abc("aaa","bbb","ccc")
	M abc("aaa","bbb")=^abc("aaa","bbb","ccc")
	M ^abc("aaa","bbb","ccc","ddd")=abc("aaa","bbb","ccc")
	M ^abc("aaa","bbb")=abc("aaa","bbb","ccc")
lab1;
	M a(111)=a(111,222)
	M b(111,222)=b(111)
	M ^a(111)=^a(111,222)
	M ^b(111,222)=^b(111)
	M a(111)=^a(111,222)
	M b(111,222)=^b(111)
	M ^a(111)=a(111,222)
	M ^b(111,222)=b(111)
lab2;
	S a(111)="vala"
	M a(111)=a(111,222)
	ZWR a
	M a(111,222)=a(111)
	ZWR a
	S ^a(111)="vala"
	M ^a(111)=^a(111,222)
	M ^a(111,222)=^a(111)
	ZWR ^a
lab3;
	M ^a(111222)=^a(111)
	M ^a(111222)=^a(111)
	M ^a(111,0,22222)=^a(111)
	M ^a(1110,22222)=^a(111)
	M ^a(111,22222)=^a(111,222)
	;
	M ^b(111)=^a(111222)
	M ^b(111)=^a(111222)
	M ^b(111)=^a(111,22222)
	M ^b(111,222)=^a(111,22222)
	M ^bb=^b
	ZWR ^a,^b,^bb
lab4;
	K (a)
	M a(111222)=a(111)
	M a(111222)=a(111)
	M a(111,0,22222)=a(111)
	M a(1110,22222)=a(111)
	M a(111,22222)=a(111,222)
	;
	M b(111)=a(111222)
	M b(111)=a(111222)
	M b(111)=a(111,22222)
	M b(111,222)=a(111,22222)
	M bb=b
	ZWR a,b,bb
	Q
