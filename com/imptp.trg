;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
; Copyright (c) 2010-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -----------------------------------------------------------------------------------------------
;             Trigger definitions for SETs and KILLs in imptp.m
; -----------------------------------------------------------------------------------------------

-*
+^arandom(fillid=:,subs=:,J=:) -commands=SET  -xecute="set ^brandomv(fillid,subs,J)=$ztval,^hrandomvariableinimptpfilling(fillid,subs,J)=$ztval"
+^arandom(fillid=:,subs=:,1)   -commands=KILL -xecute="kill ^brandomv(fillid,subs,1),^irandomvariableinimptpfillprgrm(fillid,subs,1)"

+^brandomv(fillid=:,subs=:)     -commands=SET  -xecute="set ^crandomva(fillid,subs)=$ztval"
+^brandomv(fillid=:,subs=:,J=:) -commands=SET  -xecute="set ^crandomva(fillid,subs,J)=$ztval  tstart ():serial  set ^grandomvariableinimptpfill(fillid,subs,J)=$ztval  tcommit"
+^brandomv(fillid=:,subs=:,1)   -commands=KILL -xecute="kill ^crandomva(fillid,subs,1),^frandomvariableinimptp(fillid,subs,1),^grandomvariableinimptpfill(fillid,subs,1)"

+^crandomva(fillid=:,subs=:,J=:) -commands=SET  -xecute="set (^drandomvariable(fillid,subs,J),^frandomvariableinimptp(fillid,subs,J))=$ztval"
+^crandomva(fillid=:,subs=:,1)   -commands=KILL -xecute="kill ^drandomvariable(fillid,subs,1)"

+^drandomvariable(fillid=:,subs=:)     -commands=SET  -xecute="set (^erandomvariableimptp(fillid,subs),^frandomvariableinimptp(fillid,subs))=$ztval"
+^drandomvariable(fillid=:,subs=:,J=:) -commands=SET  -xecute="set ^erandomvariableimptp(fillid,subs,J)=$ztval"
+^drandomvariable(fillid=:,subs=:,1)   -commands=KILL -xecute="tstart ():serial  kill ^erandomvariableimptp(fillid,subs,1)  tcommit"

+^grandomvariableinimptpfill(fillid=:,subs=:)     -commands=SET  -xecute="tstart ():serial  set ^hrandomvariableinimptpfilling(fillid,subs)=$ztval  tcommit"
+^grandomvariableinimptpfill(fillid=:,subs=:,1)   -commands=KILL -xecute="kill ^hrandomvariableinimptpfilling(fillid,subs,1)"

+^hrandomvariableinimptpfilling(fillid=:,subs=:)     -commands=SET  -xecute="set ^irandomvariableinimptpfillprgrm(fillid,subs)=$ztval"
+^hrandomvariableinimptpfilling(fillid=:,subs=:,J=:) -commands=SET  -xecute="set ^irandomvariableinimptpfillprgrm(fillid,subs,J)=$ztval"

+^jrandomvariableinimptpfillprogram(fillid=:,I=:)     -commands=SET   -xecute="set ^jrandomvariableinimptpfillprogram(fillid,I,I)=$ztval"
+^jrandomvariableinimptpfillprogram(fillid=:,I=:,J=:) -commands=SET   -xecute="set ^jrandomvariableinimptpfillprogram(fillid,I,J,$ztworm)=$ztval"
+^jrandomvariableinimptpfillprogram(fillid=:,I=:)     -commands=ZKILL -xecute="zkill ^jrandomvariableinimptpfillprogram(fillid,I,I)"

+^antp(fillid=:,subs=:)     -commands=SET  -xecute="set ^bntp(fillid,$ztworm)=$ztval"
+^antp(fillid=:,subs=:)     -commands=KILL -xecute="tstart ():serial  kill ^bntp(fillid,subs)  tcommit"

+^bntp(fillid=:,subs=:)     -commands=SET  -xecute="set ^cntp(fillid,$ztworm)=$ztval"
+^bntp(fillid=:,subs=:)     -commands=KILL -xecute="zkill ^brandomv(fillid,subs,1)  tstart ():serial  zkill ^cntp(fillid,subs)  tcommit"

+^cntp(fillid=:,subs=:)     -commands=SET  -xecute="set ^dntp(fillid,$ztworm)=""somejunk"""
+^cntp(fillid=:,subs=:)     -commands=ZKILL -xecute="zkill ^dntp(fillid,subs)"

+^entp(fillid=:,subs=:)     -commands=SET  -xecute="set ^fntp(fillid,subs)=$ztval_""suffix"""

; set/kill the max record size
+^gntp(fillid=:,subs=:)     -commands=SET  -xecute=<<
	set ^hntp(fillid,subs)=$ztval
	tstart ():serial
	set ^intp(fillid,subs)=$ztval
	tcommit
>>
+^gntp(fillid=:,subs=:)     -commands=SET  -xecute="set ^bntp(fillid,subs)=$ztval"

+^andxarr(fillid=:,jobno=:,loop=:)     -commands=SET  -xecute=<<
	quit:$ztoldvalue=$ztvalue  ; avoid repeating SET done in imptpztr.trg
	set (^bndxarr(fillid,jobno,loop),^cndxarr(fillid,jobno,loop))=$ztval
	tstart ():serial
	set (^endxarr(fillid,jobno,loop),^indxarr(fillid,jobno,loop))=$ztval
	tcommit
>>

+^cndxarr(fillid=:,jobno=:,loop=:)     -commands=SET  -xecute="set (^dndxarr(fillid,jobno,loop))=$ztval"

+^endxarr(fillid=:,jobno=:,loop=:)     -commands=SET  -xecute="set (^fndxarr(fillid,jobno,loop),^hndxarr(fillid,jobno,loop))=$ztval"

+^fndxarr(fillid=:,jobno=:,loop=:)     -commands=SET  -xecute="tstart ():serial  set (^gndxarr(fillid,jobno,loop))=$ztval  tcommit"

; $piece operations using $ZTUPDATE, should use $ZTDELim instead of $char(124) once it's available
+^aspan(fillid=:,I=:)  -commands=SET  -zdelim="|" -xecute=<<
	view "NOBADCHAR"
	set ztdelim=$char(124)
	if $data(^debug) zwrite $reference,$ZTUPdate
	set espan=$get(^espan(fillid,I))
	for ztup=1:1:$length($ZTUPdate,",") do
	.	set update=$piece($ZTUPdate,",",ztup)
	.	set $piece(espan,ztdelim,update)=$piece($ztval,ztdelim,update)
	set ^espan(fillid,I)=espan	; do only one SET per trigger invocation
>>
+^espan(fillid=:,I=:)  -commands=SET  -zdelim="|" -xecute=<<
	view "NOBADCHAR"
	set ztdelim=$char(124)
	if $data(^debug) zwrite $reference,$ZTUPdate
	set bspan=$get(^bspan(fillid,I))
	set nopad=$tr($ztvalue," ","")
	for ztup=1:1:$length($ZTUPdate,",") do
	.	set update=$piece($ZTUPdate,",",ztup)
	.	set $piece(bspan,ztdelim,update)=$piece(nopad,ztdelim,update)
	set ^bspan(fillid,I)=bspan	; do only one SET per trigger invocation
>>

; Determine if triggers are loaded.
;	set ^%imptp(fillid,"trigger")=0 write ^%imptp(fillid,"trigger"),!
; will produce non-zero if triggers are enabled, 2 if ztrigger command is supported
+^%imptp(*,"trigger")  -commands=SET -xecute="set $ztvalue=1+$$supported^ztrsupport()+$$canmodtrigintp^imptpdztrig()"

; --------------------------------------------------------------------------------------------------------
;     The following is the desired flow of SETs and KILLs in imptp.m due to the above triggers.
;     Tabbing of each line is proportional to $ZTLEVEL
;     Removing the tabs should give a sequence of updates that will match exactly those in imptp.m
; --------------------------------------------------------------------------------------------------------
;
; Stage 1:
;
; $ZTLEVEL=0: set ^arandom(fillid,subsMAX)=val
;
; $ZTLEVEL=0: set ^brandomv(fillid,subsMAX)=valALT
; $ZTLEVEL=1:     set ^crandomva(fillid,subsMAX)=val
;
; $ZTLEVEL=0: set ^drandomvariable(fillid,subs)=valALT
; $ZTLEVEL=1:     set ^erandomvariableimptp(fillid,subs)=valALT
; $ZTLEVEL=1:     set ^frandomvariableinimptp(fillid,subs)=valALT
;
; $ZTLEVEL=0: set ^grandomvariableinimptpfill(fillid,subs)=val
; $ZTLEVEL=1:     set ^hrandomvariableinimptpfilling(fillid,subs)=val
; $ZTLEVEL=2:         set ^irandomvariableinimptpfillprgrm(fillid,subs)=val
;
; $ZTLEVEL=0: set $ztwormhole="subs"
; $ZTLEVEL=0: set ^jrandomvariableinimptpfillprogram(fillid,I)=val
; $ZTLEVEL=1:     set ^jrandomvariableinimptpfillprogram(fillid,I,I)=val
; $ZTLEVEL=2:         set ^jrandomvariableinimptpfillprogram(fillid,I,I,subs)=val
;
; Stage 2:
;
; $ZTLEVEL=0: set ^antp(fillid,subs)=val
; $ZTLEVEL=1:     set ^bntp(fillid,subs)=val
; $ZTLEVEL=2:         set ^cntp(fillid,subs)=val
; $ZTLEVEL=3:             set ^dntp(fillid,subs)="somejunk"		; Set variable to "junk" and set it to val outside trigger
; $ZTLEVEL=0: set ^dntp(fillid,subs)=valALT
;
; Stage 3:
;
; $ZTLEVEL=0: set ^entp(fillid,subs)=val
; $ZTLEVEL=1:     set ^fntp(fillid,subs)=val_"suffix"
; $ZTLEVEL=0: set ^fntp(fillid,subs)=$extract(^fntp(fillid,subs),1,$length(^fntp(fillid,subs))-$length("suffix")) ; =val
;
; $ZTLEVEL=0: set ^gntp(fillid,subsMAX)=valMAX
; $ZTLEVEL=1:     set ^hntp(fillid,subsMAX)=valMAX
; $ZTLEVEL=1:     set ^intp(fillid,subsMAX)=valMAX
; $ZTLEVEL=1:     set ^bntp(fillid,subsMAX)=valMAX
;
; Stage 4:
;
; $ZTLEVEL=0: set ^arandom(fillid,subs,J)=valj
; $ZTLEVEL=1:     set ^brandomv(fillid,subs,J)=valj
; $ZTLEVEL=2:         set ^crandomva(fillid,subs,J)=valj
; $ZTLEVEL=3:             set ^drandomvariable(fillid,subs,J)=valj
; $ZTLEVEL=4:                 set ^erandomvariableimptp(fillid,subs,J)=valj
; $ZTLEVEL=3:             set ^frandomvariableinimptp(fillid,subs,J)=valj
; $ZTLEVEL=2:         set ^grandomvariableinimptpfill(fillid,subs,J)=valj
; $ZTLEVEL=1:     set ^hrandomvariableinimptpfilling(fillid,subs,J)=valj
; $ZTLEVEL=2:         set ^irandomvariableinimptpfillprgrm(fillid,subs,J)=valj
;
; Stage 5:
;
; $ZTLEVEL=0: kill ^arandom(fillid,subs,1)
; $ZTLEVEL=1:     kill ^brandomv(fillid,subs,1)
; $ZTLEVEL=2:         kill ^crandomva(fillid,subs,1)
; $ZTLEVEL=3:             kill ^drandomvariable(fillid,subs,1)
; $ZTLEVEL=4:                 kill ^erandomvariableimptp(fillid,subs,1)
; $ZTLEVEL=2:         kill ^frandomvariableinimptp(fillid,subs,1)
; $ZTLEVEL=2:         kill ^grandomvariableinimptpfill(fillid,subs,1)
; $ZTLEVEL=3:             kill ^hrandomvariableinimptpfilling(fillid,subs,1)
; $ZTLEVEL=1:     kill ^irandomvariableinimptpfillprgrm(fillid,subs,1)
;
; Stage 6:
;
; $ZTLEVEL=0: zkill ^jrandomvariableinimptpfillprogram(fillid,I)
; $ZTLEVEL=1:     zkill ^jrandomvariableinimptpfillprogram(fillid,I,I)
;
; Stage 7:
;
; $ZTLEVEL=0: set $piece(^aspan(fillid,I),"|",i)=$piece(valCHUNK,"|",i)
; $ZTLEVEL=1:     set $piece(^espan(fillid,I),"|",i)=$piece($ztvalue,"|",$ztupdate)
; $ZTLEVEL=2:          set $piece(^bspan(fillid,I),"|",i)=$tr($piece($ztvalue,"|",$ztupdate)," ","") ; padding removed ; not a spanning node
;
; Stage 8:
;
; $ZTLEVEL=0: kill ^antp(fillid,subs)
; $ZTLEVEL=1:     kill ^bntp(fillid,subs)
; $ZTLEVEL=2:         zkill ^brandomv(fillid,subs,1)	; This results nothing
; $ZTLEVEL=2:         zkill ^cntp(fillid,subs)
; $ZTLEVEL=3:             zkill ^dntp(fillid,subs)
; $ZTLEVEL=0: zkill ^bntp(fillid,subsMAX)
;
; Stage 9 does not appear to cause any triggers
;
; Stage 10
;
; $ZTLEVEL=0: kill ^espan(fillid,I)
; $ZTLEVEL=0: set $piece(^aspan(fillid,I),"|",i)=$tr($piece(valCHUNK,"|",i)," ","X")
; $ZTLEVEL=1:     set $piece(^espan(fillid,I),"|",i)=$piece($ztvalue,"|",$ztupdate)
; $ZTLEVEL=2:          set $piece(^bspan(fillid,I),"|",i)=$piece($ztvalue,"|",$ztupdate)
;
; Stage 11
;
; $ZTLEVEL=0: set ^andxarr(fillid,jobno,loop)=I
; $ZTLEVEL=1:     set ^bndxarr(fillid,jobno,loop)=I
; $ZTLEVEL=1:     set ^cndxarr(fillid,jobno,loop)=I
; $ZTLEVEL=2:         set ^dndxarr(fillid,jobno,loop)=I
; $ZTLEVEL=1:     set ^endxarr(fillid,jobno,loop)=I
; $ZTLEVEL=2:         set ^fndxarr(fillid,jobno,loop)=I
; $ZTLEVEL=3:             set ^gndxarr(fillid,jobno,loop)=I
; $ZTLEVEL=2:         set ^hndxarr(fillid,jobno,loop)=I
; $ZTLEVEL=1:     set ^indxarr(fillid,jobno,loop)=I
;
