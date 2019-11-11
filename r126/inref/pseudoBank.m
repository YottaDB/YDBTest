;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pseudoBank	;
	do init
	write "init data",!
	do initData(accountNeeded)
	write "init data done",!

	; start concurrent child processes
	set ^isTimeout=0
        for i=1:1:concurrent do
        . set jobstr="job child^pseudoBank("_i_"):(output=""child_pseudoBank.mjo"_i_""":error=""child_pseudoBank.mje"_i_""")"
        . xecute jobstr
        . set job(i)=$zjob
	hang 120
	set ^isTimeout=1
	; wait for child processes to die
        for i=1:1:concurrent set pid=job(i) for  quit:'$zgetjpi(pid,"ISPROCALIVE")  hang 0.001
        quit

child(jobindex);
	do init
	set temp=concurrent
	set idShift=0
	for  quit:temp<=1  set temp=temp/10 set idShift=idShift+1
	set guid=(jobindex-1)
	set user=$char(64+jobindex)
	set t=0
	for  do  quit:^isTimeout
	. set ref=guid+(t*(10**idShift))
	. set from=startCid+$random(accountNeeded)
	. set to=startCid+$random(accountNeeded-1)
	. set:from=to to=to+1
	. do postTransfer(ref,from,to,tranAmt,user)
	. set t=t+1
	quit

init	;
	set startCid=100001,tranAmt=1,accountNeeded=1000,concurrent=10
	quit

initData(accountNeeded)
	new i
	; account
	for i=0:1:(accountNeeded-1)  do
	. set cid=startCid+i
	. set ^ZACN(cid)="1|10000000"
	; history
	for i=0:1:(accountNeeded-1)  do
	. set cid=startCid+i
	. set ^ZHIST(cid)="Account Create||10000000"
	quit

postTransfer(ref,from,to,amt,user)
	tstart ():(serial:transaction="BATCH")
	set zacnfrom=^ZACN(from)
	set zacnto=^ZACN(to)
	set fromacnseq=$piece(zacnfrom,"|",1)+1
	set $piece(zacnfrom,"|",1)=fromacnseq
	set fromacnbal=$piece(zacnfrom,"|",2)-amt
	set $piece(zacnfrom,"|",2)=fromacnbal
	set toacnseq=$piece(zacnto,"|",1)+1
	set $piece(zacnto,"|",1)=toacnseq
	set toacnbal=$piece(zacnto,"|",2)+amt
	set $piece(zacnto,"|",2)=toacnbal
	set ^ZACN(from)=zacnfrom
	set ^ZACN(to)=zacnto
	set ^ZHIST(from,fromacnseq)="Transfer to "_to_"|-"_amt_"|"_fromacnbal_"|"_ref
	set ^ZHIST(to,toacnseq)="Transfer from "_to_"|"_amt_"|"_toacnbal_"|"_ref
	set ^ZTRNLOG(ref,1)="Transfer to "_to_"|"_$h_"|"_from_"|-"_amt_"|"_fromacnbal_"|"_user
	set ^ZTRNLOG(ref,2)="Transfer from "_from_"|"_$h_"|"_to_"|"_amt_"|"_toacnbal_"|"_user
	tcommit
	quit
