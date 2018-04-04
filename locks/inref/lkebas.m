;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
lkebas	; simple locks
	W "simple locks"
	Set fncnt=0
	l
	do exam(0,".",".",".",1,1,1)
	do lkeexam(0,".",".",".",0)
	l a
	do exam(1,"a",".",".",1,1,1)
	do lkeexam(1,"a",".",".",1)
	l b
	do exam(2,"b",".",".",1,1,1)
	do lkeexam(2,"b",".",".",1)
	l c
	do exam(3,"c",".",".",1,1,1)
	do lkeexam(3,"c",".",".",1)
	l (a,b,c)
	do exam(4,"c","b","a",1,1,1)
	do lkeexam(4,"a","b","c",3)
	l
	do exam(5,".",".",".",1,1,1)
	do lkeexam(5,".",".",".",0)


incr	W !,"incremental locks"
	l a
	do exam(1,"a",".",".",1,1,1)
	do lkeexam(1,"a",".",".",1)
	l +b
	do exam(2,"b","a",".",1,1,1)
	do lkeexam(2,"a","b",".",2)
	l +a,b,c
	do exam(3,"c",".",".",1,1,1)
	do lkeexam(3,"c",".",".",1)
	l +(a,b,c)
	do exam(4,"c","b","a",2,1,1)
	do lkeexam(4,"a","b","c",3)
	l
	do exam(5,".",".",".",1,1,1)
	do lkeexam(5,".",".",".",0)

decr	W !,"decremental locks"
	l a
	do exam(1,"a",".",".",1,1,1)
	do lkeexam(1,"a",".",".",1)
	l +b
	do exam(2,"b","a",".",1,1,1)
	do lkeexam(2,"a","b",".",2)
	l -a
	do exam(3,"b",".",".",1,1,1)
	do lkeexam(3,"b",".",".",1)
	l +(a,b,c)
	do exam(4,"c","b","a",1,2,1)
	do lkeexam(4,"a","b","c",3)
	l -(a,b,c)
	do exam(5,"b",".",".",1,1,1)
	do lkeexam(5,"b",".",".",1)

timed	W !,"timed locks"
	l a:0
	do exam(1,"a",".",".",1,1,1)
	do lkeexam(1,"a",".",".",1)
	l b:1
	do exam(2,"b",".",".",1,1,1)
	do lkeexam(2,"b",".",".",1)
	l a,b,c:2
	do exam(3,"c",".",".",1,1,1)
	do lkeexam(3,"c",".",".",1)
	l (a,b,c):3
	do exam(4,"c","b","a",1,1,1)
	do lkeexam(4,"a","b","c",3)
	l
	do exam(5,".",".",".",1,1,1)
	do lkeexam(5,".",".",".",0)

tincr	W !,"incremental timed locks"
	l a:4
	do exam(1,"a",".",".",1,1,1)
	do lkeexam(1,"a",".",".",1)
	l +b:5
	do exam(2,"b","a",".",1,1,1)
	do lkeexam(2,"a","b",".",2)
	l +a,b,c:-1
	do exam(3,"c",".",".",1,1,1)
	do lkeexam(3,"c",".",".",1)
	l +(a,b,c):1000
	do exam(4,"c","b","a",2,1,1)
	do lkeexam(4,"a","b","c",3)
	l:10000
	do exam(5,".",".",".",1,1,1)
	do lkeexam(5,".",".",".",0)
tdecr	W !,"decremental timed locks"
	l a:.001
	do exam(1,"a",".",".",1,1,1)
	do lkeexam(1,"a",".",".",1)
	l +b:3
	do exam(2,"b","a",".",1,1,1)
	do lkeexam(2,"a","b",".",2)
	l -a:2
	do exam(3,"b",".",".",1,1,1)
	do lkeexam(3,"b",".",".",1)
	l +(a,b,c):12.432
	do exam(4,"c","b","a",1,2,1)
	do lkeexam(4,"a","b","c",3)
	l -(a,b,c):99.99
	do exam(5,"b",".",".",1,1,1)
	do lkeexam(5,"b",".",".",1)
	l
	w "End of lock test",!
	q

exam(k,e0,e1,e2,l0,l1,l2)
	s y(1)="LOCK "_e0_" LEVEL="_l0
	s y(2)="LOCK "_e1_" LEVEL="_l1
	s y(3)="LOCK "_e2_" LEVEL="_l2
	k x
	zshow "l":x
	i $d(x("L",1))=0  s x("L",1)="LOCK . LEVEL=1"
	i $d(x("L",2))=0  s x("L",2)="LOCK . LEVEL=1"
	i $d(x("L",3))=0  s x("L",3)="LOCK . LEVEL=1"
	i y(1)=x("L",1),y(2)=x("L",2),y(3)=x("L",3)    w !,k,"   GTM PASS "   q
	e  w k,"** FAIL ","computed <",x("L",1),"> expected <",y(1),">",!
	w "         computed <",x("L",2),"> expected <",y(2),">",!
	w "         computed <",x("L",3),"> expected <",y(3),">",!
	q



lkeexam(k,e0,e1,e2,lcnt)
	Set fncnt=fncnt+1
	set fname="lkebas"_fncnt_".out"
	set cnt=0
	set unix=$zv'["VMS"
	set y="Owned by PID"
	if unix do
	.  SET zscmd="zsystem ""$LKE show -all -OUTPUT="_fname_"; $convert_to_gtm_chset "_fname_""""
	.  x zscmd
	.  set x="which is an existing process"
	else  do
	.  SET zscmd="zsystem ""pipe $LKE show /all 2>"_fname_" > "_fname_""""
	.  x zscmd
	.  set x="which is"

	set line="----"
	open fname:(READONLY)
	use fname
	if e0=".",e1=".",e2="." do
	.  for  quit:line["DEFAULT"!$ZEOF  read line
	.  if line["LOCKSPACEINFO" read line	; take into account LOCKSPACEINFO message in LKE SHOW output
	.  close fname
	.  if line["%GTM-I-NOLOCKMATCH, No matching locks were found in" w !,k,"   LKE PASS"
	.  else  w !,k,"   LKE FAIL ",line,!
	.  q
	else  do
	.  for  quit:line["DEFAULT"!$ZEOF  read line
	.  if line'["DEFAULT" close fname   w !,k,"Check REGION"  q
	.  if unix,'($ZEOF) read line
	.  if $find(line,e0)=$length(e0)+1,line[y,line[x set cnt=cnt+1
	.  if '($ZEOF) read line  if $find(line,e1)=$length(e1)+1,line[y,line[x set cnt=cnt+1
	.  if '($ZEOF) read line  if $find(line,e2)=$length(e2)+1,line[y,line[x set cnt=cnt+1
	.  close fname
	.  if lcnt=cnt w !,k,"   LKE PASS"
	.  else  w !,k,"   LKE FAIL" zwrite
	q
