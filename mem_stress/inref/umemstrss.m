;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2004, 2014 Fidelity Information Services, Inc	;
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
umemstrss;
	set $ztrap="set $ztrap="""" g ERROR^umemstrss"
	write "Memory stress test starts",!
	set totjob=6
	set ^arrlen=3
	set ^repcnt=50
	; set triggers if gtm_test_trigger is set
	if $ztrnlnm("gtm_test_tp")="NON_TP"  DO
	.	set ^trigenable=0
	else  DO
	.	set ^trigenable=+$ztrnlnm("gtm_test_trigger")
	if $zv["VMS" set ^seperator="|"
	else  set ^seperator="｜" ;U+FF5C	｜	ef bd 9c	FULLWIDTH VERTICAL LINE
	; some platforms do not have huge memory, so configure test differently for each host
	set ^hname=$$^findhost(1)
	do memstress^serverconf(^hname)
	;
	set jmaxwait=3600*4	; wait for max of 4 hours. However we expect it to take 30-60 minutes on average
	do ^job("strssjob^umemstrss",totjob,"""""")
	d gblver^umemstrss("ver",^arrlen)
	write "Memory stress test ends",!
	Q

strssjob;
	set $ztrap="set $ztrap="""" g ERROR^umemstrss"
	new repcnt,arrlen,repno,hname
	new maxlclen,maxgblen,tmp,bigstr,ascval,i,istp,adata,bdata,cdata,ddata
	set seperator=^seperator
	set seplen=$length(seperator)
	set hname=^hname
	set repcnt=^repcnt
	set arrlen=^arrlen
	set istp=1
	if $ztrnlnm("gtm_test_tp")="NON_TP"  set istp=0
	view "GVDUPSETNOOP":$random(2)
	set maxlclen=2**20
	set maxgblen=(2**14)-100
	for index=1:1:arrlen do
	.  set tmp=seperator_$$^ulongstr(253)
	.  set $p(bigstr(index),tmp,maxlclen\($zlength(tmp)))=""
	.  set remain=maxlclen-$zlength(bigstr(index))
	.  set bigstr(index)=bigstr(index)_$justify("z",remain)
	.  write "index=",index,!
	.  write "len=",$zlength(bigstr(index)),!
	k tmp
	for repno=1:1:repcnt do
	. write $H," repno : "_repno,!
	. set ^repno=repno
	. do fillop^umemstrss("set",arrlen)
	. do devop^umemstrss(repno,arrlen)
	. do fillop^umemstrss("ver",arrlen)
	for repno=1:1:repcnt do
	. do fillop^umemstrss("kill",arrlen)
	do fillop^umemstrss("set",arrlen)
	do devop^umemstrss(repno,arrlen)
        Q
	;
fillop(act,arrlen);
	new index,atprqwertyuiopasdfghjklzxcvbnm1,btpr,ctpr,dtpr,etpr,ftpr,gtpr,atprqwer
	set trigger=^trigenable
	if act="set" do
	. for index=1:1:arrlen do
	. . write $H," "_act_" : "_index,!
	. . if istp=1 tstart (atprqwertyuiopasdfghjklzxcvbnm1,btpr):(serial:transaction="TPROLBK")
	. . set subs=$$^ugenstr(index)
	. . set atprqwertyuiopasdfghjklzxcvbnm1(index,subs)="a"
	. . set btpr(index,subs)="b"
	. . set ctpr(index,subs)="c"
	. . set dtpr(index,subs)="d"
	. . set ^etpr(index,subs)="e"
	. . set ^ftpr(index,subs)="f"
	. . set ^gtpr(index,subs)="g"
	. . set ^atprqwer(index,subs)="h"
	. . merge ^atprqwertyuiopasdfghjklzxcvbnm1(index)=atprqwertyuiopasdfghjklzxcvbnm1
	. . merge ^btpr(index)=btpr
	. . merge ^ctpr(index)=ctpr
	. . merge ^dtpr(index)=dtpr
	. . merge etpr(subs,"")=^etpr
	. . merge ftpr("",subs)=^ftpr
	. . merge gtpr(0,"",subs,"",0)=^gtpr
	. . merge atprqwer(0,"",subs,"",0)=^atprqwer
	. . set ^%1234567=$h
	. . if istp=1 tstart
	. . set len=$zlength(bigstr(index),seperator)
	. . for i=1:1:1024*10 set ^atprllbkkkkkkkkkkkkkkkkkkkkkkkk(i)=len
	. . set gblval=$j(index,maxgblen)
	. . if istp=1 trollback 1
	. . for i=1:1:1024*10 set ^atprllbkkkkkkkkkkkkkkkkkkkkkkkk(i)=i*i
	. . if istp=1 trollback
	. . ;
	. . if index#3=0 kill atprqwertyuiopasdfghjklzxcvbnm1,btpr,ctpr,dtpr,etpr,ftpr,gtpr,atprqwer
	. . ;
	. . if istp=1 tstart *:(serial:transaction="BA")
	. . set idvar="dvar"
	. . do lclcrea^umemstrss(.adata,.bdata,.cdata,.@idvar,index)
	. . set afill(index,bigstr(index),adata)=adata
	. . set bbbb567890123456789012345678901(index,bigstr(index),bdata)=bdata
	. . set cfill(index,bigstr(index),cdata)=cdata
	. . set dfill(index,bigstr(index),@idvar)=@idvar
	. . set efill(index)=$order(afill(index,bigstr(index),""))
	. . set ffill(index)=$zprevious(afill(index,bigstr(index),""))
	. . set bbbb5678(index)=$data(afill(index,bigstr(index),adata))
	. . set subs=$$^ugenstr(index)
	. . set ^afill(subs)=gblval
	. . set ^bbbb567890123456789012345678901(subs)=gblval
	. . if 'trigger  do
	. . . set ^cfill(subs)=gblval
	. . set ^dfill(subs)=gblval
	. . set ^efill(subs)=gblval
	. . set ^ffill(subs)=gblval
	. . set ^bbbb5678(subs)=gblval
	. . set ^%123456789012345678901234567890(subs)=gblval
	. . set ^%1234567=$h_"|"_$j
	. . set ^%1234567(jobindex)=1+$trestart+$get(^%1234567(jobindex+1))+$get(^%1234567(jobindex+2))
	. . set ^%1234567("TREST",$trestart)=1
	. . if istp=1 do
	. . . if ($trestart=0),($random(10)=1) trestart
	. . . tcommit
	. if repno=^repcnt,jobindex=1 do
	. . do ^zwr("bigstr","bigstr.txt","M")
	. . if $zv'["VMS" do ^zwr("bigstr","bigstr.utf-8.txt","UTF-8")
	. . if $zv'["VMS" do ^zwr("bigstr","bigstr.utf-16.txt","UTF-16")
	. . if $zv'["VMS" do ^zwr("bigstr","bigstr.utf-16le.txt","UTF-16LE")
	. . if $zv'["VMS" do ^zwr("bigstr","bigstr.utf-16be.txt","UTF-16BE")
	;
	if act="kill" do
	. for index=1:1:arrlen do
	. . do lclcrea^umemstrss(.adata,.bdata,.cdata,.ddata,index)
	. . kill afill(index,bigstr(index),adata)
	. . kill bbbb567890123456789012345678901(index,bigstr(index),bdata)
	. . kill cfill(index,bigstr(index),cdata)
	. . kill dfill(index,bigstr(index),ddata)
	. . kill efill(index)
	. . kill ffill(index)
	. . kill bbbb5678(index)
	. if $data(afill) write "TEST-E-afill still has data",! zwr afill
	. if $data(bbbb567890123456789012345678901) write "TEST-E-bbbb567890123456789012345678901 still has data",! zwr bbbb567890123456789012345678901
	. if $data(cfill) write "TEST-E-cfill still has data",! zwr cfill
	. if $data(dfill) write "TEST-E-dfill still has data",! zwr dfill
	. if $data(efill) write "TEST-E-efill still has data",! zwr efill
	. if $data(ffill) write "TEST-E-ffill still has data",! zwr ffill
	. if $data(bbbb5678) write "TEST-E-bbbb5678 still has data",! zwr bbbb5678
	;
	if act="ver" do
	. for index=1:1:arrlen do
	. . kill adata,bdata,cdata,ddata
	. . do lclcrea^umemstrss(.adata,.bdata,.cdata,.ddata,index)
	. . if $GET(afill(index,bigstr(index),adata))'=adata write "TEST-E-Verify failed :: afill index =",index," Found=",$GET(afill(index,bigstr(index),adata)),!
	. . if $GET(bbbb567890123456789012345678901(index,bigstr(index),bdata))'=bdata write "TEST-E-Verify failed :: bbbb567890123456789012345678901 index =",index," Found=",$GET(bbbb567890123456789012345678901(index,bigstr(index),adata)),!
	. . if $GET(cfill(index,bigstr(index),cdata))'=cdata write "TEST-E-Verify failed :: cfill index =",index," Found=",$GET(cfill(index,bigstr(index),adata)),!
	. . if $GET(dfill(index,bigstr(index),ddata))'=ddata write "TEST-E-Verify failed :: dfill index =",index," Found=",$GET(dfill(index,bigstr(index),adata)),!
	. . if $GET(efill(index))'=$order(afill(index,bigstr(index),"")) write "TEST-E-Verify failed :: efill index =",index," Found=",$GET(efill(index)),!
	. . if $GET(ffill(index))'=$zprevious(afill(index,bigstr(index),"")) write "TEST-E-Verify failed :: ffill index =",index," Found=",$GET(ffill(index)),!
	. . if $GET(bbbb5678(index))'=$data(afill(index,bigstr(index),adata)) write "TEST-E-Verify failed :: bbbb5678 index =",index," Found=",$GET(bbbb5678(index)),!
	quit
	;
lclcrea(avar,bvar,cvar,dvar,index)
	set tndx=index#131+127
	set avar=$extract(bigstr(index),1,maxlclen)
	set bvar=bigstr(index)
	set $piece(bvar,$char(tndx),1,$length(bigstr(index)))=$char(tndx+1)
	set cvar=$find(bigstr(index),"ＸＹＺ")
	set dvar=$translate(bigstr(index),$char(tndx),"α")
	set dvar=$translate(dvar,"α",$zchar(tndx))
	set dvar=$reverse(dvar)
	quit
	;
gblver(act,arrlen);
	new index,maxgblen
	set maxgblen=(2**14)-100
	if act="ver" do
	. for index=1:1:arrlen do
	. . set gblval=$j(index,maxgblen)
	. . set subs=$$^ugenstr(index)
	. . if $GET(^afill(subs))'=gblval write "TEST-E-Verify failed for index =",index,!
	. . if $GET(^bbbb567890123456789012345678901(subs))'=gblval write "TEST-E-Verify failed for index =",index,!
	. . if $GET(^cfill(subs))'=gblval write "TEST-E-Verify failed for index =",index,!
	. . if $GET(^dfill(subs))'=gblval write "TEST-E-Verify failed for index =",index,!
	. . if $GET(^efill(subs))'=gblval write "TEST-E-Verify failed for index =",index,!
	. . if $GET(^ffill(subs))'=gblval write "TEST-E-Verify failed for index =",index,!
	. . if $GET(^bbbb5678(subs))'=gblval write "TEST-E-Verify failed for index =",index,!
	. . if $GET(^%123456789012345678901234567890(subs))'=gblval write "TEST-E-Verify failed for index =",index,!
	quit

devop(repno,arrlen);
	new start,new
	set $ztrap="g ERROR"
	set start=((repno-1)*arrlen)+1
	set end=start+arrlen-1
        for fno=start:1:end do
        .  set fname(fno)="MEMLEAK"_$j_fno
        .  open fname(fno):(newversion:chset="UTF-16LE":exception="g DEVERR")
        .  use fname(fno):(exception="g DEVERR")
        .  write $j," ",fno,!
	.  write $j($C(1000),1000000),!
        .  close fname(fno):delete
        quit

DEVERR;
	write "$zstatus=",$zstatus,!
	if $tlevel trollback
        halt
ERROR;
	write "$zstatus=",$zstatus,!
	if $data(index) zwrite index
	if $tlevel trollback
        halt
