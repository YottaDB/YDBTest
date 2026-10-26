;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test $ZTRIGGER("ITEM") gives the right result when a stringpool garbage collection happens while it
; processes a trigger definition that contains a newline [YDB#1316]
;
; Each entry point calls $ZTRIGGER("ITEM",rec), most of them many times. rec is built by concatenation, so it
; is in the stringpool. Before each call, a string of random length is allocated in the stringpool, so that
; garbage collections happen at varying points inside $ZTRIGGER. The $ZTRIGGER output goes to
; <stage>_ztrigger.out.
;
ydb1316	;
	quit

multi	; multi-line -xecute and a numeric subscript
	do run("multi",20000,0)
	quit

single	; single-line definition that ends in a newline, with a numeric subscript
	do run("single",20000,0)
	quit

reorder	; multi-line -xecute followed by a qualifier after the closing >>
	do run("reorder",20000,0)
	quit

newtrig	; multi-line -xecute, a new trigger per call, while the stringpool keeps expanding
	do run("newtrig",30000,1)
	do verify(30000)
	quit

bigger	; multi-line -xecute, each definition more than twice as long as the one before, so that the buffer for
	; the copy of the definition has to be replaced by a bigger one
	new i,nbad
	do run("bigger",4,0)
	set nbad=0
	for i=1:1:4 set ^E(i)=i kill ^E(i) if $get(^F(i))'=(i**3*30) set nbad=nbad+1
	write $select(nbad:"WRONG",1:"PASS")," : ",nbad," of 4 triggers ran a wrong XECUTE string",!
	quit

run(stage,n,grow)
	; Call $ZTRIGGER("ITEM",rec) n times and check that each call returns 1 and leaves rec unchanged.
	; If grow is 1, also keep some strings live so that the stringpool keeps expanding.
	new i,rec,orig,x,keep,ok,nfail,nchanged,log
	set log=stage_"_ztrigger.out"
	open log:newversion
	use log
	set (nfail,nchanged)=0
	for i=1:1:n do
	. set x=$justify(i,1+$random(3000))
	. if grow,'$random(4) set keep(i)=$justify(i,1+$random(2000))
	. set rec=$$rec(stage,i),orig=rec
	. set ok=$ztrigger("item",rec)
	. if 'ok set nfail=nfail+1
	. if rec'=orig set nchanged=nchanged+1
	close log
	write $select(nfail:"WRONG",1:"PASS")," : ",n-nfail," of ",n," $ZTRIGGER calls returned 1"
	write:nfail " (see ",log,")"
	write !
	write $select(nchanged:"WRONG",1:"PASS")," : ",nchanged," of ",n," $ZTRIGGER calls changed the value of their argument",!
	quit

rec(stage,i)
	; Return the trigger definition for call i of stage, built by concatenation
	new nl
	set nl=$char(10)
	quit:"multi"=stage "+^OR(sub1=100,sub2=0:$C(0)) -command=kill -name=multi -xecute=<<"_nl_" do dft($reference) quit"_nl_"dft(var)"_nl_" quit"_nl
	quit:"single"=stage "+^X(sub=1) -command=S -name=single -xecute=""set y=1"""_nl
	quit:"reorder"=stage "+^A -command=kill -xecute=<<"_nl_" set ^B=1"_nl_">>"_nl_"-name=reorder"
	quit:"bigger"=stage "+^E(sub="_i_") -command=kill -name=big"_i_" -xecute=<<"_nl_" set ^F("_i_")=$length("""_$justify("",i**3*30)_""")"_nl
	quit "+^D -command=kill -name=t"_i_" -xecute=<<"_nl_" set ^B="_i_nl_" set ^C="_i_nl

verify(n)
	; Check the XECUTE string of each trigger t<i> that newtrig added, using the $ZTRIGGER("SELECT") output
	new file,line,line1,line2,i,nseen,nbad
	set file="newtrig_select.out"
	open file:newversion
	use file
	if $ztrigger("select","t*")
	close file
	open file:readonly
	use file
	set (nseen,nbad)=0
	for  read line quit:$zeof  do
	. quit:line'["-name=t"
	. set i=+$piece($piece(line,"-name=t",2)," ",1)
	. read line1,line2
	. set nseen=nseen+1
	. if (line1'=(" set ^B="_i))!(line2'=(" set ^C="_i)) set nbad=nbad+1
	close file
	write $select(nseen=n:"PASS",1:"WRONG")," : $ZTRIGGER(""SELECT"") shows ",nseen," of ",n," triggers",!
	write $select(nbad:"WRONG",1:"PASS")," : ",nbad," of ",nseen," triggers have a wrong XECUTE string"
	write:nbad " (see ",file,")"
	write !
	quit
