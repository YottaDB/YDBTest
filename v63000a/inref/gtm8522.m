;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8522	;
	do gtm8522a
	do gtm8522b
	quit
	;
gtm8522a;
	; Original testcase reported for GTM-8522
	;
	write $select(1?1A.AN.(1"."):"FAIL",1:"PASS")," from gtm8522a",!
	quit
gtm8522b;
	; General purpose test of pattern match operations
	; This generates some patterns (with alternations) which takes ages to run without the fixes in GTM-8522.
	;
	; Currently limits repetition counts and string literal lengths to 4, since with higher limits
	; and alternation usages, pattern matching takes looooooooong to run and will be addressed.
	; Currently this only generates pattern input strings that are guaranteed to pass the pattern match test.
	; It is harder to generate patterns that are guaranteed to fail. Is a todo for the future.
	;
	new errcnt
	do init
	set begtime=$h
	for loopcnt=1:1  quit:($$^difftime($h,begtime)>15)  do pat	; test various randomly-generated patterns for about 15 seconds
	write $select($data(errcnt):"FAIL",1:"PASS")," from gtm8522b",!
	quit
init	;
	set arr(0)="C",arr(1)="N",arr(2)="P",arr(3)="A",arr(4)="L",arr(5)="U",arr(6)="e" ; needed by patcode()
	for i=1:1:31,127 set arr("C",$incr(arr("C")))=i  					; initialize 'C' array
	for i=48:1:57    set arr("N",$incr(arr("N")))=i  					; initialize 'N' array
	for i=32:1:47,58:1:64,91:1:96,123:1:126 set arr("P",$incr(arr("P")))=i 			; initialize 'P' array
	for i=97:1:122   set (arr("L",$incr(arr("L"))),arr("A",$incr(arr("A"))))=i 		; initialize 'L' and 'A' array
	for i=65:1:90    set (arr("U",$incr(arr("U"))),arr("A",$incr(arr("A"))))=i 		; initialize 'U' and 'A' array
	for i=1:1:127    set arr("e",$incr(arr("e")))=i  		                	; initialize 'E' array
	quit
pat	;
	new finalstr,i
	kill dbg
	set altdisable=$random(2)
	; Note use 'e' and not 'E' above to avoid NUMOFLOW errors (issue investigated by Roger currently)
	set atoms=1+$random(5)	; gives us a range [1,6]
	set patom="",finalstr="",goodstr=""
	for i=1:1:atoms set patom=patom_$$patatom(1+$random(4),.goodstr),finalstr=finalstr_goodstr,goodstr=""
	set result=finalstr?@patom
	if ('result),$increment(errcnt) do
	. write !,"TEST-E-FAIL : *********************************************************",!
	. zwrite dbg
	. write !
	. write $zwrite(finalstr),"?",patom,!	; $zwrite(finalstr) done in case it contains control characters
	quit
patatom(depth,goodstr);
	; Generate one pattern atom
	;
	new patom,rand,i,gudstr,gudrepct
	set patom=$$repct,gudrepct=goodrepct		; goodrepct contains good repitition count
	set rand=$random($select($get(altdisable)=1:75,1:100))
	if (depth=0)&(rand'<75) set rand=$random(75)	; do not choose alternation to avoid indefinite recursion
	if rand<70       set pcode=$$patcode		; goodstr contains good string
	else  if rand<95 set pcode=$$strlit		; goodstr contains good string
	else             set pcode=$$alternation(depth)	; goodstr contains good string
	set patom=patom_pcode
	set gudstr=goodstr,goodstr=""
	for i=1:1:gudrepct set goodstr=goodstr_gudstr
	set dbg($incr(dbg),"goodrepct")=gudrepct
	set dbg($incr(dbg),"patom")=patom
	set dbg($incr(dbg),"goodstr")=goodstr
	quit patom
repct()	;
	; can be anyone of the following 5 combinations
	;
	; .
	; N1
	; N1.N2
	; N1.
	; .N2
	;
	new rand,repct,n1,n2,max
	set rand=$random(5),max=$select(altdisable:16,1:4)
	if rand=0 set repct=".",goodrepct=$random(max)									; .
	if rand=1 set repct=$$pickn,goodrepct=repct									; N1
	if rand=2 set n1=$$pickn,n2=$$pickn(n1),repct=n1_"."_n2,goodrepct=n1+$select(n2-n1=0:0,1:$random(n2-n1))	; N1.N2
	if rand=3 set n1=$$pickn,repct=n1_".",goodrepct=n1+$random($select(altdisable:8,1:2))				; N1.
	if rand=4 set n2=$$pickn,repct="."_n2,goodrepct=$select(n2=0:0,1:$random(n2))					; .N2
	quit repct
pickn(start)	;
	; choose a number from [0,4] if alternations are enabled and [0,16] if disabled
	; higher ranges cause cpu spins with alternation e.g. 7(."kvio").C
	;
	new n,startn,deltan,retn
	set n=$random(3+$select(altdisable:2,1:0))
	if n=0  quit $select($data(start):start,1:0)
	set n=n-1,startn=(2**n),deltan=$random(startn)
	set retn=startn+deltan
	if ($data(start)&(retn<start)) quit start
	quit retn
patcode();
	; choose a patcode from one or more of {C,N,P,A,L,U,E}
	;
	new rand,pcode
	set rand=$random(100)
	if rand<50 quit $$getpcode(1)
	if rand<85 quit $$getpcode(2)
	if rand<95 quit $$getpcode(3)
	if rand<97 quit $$getpcode(4)
	if rand<98 quit $$getpcode(5)
	if rand<99 quit $$getpcode(6)
	quit $$getpcode(7)
getpcode(n);
	new i,pcode,index,tot,rand,nrand
	set pcode="",goodstr="",nrand=1+$random(n)
	for i=1:1:n do
	. set index=$random(7)
	. set pcode=pcode_arr(index)
	. if i=nrand set tot=arr(arr(index)),rand=1+$random(tot),goodstr=goodstr_$char(arr(arr(index),rand))
	quit pcode
strlit();
	new strlit,strlen,i,char
	; null string should be a possibility too
	set strlen=($$pickn)
	set strlit=""
	for i=1:1:strlen do
	. set char=$zchar(97+$random(26))
	. set strlit=strlit_char
	set goodstr=strlit
	set strlit=""""_strlit_""""
	set dbg($incr(dbg),"strlit")=strlit
	set dbg($incr(dbg),"goodstr")=goodstr
	quit strlit
alternation(depth);
	new alt,i,nchoices,goodalt,nrand
	set nchoices=1+$random(2),alt="",goodalt="",goodstr="",nrand=1+$random(nchoices)
	for i=1:1:nchoices do
	. set alt=alt_$select(i=1:"(",1:",")_$$patatom(depth-1,.goodstr)
	. if i=nrand set goodalt=goodstr
	set alt=alt_")"
	set goodstr=goodalt
	set dbg($incr(dbg),"alt")=alt
	set dbg($incr(dbg),"goodstr")=goodstr
	quit alt
