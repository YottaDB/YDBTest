;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2002, 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2018-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
umjrnl(srcfile,outfile,audit)   ;public; Apply M journal extract onto database
	;
	; 01 = Process initialization
	; 02 = Process termination
	; 03 = End of file
	; 04 = Kill
	; 05 = Set
	; 06 = ZTstart
	; 07 = ZTcommit
	; 08 = Tstart
	; 09 = Tcommit
	; 10 = ZKill
	; 11 = ZTWOrmhole
	; 12 = ZTRIGger
	; 13 = LGTRig (logical trigger journal record)
	;
	set $ZT="set $ZT="""" g ERROR"
	;
	new OK,command,cnt,ref,tpFence,tran,trgtran
	;
	; By default the routine prints what is applied. set umjrnlmode to "silent", if the output is not desired
	set umjrnlmode=$ztrnlnm("umjrnlmode")
	set trigtst=$ztrnlnm("gtm_test_trigger")
	;
	; The Unix and VMS journal extract format are now the same because of trigger changes
	set recfmtASCII="YDBJEX08"
	set recfmtUNICODE="UTF-8"
	set utf8=0
	; The globals are now at position 11
	set jnlnodeposn=11
	set (ztwormposn,nodeflgposn,lgtrigposn)=10
	open srcfile:(READONLY:ichset="M":REC=32000)
	use srcfile R rec
	if rec'[recfmtASCII use $principal w "TEST-E- Lost Trans Application failed!  Incorrect Journal Extract Format!!",!,rec,! do umhalt
	if rec[recfmtUNICODE set utf8=1
	if utf8=1 do
	. close srcfile
	. open srcfile:(READONLY:REC=32000:ICHSET="UTF-8")
	. use srcfile R rec
	;
	kill tran,trgtran
	set cnt=0,tfseq=1,tpFence=0,audit=+$G(audit)
	;
	for  use srcfile quit:$ZEOF  R rec D
	.       ;
	.       if audit d audit(rec)
	.       ;
	.       set recType=+$piece(rec,"\",1)
	.       set recSeqno=+$piece(rec,"\",6)
	.       ;
	.       if recType=5 D setRec(rec) quit
	.       if recType=4 D killRec(rec) quit
	.       if recType=10 D zkillRec(rec) quit
	.       if recType=11 D ztwormhole(rec) quit
	.       if recType=12 D ztrig(rec) quit
	.       if recType=13 D lgtrig(rec) quit
	.       ;
	.       if recType=6 set tpFence=tpFence+1 set $ztwormhole="" quit
	.       if recType=7 set tpFence=tpFence-1 D:0=tpFence commit(.tran,.trgtran,srcfile,.tfseq) set $ztwormhole="" quit
	.       ;
	.       ; Treat TS as ZTS and TC as ZTC -- should be OK
	.       ;
	.       if recType=8 set tpFence=tpFence+1 quit
	.       if recType=9 set tpFence=tpFence-1 D:0=tpFence commit(.tran,.trgtran,srcfile,.tfseq) quit
	;
	close srcfile
	;
	if tpFence,cnt D
	.       ;
	.       if $G(outfile)="" set outfile=$principal
	.       E  open outfile
	.       ;
	.       use outfile w !,"Incomplete transaction context dump",!!
	.       for i=1:1:cnt w tran(i),!
	.       if outfile'=$principal c outfile
	quit
	;
	;----------------------------------------------------------------------
setRec(rec)     ;Set Record
	;----------------------------------------------------------------------
	;
	quit:trigtst&($piece(rec,"\",nodeflgposn)#2)
	new skipgbl
	set data=$piece(rec,"\",jnlnodeposn,99999)
	if $data(checkzqgblmod) tstart ()	;Don't move tstart into the following if - it needs to be at the outermost level
	if $data(checkzqgblmod)  do
	. do SPLIT(data,.datavar,.dataval)
	. if $zqgblmod(@datavar)  do
	. . use $principal
	. . write !,"Not applying ""set ",data,""", $zqgblmod(",datavar,") returned 1."
	. . if $data(@datavar) write " Current value of global is ",@datavar
	. . set skipgbl=1
	;
	if $data(skipgbl) trollback  quit
	if "^#t("=$Extract($piece(rec,"\",jnlnodeposn),1,4) do
	. ; no need to play these as playing the preceding TLGTRIG/ULGTRIG records would take care of this automatically
	else  do
	. if tpFence set cnt=cnt+1,tran(cnt)="set "_data
	. else  set @data
	if ("silent"'=umjrnlmode) use $principal write "Applying: set ",data,""", $zqgblmod(",data,") returned 0.",!
	if $data(checkzqgblmod)  do
	. tcommit
	quit
	;
	;----------------------------------------------------------------------
killRec(rec)    ;Kill Record
	;----------------------------------------------------------------------
	;
	quit:trigtst&($piece(rec,"\",nodeflgposn)#2)
	set data=$piece(rec,"\",jnlnodeposn,99999)
	if $data(checkzqgblmod) tstart ()
	if $data(checkzqgblmod)  do
	. if $zqgblmod(@data)  do
	. . use $principal write !,"Not applying (seqno:",recSeqno,") ""kill ",data,""", $zqgblmod(",data,") returned 1."
	. . if $data(@data) write " Current value of global is ",@data
	. . set skipgbl=1
	if $data(skipgbl) trollback  quit
	;
	if "^#t"=$Extract($piece(rec,"\",jnlnodeposn),1,3) do
	. ; no need to play these as playing the preceding TLGTRIG/ULGTRIG records would take care of this automatically
	else  do
	. if tpFence set cnt=cnt+1,tran(cnt)="kill "_data
	. else  kill @data
	if $data(checkzqgblmod)  do
	. tcommit
	quit
	;
	;----------------------------------------------------------------------
zkillRec(rec)   ; Zkill a record
	;----------------------------------------------------------------------
	set data=$piece(rec,"\",jnlnodeposn,99999)
	if $data(checkzqgblmod) tstart ()
	if $data(checkzqgblmod)  do
	. if $zqgblmod(@data)  do
	. . use $principal write !,"Not applying (seqno:",recSeqno,") ""zkill ",data,""", $zqgblmod(",data,") returned 1."
	. . if $data(@data) write " Current value of global is ",@data
	. . set skipgbl=1
	if $data(skipgbl) trollback  quit
	;
	if "^#t"=$Extract($piece(rec,"\",jnlnodeposn),1,3) do
	. ; no need to play these as playing the preceding TLGTRIG/ULGTRIG records would take care of this automatically
	else  do
	. if tpFence set cnt=cnt+1,tran(cnt)="ZKILL "_data
	. else  ZKILL @data
	if $data(checkzqgblmod)  do
	. tcommit
	quit
	;
	;----------------------------------------------------------------------
ztwormhole(rec)     ;$ztwormhole Record
	;----------------------------------------------------------------------
	;
	new skipgbl
	set data=$piece(rec,"\",ztwormposn,99999)
	if $data(checkzqgblmod)  quit
	if $data(skipgbl)        quit
	if 'tpFence use $principal write "TEST-E-ASSERT, umjrnl.m saw ZTWORMHOLE record outside of TP. Cannot handle",!  do umhalt
	set cnt=cnt+1,tran(cnt)="set $ztwormhole="_data
	if ("silent"'=umjrnlmode) use $principal write "Applying: set $ztwormhole=",data,!
	quit
	;
	;----------------------------------------------------------------------
ztrig(rec)	; ztrigger record
	;----------------------------------------------------------------------
	;
	new skipgbl
	set data=$piece(rec,"\",jnlnodeposn,99999)	;the node on which the ztrigger was invoked is at the same offset as that of the kill record
	if $data(checkzqgblmod)  quit
	if $data(skipgbl)        quit
	if 'tpFence use $principal write "TEST-E-ASSERT, umjrnl.m saw ZTRIGGER record outside of TP. Cannot handle",!  do umhalt
	set cnt=cnt+1,tran(cnt)="ztrigger "_data
	if ("silent"'=umjrnlmode) use $principal write "Applying: ztrigger ",data,!
	quit
	;
	;----------------------------------------------------------------------
lgtrig(rec)     ;lgtrig Record
	;----------------------------------------------------------------------
	;
	new skipgbl
	set data=$piece(rec,"\",lgtrigposn,99999)
	if $data(checkzqgblmod)  quit
	if $data(skipgbl)        quit
	if 'tpFence use $principal write "TEST-E-ASSERT, umjrnl.m saw LGTRIG record outside of TP. Cannot handle",!  do umhalt
	set cnt=cnt+1,trgtran(cnt)=""
	set tran(cnt)="if '$ztrigger(""item"","_data_") use $principal write ""TEST-E-ASSERT : $ztrigger failed. See ^errmsg global"",! do umhalt"
	if ("silent"'=umjrnlmode) use $principal write "Applying: if $ztrigger(""item"",",data,")",!
	quit
	;
	;----------------------------------------------------------------------
commit(tran,trgtran,srcfile,tfseq)	;Transaction Commit Record
	;----------------------------------------------------------------------
	;
	if $data(checkzqgblmod) use $principal write "TEST-E-ASSERT, umjrnl.m cannot handle $zqgblmod checks within TP",!  do umhalt
	new i,saveio
	if cnt for i=1:1:cnt do
	. ; $ztrigger has output so if that is being played, switch to $principal (to avoid srcfile which is the device otherwise)
	. if $data(trgtran(i)) set saveio=$io use $principal
	. xecute tran(i)
	. if $data(trgtran(i)) use saveio
	set cnt=0
	kill tran,trgtran
	quit
	;
	;----------------------------------------------------------------------
audit(msg)      ; Display audit trail
	;----------------------------------------------------------------------
	;
	use $principal W !,msg
	quit
	;
	;----------------------------------------------------------------------
ERROR   ;Log M error
	;----------------------------------------------------------------------
	;
	if $tlevel trollback
	zshow "*":^errmsg
	zmessage +$ZS
	quit
	;----------------------------------------------------------------------
umhalt  ;Abrupt halt
	;----------------------------------------------------------------------
	if $TLEVEL trollback
	zshow "*":^errmsg
	halt
	;
SPLIT(X,p1,p2,subs)  ; Split journal record correctly at =
	; picked entirely from Profile's URECLOST.m -- Nergis Dincer
	;-----------------------------------------------------------------
	; Arguments:
	;       . X     Journal record    /TYP=T/MECH=VAL
	;
	;       . p1    Piece one - returned    /TYP=T/MECH=REFNAM:W
	;
	;       . p2    Piece two - returned    /TYP=T/MECH=REFNAM:W
	;
	;       . subs  Subscripts              /TYP=ARR/MECH=REFNAM:RW/OPT
	;               If subs="", return global and subscripts
	;               in subs() array, subscipted 1-n, and
	;               subs=number of subscripts
	;
	; Example:
	;
	;       x = 05\57718,62312\19442\652\752014\^ABC(1)="test"
	;       d SPLIT(x,.p1,.p2)
	;
	;       p1 =  05\57718,62312\19442\652\752014\^ABC(1)
	;       p2 = "test"
	;-----------------------------------------------------------------
	;
	new eq,ptr
	if X'["=" set p1=X,p2="" quit
	;
	if $g(subs) k subs set subs=1
	;
	set ptr=0,eq=0
	for  d  quit:'ptr
	.       set ptr=$f(X,"=",ptr) quit:'ptr
	.       set p1=$e(X,1,ptr-2)
	.       if $l(p1,$c(34))-1#2'=0 quit
	.       set p2=$e(X,ptr,99999)
	.       set ptr=0,eq=1
	;
	if eq=0 set p1=X,p2="" set:$d(subs) subs=0 quit
	quit:'$d(subs)
	;
	; Break global reference into subscripts
	new i,ptr,remains,val,cindex,j
	set ptr=0
	set remains=$p(p1,"(",2,9999),remains=$e(remains,1,$l(remains)-1)
	;
	new cindex,j,var,seq,ii
	set cindex=0,j=0,var=""
	for  d  quit:'cindex
	.       set cindex=$f(remains,"$C",cindex)
	.       if cindex>0 d
	..              set t2=$f(remains,")",cindex)
	..              set temp="$C"_$e(remains,cindex,t2-1)
	..              set var("abcde"_j)=temp
	..              set remains=$e(remains,1,cindex-3)_"abcde"_j_$e(remains,t2,$l(remains))
	..              set j=j+1
	;
	for i=1:1 set val=$$NPC^%ZS(remains,.ptr,",") quit:'ptr  set subs(i)=val
	if j>0 d
	.       set seq="" for  set seq=$o(subs(seq)) d  quit:seq=""
	..              if $g(subs(seq))="" quit
	..              set ii="" for  set ii=$o(var(ii)) d  quit:ii=""
	...                     if ii="" quit
	...                     if subs(seq)[ii set subs(seq)=$p(subs(seq),ii,1)_var(ii)_$p(subs(seq),ii,2)
	..              if $g(var(subs(seq)))'="" set subs(seq)=var(subs(seq))
	;
	set subs=i-1
	quit
	;

