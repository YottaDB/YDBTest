;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start
	set $etrap="do errproc()"
	kill ^fired
	do text^dollarztrigger("tfile^nullsub","nullsub.trg")
	do file^dollarztrigger("nullsub.trg",1)
	; all the ztrigger command should work no matter whether database supports nullscript
	ztrigger ^a("")
	ztrigger ^a("b","")
	ztrigger ^b("")
	ztrigger ^b(10)
	ztrigger ^c("a")
	ztrigger ^d("$")
	ztrigger ^e("a")
	zwr ^fired(:,:)
	kill ^fired
	; for database not supporting nullsubscript, set will result in error
	set ^a("")=1
	zwr ^fired(:,:)
	halt

errproc()
	write $zstatus,!
	set $zstatus="",$ecode=""
	quit

test
	set ref=$reference
	set x=$increment(^fired($ZTNAme))
	set $piece(^fired($ZTNAme,x),$char(32),1)="$reference="_ref
	if $data(lvn) set $piece(^fired($ZTNAme,x),$char(32),2)="lvn="_lvn
	quit

tfile
	;+^b("":"a") -commands=S,ZTR -xecute="do test^nullsub"
	;+^b("":) -commands=S,ZTR -xecute="do test^nullsub"
	;+^b("";"";0;"a") -commands=S,ZTR -xecute="do test^nullsub"
	;+^b("";0;"g") -commands=S,ZTR -xecute="do test^nullsub"
	;+^a("b","") -command=SET,ZTR -xecute="do test^nullsub"
	;+^a("") -command=SET,ZTR -xecute="do test^nullsub"
	;+^c("":"") -command=SET,ZTR -xecute="do test^nullsub"
	;+^d("":",") -command=SET,ZTR -xecute="do test^nullsub"
	;+^e(":":"") -command=SET,ZTR -xecute="do test^nullsub"

