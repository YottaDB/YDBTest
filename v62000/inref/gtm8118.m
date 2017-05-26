;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8118	;
	quit
test1	;
	; Test that Source server sends transactions in timely fashion when reading from journal files
	;
	; Fill up 6Mb of data in a.mjl and c.mjl
	; this assumes ^a maps to a.dat, ^b maps to b.dat, ^c maps to c.dat
	;
	for i=1:1:600    set (^a(i),^c(i))=$justify(i,10000)
	for i=1:1:100000 set (^b(i))=$justify(i,20)
	quit
test2a	;
	; Helper M program for Test 2 (see description of test in gtm8118.csh)
	for i=1:1:2000 s ^x(i)=$j(i,3800)
	quit
test2b	;
	set jmaxwait=0
	do ^job("test2bchild^gtm8118",1,"""""")
	quit
test2bchild ;
	; Helper M program for Test 2 (see description of test in gtm8118.csh
	hang $random(1600)/100	; Sleep randomly before switch (see gtm8118.csh under Test 2 for why this might help)
	for i=1:1:200 s ^x(i)=$j(i,3800)
	quit
test2bwait;
	do wait^job
	quit
