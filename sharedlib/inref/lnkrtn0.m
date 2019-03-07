;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lnkrtn;
	w "in lnkrtn0",!
	quit
entry1;
	w "in entry1^lnkrtn0",!
	set data0("digits")="0123456789"
	set data0("alpha")="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	set data0("wspace")="!@#$%^&*(){}[]|\,./<>?`~;:"
	set data0("special")=$C(0,1,2,3,4,5,6,7,8,9,128,129,255)
	set data0("mixed")=data0("alpha")_data0("wspace")_data0("special")
	set data0("percent")="%"_data0("alpha")
	set data0("numeric")=123456789
	set data0("float")=123456789.123456789
	if cnt=1 set data0("cnt1")="This is literal number 1"
	if cnt=2 set x="data0(""cnt2"")" set @x="This is literal number 2"
	quit
entry2;
	w "in entry2^lnkrtn0",!
	set newdata0(data0("digits"))="digits"
	set newdata0(data0("alpha"))="alpha"
	set newdata0(data0("wspace"))="wspace"
	set newdata0(data0("special"))="special"
	set newdata0(data0("mixed"))="mixed"
	set newdata0(data0("percent"))="percent"
	set newdata0(data0("numeric"))="numeric"
	set newdata0(data0("float"))="float"
	quit
entry3;
	w "in entry3^lnkrtn0",!
	merge mrgdata0=data0
	quit
entry4;
	w "in entry4^lnkrtn0",!
	do entry3^lnkrtn
	quit
	;
entry5;
	w "in entry5^lnkrtn0",!
	merge lnkrtn1Tolnkrtn0Merge0=data1
	quit
verifyall;
	;
	new $ZT
	set $ZT="set $ZT="""" g error"
	;
	set digits="0123456789"
	set alpha="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	set wspace="!@#$%^&*(){}[]|\,./<>?`~;:"
	set special=$C(0,1,2,3,4,5,6,7,8,9,128,129,255)
	set mixed=alpha_wspace_special
	set percent="%"_alpha
	set numeric=123456789
	set float=123456789.123456789
	;
	set maxerr=10
	set errcnt=0
	set cnt=0
	for datastr="data","mrgdata","lnkrtn2Tolnkrtn1Merge","lnkrtn1Tolnkrtn2Merge","lnkrtn1Tolnkrtn0Merge" do
	. do exam(datastr_cnt_"(""digits"")",digits)
	. do exam(datastr_cnt_"(""alpha"")",alpha)
	. do exam(datastr_cnt_"(""wspace"")",wspace)
	. do exam(datastr_cnt_"(""special"")",special)
	. do exam(datastr_cnt_"(""mixed"")",mixed)
	. do exam(datastr_cnt_"(""percent"")",percent)
	. do exam(datastr_cnt_"(""numeric"")",numeric)
	. do exam(datastr_cnt_"(""float"")",float)
	;
	do exam("data0(""cnt1"")","This is literal number 1")
	do exam("data0(""cnt2"")","This is literal number 2")
	do exam("data1(""cnt3"")","This is literal number 3")
	do exam("data1(""cnt4"")","This is literal number 4")
	do exam("data2(""cnt5"")","This is literal number 5")
	do exam("data2(""cnt6"")","This is literal number 6")
	;
	for ndx=1:1:max do
	. do exam("squaresubArray("_ndx_")",ndx*ndx)
	. do exam("squarefnArray("_ndx_")",ndx*ndx)
	. do exam("litfnArray("_ndx_")","This is cnt "_ndx)
	. set halfnum=ndx\2  do exam("halfArray("_ndx_")","half of "_ndx_" is "_halfnum)
	for lineno=begline:1:maxline  do
	. if $get(zblnkrtn(lineno))<1 write "Verify Fail for zblnkrtn",!
	. if $get(zblnkrtn0(lineno))<1 write "Verify Fail for zblnkrtn0",!
	do examnew(digits,"digits")
	do examnew(alpha,"alpha")
	do examnew(wspace,"wspace")
	do examnew(special,"special")
	do examnew(mixed,"mixed")
	do examnew(percent,"percent")
	do examnew(numeric,"numeric")
	do examnew(float,"float")
	;
	if errcnt=0 write "verifyall PASSED",!
	else  zwr
	quit
	;
exam(lhs,rhs);
	if $get(@lhs)'=rhs do
	.  write "Verify Failed: for ",lhs,!
	.  write "      Expected:",rhs,!
	.  write "      Found   :",$get(@lhs),!
	.  set errcnt=errcnt+1
	quit
examnew(type,rhs);
	if $get(newdata0(type))'=rhs do
	.  write "Verify Failed: for newdata0(",type,")",!
	.  write "      Expected:",rhs,!
	.  write "      Found   :",$get(newdata0(type)),!
	.  set errcnt=errcnt+1
	if $get(newdata1(type))'=rhs do
	.  write "Verify Failed: for newdata1(",type,")",!
	.  write "      Expected:",rhs,!
	.  write "      Found   :",$get(newdata1(type)),!
	.  set errcnt=errcnt+1
	if $get(newdata2(type))'=rhs do
	.  write "Verify Failed: for newdata2(",type,")",!
	.  write "      Expected:",rhs,!
	.  write "      Found   :",$get(newdata2(type)),!
	.  set errcnt=errcnt+1
	quit
error;
	write $zstatus,!
	q
