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
;
; These are collection of helper M routines used by simpleapi_imptp.c
;
dupsetnoop;
	view "GVDUPSETNOOP":1
	quit

getdatinfo;
	do get^datinfo("^%imptp("_fillid_")")
	quit

imptpdztrig;
	do:dztrig ^imptpdztrig(2,istp<2)
	quit

tpnoiso;
	do tpnoiso^imptp
	quit

helper1	;
	do pauseifneeded^pauseimptp
	set subs=$$^ugenstr(I)
	set val=$$^ugenstr(loop)
	do:dztrig ^imptpdztrig(1,istp<2)
	set ztwormstr="set $ztwormhole=subs"
	set recpad=recsize-($$^dzlenproxy(val)-$length(val))			; padded record size minus UTF-8 bytes
	set recpad=$select((istp=2)&(recpad>800):800,1:recpad)			; ZTP uses the lower of the orig 800 or recpad
	set valMAX=$j(val,recpad)
	set valALT=$select(span>1:valMAX,1:val)
	set keypad=$select(istp=2:1,1:keysize-($$^dzlenproxy(subs)-$length(subs)))	; padded key size minus UTF-8 bytes. ZTP uses no padding
	set subsMAX=$j(subs,keypad)
	if $$^dzlenproxy(subsMAX)>keysize write $$^dzlenproxy(subsMAX),?4 zwr subs,I,loop
	quit

ztwormstr	;
	xecute ztwormstr
	quit

ztrcmd	;
	xecute ztrcmd
	quit

helperinit;
	set $etrap="write $zstatus,! zshow ""*"" halt"
	quit

helper2	;
	; Stage 2
	do helperinit
	set rndm=$random(10)
	if (5>rndm)&(0=$tlevel)&trigger do  ; $ztrigger() operation 50% of the time: 10% del by name, 10% del, 80% add
	. set rndm=$random(10),trig=$select(0=rndm:"-"_fulltrig,1=rndm:"-"_trigname,1:"+"_fulltrig)
	. set ztrigstr="set ztrigret=$ztrigger(""item"",trig)"	; xecute needed so it compiles on non-trigger platforms
	. xecute ztrigstr
	. if (trig=("-"_trigname))&(ztrigret=0) set ztrigret=1	; trigger does not exist, ignore delete-by-name error
	. goto:'ztrigret ERROR^imptp
	quit

helper3	;
	do helperinit
	; Stage 4
	for J=1:1:jobcnt D
	. set valj=valALT_J
	. ;
	. if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
	. set ^arandom(fillid,subs,J)=valj
	. if 'trigger do
	. . set ^brandomv(fillid,subs,J)=valj
	. . set ^crandomva(fillid,subs,J)=valj
	. . set ^drandomvariable(fillid,subs,J)=valj
	. . set ^erandomvariableimptp(fillid,subs,J)=valj
	. . set ^frandomvariableinimptp(fillid,subs,J)=valj
	. . set ^grandomvariableinimptpfill(fillid,subs,J)=valj
	. . set ^hrandomvariableinimptpfilling(fillid,subs,J)=valj
	. . set ^irandomvariableinimptpfillprgrm(fillid,subs,J)=valj
	. do:dztrig ^imptpdztrig(1,istp<2)
	. if istp=1 tcommit
	. ;
	; Stage 5
	if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
	do:dztrig ^imptpdztrig(2,istp<2)
	if ((istp=1)&(crash)) do
	. set rndm=$random(10)
	. if rndm=1 if $TRESTART>2  do noop^imptp	; Just randomly hold crit for long time
	. if rndm=2 if $TRESTART>2  hang $random(10)	; Just randomly hold crit for long time
	kill ^arandom(fillid,subs,1)
	if 'trigger do
	. kill ^brandomv(fillid,subs,1)
	. kill ^crandomva(fillid,subs,1)
	. kill ^drandomvariable(fillid,subs,1)
	. kill ^erandomvariableimptp(fillid,subs,1)
	. kill ^frandomvariableinimptp(fillid,subs,1)
	. kill ^grandomvariableinimptpfill(fillid,subs,1)
	. kill ^hrandomvariableinimptpfilling(fillid,subs,1)
	. kill ^irandomvariableinimptpfillprgrm(fillid,subs,1)
	do:dztrig ^imptpdztrig(1,istp<2)
	do:dztrig ^imptpdztrig(2,istp<2)
	if istp=1 tcommit
	; Stage 6
	if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
	zkill ^jrandomvariableinimptpfillprogram(fillid,I)
	if 'trigger do
	. zkill ^jrandomvariableinimptpfillprogram(fillid,I,I)
	if istp=1 tcommit
	; Stage 7 : delimited spanning nodes to be changed in Stage 10
	; At the end of ithis transaction, ^aspan=^espan and $tr(^aspan," ","")=^bspan
	; Partial completion due to crash results in: 1. ^aspan is defined and ^[be]span are undef
	;				 		2. ^aspan=^espan and ^bspan is undef
	if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp>0 ifneeded^orlbkresume(istp)
	; divide up valMAX into a "|" delimited string with the delimiter placed at every 7th space char
	set piecesize=7
	set valPIECE=valMAX
	set totalpieces=($length(valPIECE)/piecesize)+1
	for i=1:1:totalpieces set:($extract(valPIECE,(piecesize*i))=" ") $extract(valPIECE,(piecesize*i))="|" ; $extract beyond $length returns a null character
	set totalpieces=$length(valPIECE,"|")
	set ^aspan(fillid,I)=valPIECE
	if 'trigger do
	. set ^espan(fillid,I)=$get(^aspan(fillid,I))
	. set ^bspan(fillid,I)=$tr($get(^aspan(fillid,I))," ","")
	if istp=1 tcommit
	; Stage 8
	kill ^arandom(fillid,subs,1)	; This results nothing
	kill ^antp(fillid,subs)
	if 'trigger do
	. kill ^bntp(fillid,subs)
	. zkill ^brandomv(fillid,subs,1)	; This results nothing
	. zkill ^cntp(fillid,subs)
	. zkill ^dntp(fillid,subs)
	kill ^bntp(fillid,subsMAX)
	if istp=1 set ^dummy(fillid)=$h		; To test duplicate sets for TP.
	; Stage 9
	; $incr on ^cntloop and ^cntseq exercize contention in CREG (regions > 3) or DEFAULT (regions <= 3)
	set flag=$random(2)
	if flag=1,lfence=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
	set cntloop=$incr(^cntloop(fillid))
	set cntseq=$incr(^cntseq(fillid),(13+jobcnt))
	if flag=1,lfence=1 tcommit
	; Stage 10 : More SET $piece
	; At the end of ithis transaction, $tr(^aspan," ","")=^bspan and $p(^aspan,"|",targetpiece)=$p(^espan,"|",targetpiece)
	; NOTE that ZKILL ^espan means that the SET $PIECE of ^espan will only create pieces up to the target piece
	; Partial completion due to crash results in: 1. ^espan is undef and $tr(^aspan," ","")=^bspan
	;				   		2. ^espan is undef and $p(^aspan,"|",targetpiece)=$tr($p(^bspan,"|",targetpiece)," ","X")
	;				   		3. $p(^aspan,"|",targetpiece)=$tr($p(^espan,"|",targetpiece) and $p(^aspan,"|",targetpiece)=$tr($p(^bspan,"|",targetpiece)," ","X")
	if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp>0 ifneeded^orlbkresume(istp)
	set targetpiece=(loop#(totalpieces))
	set subpiece=$tr($piece($get(^aspan(fillid,I)),"|",targetpiece)," ","X")
	zkill ^espan(fillid,I)
	set $piece(^aspan(fillid,I),"|",targetpiece)=subpiece
	if 'trigger do
	. set $piece(^espan(fillid,I),"|",targetpiece)=subpiece
	. set $piece(^bspan(fillid,I),"|",targetpiece)=subpiece
	if istp=1 tcommit
	; Stage 11
	if lfence=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
	do:dztrig ^imptpdztrig(1,istp<2)
	set ztr=(trigger#10)>1  ; ZTRigger command testing
	xecute:ztr "set $ztwormhole=I ztrigger ^andxarr(fillid,jobno,loop) set $ztwormhole="""""
	set ^andxarr(fillid,jobno,loop)=I
	if 'trigger do
	. set ^bndxarr(fillid,jobno,loop)=I
	. set ^cndxarr(fillid,jobno,loop)=I
	. set ^dndxarr(fillid,jobno,loop)=I
	. set ^endxarr(fillid,jobno,loop)=I
	. set ^fndxarr(fillid,jobno,loop)=I
	. set ^gndxarr(fillid,jobno,loop)=I
	. set ^hndxarr(fillid,jobno,loop)=I
	. set ^indxarr(fillid,jobno,loop)=I
	if istp=0 xecute:ztr ztrcmd set ^lasti(fillid,jobno)=loop
	if lfence=1 tcommit
	quit
