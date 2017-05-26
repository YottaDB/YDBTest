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
lkereg;   test for regions

	;A1,B1 is in REG1
	;A2,B2 is in REG2
	; others in DEFAULT
	set unix=$zv'["VMS"
	if unix set DEFAULT="DEFAULT"
	else  set DEFAULT="$DEFAULT"
	l
	do exam(0,".",".",".",1,1,1)
	do lkeexam(0,DEFAULT,".",".",".",0)
	do lkeexam(0,"REG1",".",".",".",0)
	do lkeexam(0,"REG2",".",".",".",0)

	l (^A1,^A2,C)
	do exam(1,"C","^A2","^A1",1,1,1)
	do lkeexam(1,DEFAULT,"C",".",".",1)
	do lkeexam(1,"REG1","^A1",".",".",1)
	do lkeexam(1,"REG2","^A2",".",".",1)

	l  l (^A1,^B1)
	do exam(2,"^B1","^A1",".",1,1,1)
	do lkeexam(2,DEFAULT,".",".",".",0)
	do lkeexam(2,"REG1","^A1","^B1",".",2)
	do lkeexam(2,"REG2",".",".",".",0)

	l +^A2   l +^B2
	do lkeexam(3,DEFAULT,".",".",".",0)
	do lkeexam(3,"REG1","^A1","^B1",".",2)
	do lkeexam(3,"REG2","^A2","^B2",".",2)

	l
	do exam(0,".",".",".",1,1,1)
	do lkeexam(4,DEFAULT,".",".",".",0)
	do lkeexam(4,"REG1",".",".",".",0)
	do lkeexam(4,"REG2",".",".",".",0)

	l  l (^A1,A1,^B1,B1)
	do lkeexam(5,DEFAULT,"A1","B1",".",2)
	do lkeexam(5,"REG1","^A1","^B1",".",2)
	do lkeexam(5,"REG2",".",".",".",0)

	l  l (^A1,^A2,^A3)
	do lkeexam(6,DEFAULT,"^A3",".",".",1)
	do lkeexam(6,"REG1","^A1",".",".",1)
	do lkeexam(6,"REG2","^A2",".",".",1)

	l  l (A1,A2,A3)
	do exam(7,"A3","A2","A1",1,1,1)
	do lkeexam(7,DEFAULT,"A1","A2","A3",3)
	do lkeexam(7,"REG1",".",".",".",0)
	do lkeexam(7,"REG2",".",".",".",0)

	l  l (^A3(1),^A3("string"),^A3(10))
	do lkeexam(8,DEFAULT,"^A3(1)","^A3(10)","^A3(""string"")",3)
	do lkeexam(8,"REG1",".",".",".",0)
	do lkeexam(8,"REG2",".",".",".",0)
	quit


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



lkeexam(k,reg,e0,e1,e2,lcnt)
	set fname="temp"_k_".out"
	set cnt=0
	set line="XXXX"
	if unix do
	. set lkecmd="$LKE show -r="_reg_" -OUTPUT="_fname_"; $convert_to_gtm_chset "_fname
	else  do
	. set lkecmd="pipe $LKE show /R="_reg_" 2>"_fname_" >"_fname
	set y="Owned by PID"
	zsystem lkecmd

	open fname:(READONLY)
	use fname
	for  quit:line[reg!$ZEOF  read line
        if line'[reg close fname   w !,k,"FAIL:Check REGION"  q

	if e0=".",e1=".",e2="." do
	. if line'["%GTM-I-NOLOCKMATCH, No matching locks were found in" set cnt=-99
	else  do
	. if '$ZEOF,unix read line
	. if line[y,line[e0 set cnt=cnt+1
	. if '$ZEOF read line  if line[y,line[e1 set cnt=cnt+1
	. if '$ZEOF read line  if line[y,line[e2 set cnt=cnt+1
	close fname

	if lcnt=cnt w !,k,"   LKE PASS"
	else  do
	. w !,k,"   LKE FAIL",!,"Found:",!
	. if unix zsystem "cat temp.out"
	. else  zsystem "type temp.out"
	q
