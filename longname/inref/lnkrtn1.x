;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
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
lnkrtn;
	w "in lnkrtn1",!
	quit
entry1;
	w "in entry1^lnkrtn1",!
	set data1("digits")="0123456789"
	set data1("alpha")="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	set data1("wspace")="!@#$%^&*(){}[]|\,./<>?`~;:"
	set data1("special")=$C(0,1,2,3,4,5,6,7,8,9,128,129,255)
	set data1("mixed")=data1("alpha")_data1("wspace")_data1("special")
	set data1("percent")="%"_data1("alpha")
	set data1("numeric")=123456789
	set data1("float")=123456789.123456789
	if cnt=1 set data1("cnt3")="This is literal number 3"
	if cnt=2 set x="data1(""cnt4"")" set @x="This is literal number 4"
	quit
entry2;
	w "in entry2^lnkrtn1",!
	set newdata1(data1("digits"))="digits"
	set newdata1(data1("alpha"))="alpha"
	set newdata1(data1("wspace"))="wspace"
	set newdata1(data1("special"))="special"
	set newdata1(data1("mixed"))="mixed"
	set newdata1(data1("percent"))="percent"
	set newdata1(data1("numeric"))="numeric"
	set newdata1(data1("float"))="float"
	quit
entry3;
	w "in entry3^lnkrtn1",!
	merge mrgdata1=data1
	quit
entry4;
	w "in entry4^lnkrtn1",!
	do entry4^lnkrtn0
	quit
entry5;
	w "in entry5^lnkrtn1",!
	merge lnkrtn2Tolnkrtn1Merge0=data2
	quit
squaresub(num)
	set num=num*num
	quit
squarefn(num)
	quit num*num
litfn()
	new lit
	set lit="This is cnt "_cnt
	quit lit
