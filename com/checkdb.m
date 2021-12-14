;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2002-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkdb;
	;	Checks the database, if database has correct data
	;	Check if nothing is lost or, nothing is duplicate
	;   This program for database fills using primitive root of a field.
        ;   Say, w is the primitive root and we have 5 jobs
        ;   Job 1 : Sets index w^0, w^5, w^10 etc.
        ;   Job 2 : Sets index w^1, w^6, w^11 etc.
        ;   Job 3 : Sets index w^2, w^7, w^12 etc.
        ;   Job 4 : Sets index w^3, w^8, w^13 etc.
        ;   Job 5 : Sets index w^4, w^9, w^14 etc.
        ;   In above example nroot = w^5
        ;   In above example root =  w
	;
	;   WARNING: Versions prior to V60001 did not support $ZWRITE().
	;   Currently no test uses checkdb with a prior version. If the need
	;   arises, fork checkdb into two versions, one for versions prior to
	;   V60001 and one for current versions.
	set $ZT="SET $ZT="""" g ERROR^checkdb"
	view "NOBADCHAR"
	;
	set crash=+$ztrnlnm("gtm_test_crash")	; Do not use ^%imptp("crash") as test might have redefined the logical
	set fid=+$ztrnlnm("gtm_test_dbfillid")	; Do not use ^%imptp("totaljob",fid), as test might have redefined the logical
	do loadinfofileifneeded^imptp(fid)
	set span=+$ztrnlnm("gtm_test_spannode")
	set skipreg=^%imptp(fid,"skipreg")
	set istp=^%imptp(fid,"istp")
	set gtcm=^%imptp(fid,"gtcm")
	set prime=^%imptp(fid,"prime")
	set root=^%imptp(fid,"root")
	set jobcnt=^%imptp(fid,"totaljob")
	set keysize=^%imptp(fid,"key_size")
	set recsize=^%imptp(fid,"record_size")
	set verifail="Verify Fail @",expect=" Expected="
	;
	if jobcnt=0 write "TEST-E-CHECKDB Cannot do checkdb, jobcnt=",jobcnt,! h
	if (gtcm=1)&(crash=1) w "TEST-E-CHECKDB Cannot verify database, gtcm=",gtcm,"crash=",crash,! h
	if (crash=0)&(skipreg'=0) w "TEST-E-CHECKDB Cannot do checkdb, skipreg=",skipreg,"crash=",crash,! h
	;
	set callcrash=crash
	if istp=0 set callcrash=0
	set fl=0
	set maxerr=10
	set fltconst=3.14
        set nroot=1
	set cntloop=0
        for J=1:1:jobcnt do
	.	set nroot=(nroot*root)#prime
	.	set cntloop=cntloop+$GET(^lasti(fid,J))
	if callcrash=0 do nocrash^checkdb
	if callcrash'=0 do
	. if istp=2 do crashztp^checkdb
	. if istp'=2 do crash^checkdb
	;
	if (crash=0)&(cntloop'=$GET(^cntloop(fid))) w verifail,loop,": ^cntloop(",fid,")=",$GET(^cntloop(fid))," Expected=",cntloop,! set fl=fl+1
	;
	if fl=0 write "checkdb PASSED.",!
	else  write "checkdb FAILED.",!
	q
	;
crash;
	set vms=$zv["VMS"
	set ival=1
	for jobno=1:1:jobcnt D
	. set I=ival
	. write:$data(^debug) "Testing ",jobno," up till ",$GET(^lasti(fid,jobno)),!
	. for loop=1:1:$GET(^lasti(fid,jobno)) do  q:(fl>maxerr)
	. . if vms do
	. . . set subs=$$^genstr(I)			; I to subs  has one-to-one mapping
	. . . set val=$$^genstr(loop)		; loop to val has one-to-one mapping
	. . else  do
	. . . set subs=$$^ugenstr(I)			; I to subs  has one-to-one mapping
	. . . set val=$$^ugenstr(loop)		; loop to val has one-to-one mapping
	. . set recpad=recsize-($$^dzlenproxy(val)-$length(val))
	. . set recpad=$select((istp=2)&(recpad>800):800,1:recpad)
	. . set valMAX=$j(val,recpad)
	. . set valALT=$select(span>1:valMAX,1:val)
	. . set keypad=$select(istp=2:1,1:keysize-($$^dzlenproxy(subs)-$length(subs)))
	. . set subsMAX=$j(subs,keypad)
	. . ; divide up valMAX into a "|" delimited string with the delimiter placed at every 7th space char
	. . ; incomplete runs may complete Stage 7 (valPIECE) but not Stage 10
	. . set piecesize=7
	. . set valPIECE=valMAX
	. . set totalpieces=($length(valPIECE)/piecesize)+1
	. . for i=1:1:totalpieces set:($extract(valPIECE,(piecesize*i))=" ") $extract(valPIECE,(piecesize*i))="|"
	. . set totalpieces=$length(valPIECE,"|")
	. . set targetpiece=(loop#(totalpieces))
	. . ; Stage 10 has two different final states for ^[abe]span
	. . ; ^aspan stripped of padding is equal to ^bspan
	. . ; ^espan has null pieces up to targetpiece which is XXXXXX
	. . set (stage(7,"aspan"),stage(7,"espan"))=valPIECE
	. . set stage(7,"bspan")=$tr(valPIECE," ","")
	. . set stage(10,"aspan")=valPIECE
	. . set $piece(stage(10,"aspan"),"|",targetpiece)=$tr($piece(valPIECE,"|",targetpiece)," ","X")
	. . set stage(10,"bspan")=$tr(stage(10,"aspan")," ","")
	. . kill stage(10,"espan")
	. . set $piece(stage(10,"espan"),"|",targetpiece)=$tr($piece(valPIECE,"|",targetpiece)," ","X")
	. . set complete=$DATA(^andxarr(fid,jobno,loop))
	. . ;
	. . ; First tp
	. . if $GET(^arandom(fid,subsMAX))'=val write verifail,loop,": ^arandom(",fid,",",$zwrite(subsMAX),")=",$zwrite($GET(^arandom(fid,subsMAX)))," Expected=",$zwrite(val),! set fl=fl+1
	. . if $GET(^brandomv(fid,subsMAX))'=valALT write verifail,loop,": ^brandomv(",fid,",",$zwrite(subsMAX),")=",$zwrite($GET(^brandomv(fid,subsMAX)))," Expected=",$zwrite(val),! set fl=fl+1
	. . if $GET(^crandomva(fid,subsMAX))'=valALT write verifail,loop,": ^crandomva(",fid,",",$zwrite(subsMAX),")=",$zwrite($GET(^crandomva(fid,subsMAX)))," Expected=",$zwrite(val),! set fl=fl+1
	. . if $GET(^drandomvariable(fid,subs))'=valALT write verifail,loop,": ^drandomvariable(",fid,",",$zwrite(subs),")=",$zwrite($GET(^drandomvariable(fid,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	. . if $GET(^erandomvariableimptp(fid,subs))'=valALT write verifail,loop,": ^erandomvariableimptp(",fid,",",$zwrite(subs),")=",$zwrite($GET(^erandomvariableimptp(fid,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	. . if $GET(^frandomvariableinimptp(fid,subs))'=valALT write verifail,loop,": ^frandomvariableinimptp(",fid,",",$zwrite(subs),")=",$zwrite($GET(^frandomvariableinimptp(fid,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	. . if $GET(^grandomvariableinimptpfill(fid,subs))'=val write verifail,loop,": ^grandomvariableinimptpfill(",fid,",",$zwrite(subs),")=",$zwrite($GET(^grandomvariableinimptpfill(fid,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	. . if skipreg<1 do
	. . . if $GET(^hrandomvariableinimptpfilling(fid,subs))'=val write verifail,loop,": ^hrandomvariableinimptpfilling(",fid,",",$zwrite(subs),")=",$zwrite($GET(^hrandomvariableinimptpfilling(fid,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	. . if $GET(^irandomvariableinimptpfillprgrm(fid,subs))'=val w verifail,loop,": ^irandomvariableinimptpfillprgrm(",fid,",",$zwrite(subs),")=",$zwrite($GET(^irandomvariableinimptpfillprgrm(fid,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	. . if $GET(^jrandomvariableinimptpfillprogram(fid,I,I,subs))'=val write verifail,loop,": ^jrandomvariableinimptpfillprogram(",fid,",",I,",","I",",",$zwrite(subs),")=",$zwrite($GET(^jrandomvariableinimptpfillprogram(fid,I,I,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	. . if complete do
	. . . if $GET(^jrandomvariableinimptpfillprogram(fid,I))'="" write verifail,loop,": ^jrandomvariableinimptpfillprogram(",fid,",",I,")=",$zwrite($GET(^jrandomvariableinimptpfillprogram(fid,I)))," Expected=null",! set fl=fl+1
	. . . if $GET(^jrandomvariableinimptpfillprogram(fid,I,I))'="" write verifail,loop,": ^jrandomvariableinimptpfillprogram(",fid,",",I,",",I,")=",$zwrite($GET(^jrandomvariableinimptpfillprogram(fid,I,I)))," Expected=null",! set fl=fl+1
	. . . ; Continue tp for the second subscripts
	. . if complete set jmax=jobcnt
	. . else  do
	. . .  set jmax=$ZPREVIOUS(^arandom(fid,subs,""))
	. . .  ; verify TP partners
	. . .  if jmax'=$ZPREVIOUS(^brandomv(fid,subs,"")) write verifail,loop,": $zprev ^brandomv(",fid,",",$zwrite(subs),")=",$zwrite($ZPREVIOUS(^brandomv(fid,subs,"")))," Expected=",$zwrite(jmax),! set fl=fl+1
	. . .  if jmax'=$ZPREVIOUS(^crandomva(fid,subs,"")) write verifail,loop,": $zprev ^crandomva(",fid,",",$zwrite(subs),")=",$zwrite($ZPREVIOUS(^crandomva(fid,subs,"")))," Expected=",$zwrite(jmax),! set fl=fl+1
	. . .  if jmax'=$ZPREVIOUS(^drandomvariable(fid,subs,"")) write verifail,loop,": $zprev ^drandomvariable(",fid,",",$zwrite(subs),")=",$zwrite($ZPREVIOUS(^drandomvariable(fid,subs,"")))," Expected=",$zwrite(jmax),! set fl=fl+1
	. . .  if jmax'=$ZPREVIOUS(^erandomvariableimptp(fid,subs,"")) write verifail,loop,": $zprev ^erandomvariableimptp(",fid,",",$zwrite(subs),")=",$zwrite($ZPREVIOUS(^erandomvariableimptp(fid,subs,"")))," Expected=",$zwrite(jmax),! set fl=fl+1
	. . .  if jmax'=$ZPREVIOUS(^frandomvariableinimptp(fid,subs,"")) write verifail,loop,": $zprev ^frandomvariableinimptp(",fid,",",$zwrite(subs),")=",$zwrite($ZPREVIOUS(^frandomvariableinimptp(fid,subs,"")))," Expected=",$zwrite(jmax),! set fl=fl+1
	. . .  if jmax'=$ZPREVIOUS(^grandomvariableinimptpfill(fid,subs,"")) write verifail,loop,": $zprev ^grandomvariableinimptpfill(",fid,",",$zwrite(subs),")=",$zwrite($ZPREVIOUS(^grandomvariableinimptpfill(fid,subs,"")))," Expected=",$zwrite(jmax),! set fl=fl+1
	. . .  if skipreg<1 do
	. . .  . if jmax'=$ZPREVIOUS(^hrandomvariableinimptpfilling(fid,subs,"")) write verifail,loop,": $zprev ^hrandomvariableinimptpfilling(",fid,",",$zwrite(subs),")=",$zwrite($ZPREVIOUS(^hrandomvariableinimptpfilling(fid,subs,"")))," Expected=",$zwrite(jmax),! set fl=fl+1
	. . .  if jmax'=$ZPREVIOUS(^irandomvariableinimptpfillprgrm(fid,subs,"")) write verifail,loop,": $zprev ^irandomvariableinimptpfillprgrm(",fid,",",$zwrite(subs),")=",$zwrite($ZPREVIOUS(^irandomvariableinimptpfillprgrm(fid,subs,"")))," Expected=",$zwrite(jmax),! set fl=fl+1
	. . for J=1:1:+jmax do
	. . . set rval=valALT_J
	. . . if ((J=1)&((complete)!($DATA(^arandom(fid,subs,1))=0))) set rval=""
	. . . if $GET(^arandom(fid,subs,J))'=rval write verifail,loop,": ^arandom(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^arandom(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	. . . if $GET(^brandomv(fid,subs,J))'=rval write verifail,loop,": ^brandomv(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^brandomv(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	. . . if $GET(^crandomva(fid,subs,J))'=rval write verifail,loop,": ^crandomva(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^crandomva(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	. . . if $GET(^drandomvariable(fid,subs,J))'=rval write verifail,loop,": ^drandomvariable(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^drandomvariable(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	. . . if $GET(^erandomvariableimptp(fid,subs,J))'=rval write verifail,loop,": ^erandomvariableimptp(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^erandomvariableimptp(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	. . . if $GET(^frandomvariableinimptp(fid,subs,J))'=rval write verifail,loop,": ^frandomvariableinimptp(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^frandomvariableinimptp(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	. . . if $GET(^grandomvariableinimptpfill(fid,subs,J))'=rval write verifail,loop,": ^grandomvariableinimptpfill(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^grandomvariableinimptpfill(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	. . . if skipreg<1 do
	. . . .  if $GET(^hrandomvariableinimptpfilling(fid,subs,J))'=rval write verifail,loop,": ^hrandomvariableinimptpfilling(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^hrandomvariableinimptpfilling(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	. . . if $GET(^irandomvariableinimptpfillprgrm(fid,subs,J))'=rval write verifail,loop,": ^irandomvariableinimptpfillprgrm(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^irandomvariableinimptpfillprgrm(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	. . if complete do
	. . . ; Now ntp
	. . . if $DATA(^antp(fid,subs))'=0 write verifail,loop,": ^antp(",fid,",",$zwrite(subs),")=",$zwrite($GET(^antp(fid,subs)))," Expected=null",! set fl=fl+1
	. . . if $DATA(^bntp(fid,subs))'=0 write verifail,loop,": ^bntp(",fid,",",$zwrite(subs),")=",$zwrite($GET(^bntp(fid,subs)))," Expected=null",! set fl=fl+1
	. . . if $DATA(^cntp(fid,subs))'=0 write verifail,loop,": ^cntp(",fid,",",$zwrite(subs),")=",$zwrite($GET(^cntp(fid,subs)))," Expected=null",! set fl=fl+1
	. . . if $DATA(^dntp(fid,subs))'=0 write verifail,loop,": ^dntp(",fid,",",$zwrite(subs),")=",$zwrite($GET(^dntp(fid,subs)))," Expected=null",! set fl=fl+1
	. . if (complete)!(+jmax'=0) do
	. . . if $GET(^entp(fid,subs))'=val write verifail,loop,": ^entp(",fid,",",$zwrite(subs),")=",$zwrite($GET(^entp(fid,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	. . . if $GET(^fntp(fid,subs))'=val write verifail,loop,": ^fntp(",fid,",",$zwrite(subs),")=",$zwrite($GET(^fntp(fid,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	. . . if $GET(^gntp(fid,subsMAX))'=valMAX write verifail,loop,": ^gntp(",fid,",",$zwrite(subsMAX),")=",$zwrite($GET(^gntp(fid,subsMAX)))," Expected=",$zwrite(valMAX),! set fl=fl+1
	. . . if skipreg<1 do
	. . . . if $GET(^hntp(fid,subsMAX))'=valMAX write verifail,loop,": ^hntp(",fid,",",$zwrite(subsMAX),")=",$zwrite($GET(^hntp(fid,subsMAX)))," Expected=",$zwrite(valMAX),! set fl=fl+1
	. . . if $GET(^intp(fid,subsMAX))'=valMAX write verifail,loop,": ^intp(",fid,",",$zwrite(subsMAX),")=",$zwrite($GET(^intp(fid,subsMAX)))," Expected=",$zwrite(valMAX),! set fl=fl+1
	. . if 'complete do  			; validate the last fully completed transaction
	. . . set aspan=$GET(^aspan(fid,I))	; use $GET in case the globals are not defined
	. . . set bspan=$GET(^bspan(fid,I))
	. . . set espan=$GET(^espan(fid,I))
	. . . ; All are undefined
	. . . quit:((aspan="")&(espan="")&(bspan=""))
	. . . ; Stage 7 successful
	. . . quit:((aspan=stage(7,"aspan"))&(aspan=espan)&(stage(7,"bspan")=bspan))
	. . . ; Stage 7 partial #1 aspan isdef and [be]span undef
	. . . quit:((aspan=stage(7,"aspan"))&(espan="")&(bspan=""))
	. . . ; Stage 7 partial #2 aspan=espan and bspan undef
	. . . quit:((aspan=stage(7,"aspan"))&(aspan=espan)&(bspan=""))
	. . . ; Stage 10 partial #1 espan undef and aspan=stage(7,"aspan") and bspan=stage(7,"bspan")
	. . . quit:((aspan=stage(7,"aspan"))&(espan="")&(stage(7,"bspan")=bspan))
	. . . ; at this point Stage 7 is complete. if aspan=stage(7,"aspan") issue an error due to failing all prior success cases
	. . . if aspan=stage(7,"aspan") write verifail,loop,": Stage 7 ^[abe]span(",fid,",",loop,") at ",loop,! do spanerr set fl=fl+1 quit
	. . . ; Stage 10 successful
	. . . quit:((aspan=stage(10,"aspan"))&(espan=stage(10,"espan"))&(bspan=stage(10,"bspan")))
	. . . ; Stage 10 partial #2 espan undef and $piece(aspan,"|",targetpiece) has been set, but $piece(bspan,"|",targetpiece) has not
	. . . quit:((aspan=stage(10,"aspan"))&(espan="")&(stage(7,"bspan")=bspan))
	. . . ; Stage 10 partial #3 SET $P of targetpiece in ^[ae]span is done, but not for bspan
	. . . quit:((aspan=stage(10,"aspan"))&(espan=stage(10,"espan"))&(stage(7,"bspan")=bspan))
	. . . ; at this point Stage 10 is complete. issue an error due to failing all prior success cases
	. . . write verifail,loop,": ^[abe]span(",fid,",",I,") at ",loop,!
	. . . do spanerr
	. . . set fl=fl+1 quit
	. . if (fl>maxerr) write "Too many errors for job:",jobno,!
	. . set I=(I*nroot)#prime
        . set ival=(ival*root)#prime
	quit
	; dump out all related ^[abe]span globals and locals to aide in debugging
spanerr
	zwrite loop,I,fid,targetpiece,totalpieces
	write "The below values are being printed stripped of padding spaces",!
	write "aspan should equal bspan AND val must equal valMAX",!
	write "aspan is",?26,$zwrite($tr(aspan," ",""))," pieces=",$length(aspan,"|"),!
	write "espan is",?26,$zwrite($tr(espan," ",""))," pieces=",$length(espan,"|"),!
	write "bspan is",?26,$zwrite($tr(bspan," ",""))," pieces=",$length(bspan,"|"),!
	write "value is",?26,$zwrite($tr(val," ","")),!
	write "valMax is",?26,$zwrite($tr(valMAX," ","")),!
	write "Stage 7 aspan should be",?26,$zwrite($tr(stage(7,"aspan")," ",""))," pieces=",$length(stage(7,"aspan"),"|"),!
	write "Stage 10 aspan should be",?26,$zwrite($tr(stage(10,"aspan")," ",""))," pieces=",$length(stage(10,"aspan"),"|"),!
	write "Stage 10 espan should be",?26,$zwrite($tr(stage(10,"espan")," ",""))," pieces=",$length(stage(10,"espan"),"|"),!
	quit
	;
crashztp;
	set maxcrash=3
	set ival=1
	set crashcnt=0
	for jobno=1:1:jobcnt do
	. set I=ival
	. for loop=1:1:$GET(^lasti(fid,jobno))-1  do  q:(fl>maxerr)
	. . set datacnt=0
	. . if $DATA(^andxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if $DATA(^bndxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if $DATA(^cndxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if $DATA(^dndxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if $DATA(^endxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if $DATA(^fndxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if $DATA(^gndxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if $DATA(^hndxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if $DATA(^indxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if datacnt'=9  set crashcnt=crashcnt+1
	. . else  do compiter^checkdb(fid,I,loop)
	. . set I=(I*nroot)#prime
        . set ival=(ival*root)#prime
	quit
	;
nocrash;
	set ival=1
	for jobno=1:1:jobcnt D
	. set I=ival
	. for loop=1:1:$GET(^lasti(fid,jobno)) do  q:(fl>maxerr)
	. . do compiter^checkdb(fid,I,loop)
	. . if (fl>maxerr) write "Too many errors for job:",jobno,!
	. . set I=(I*nroot)#prime
        . set ival=(ival*root)#prime
	q
	;
compiter(fid,I,loop)
	set vms=$zv["VMS"
	if vms do
	. set subs=$$^genstr(I)			; I to subs  has one-to-one mapping
	. set val=$$^genstr(loop)		; loop to val has one-to-one mapping
	else  do
	. set subs=$$^ugenstr(I)			; I to subs  has one-to-one mapping
	. set val=$$^ugenstr(loop)		; loop to val has one-to-one mapping
	set recpad=recsize-($$^dzlenproxy(val)-$length(val))
	set recpad=$select((istp=2)&(recpad>800):800,1:recpad)
	set valMAX=$j(val,recpad)
	set valALT=$select(span>1:valMAX,1:val)
	set keypad=$select(istp=2:1,1:keysize-($$^dzlenproxy(subs)-$length(subs)))
	set subsMAX=$j(subs,keypad)
	; divide up valMAX into a "|" delimited string with the delimiter placed at every 7th space char
	set piecesize=7
	set valPIECE=valMAX
	set totalpieces=($length(valPIECE)/piecesize)+1
	for i=1:1:totalpieces set:($extract(valPIECE,(piecesize*i))=" ") $extract(valPIECE,(piecesize*i))="|"
	set totalpieces=$length(valPIECE,"|")
	set targetpiece=(loop#(totalpieces))
	set $piece(valPIECE,"|",targetpiece)=$tr($piece(valPIECE,"|",targetpiece)," ","X")
	; First tp
	if $GET(^arandom(fid,subsMAX))'=val write verifail,loop,": ^arandom(",fid,",",$zwrite(subsMAX),")=",$zwrite($GET(^arandom(fid,subsMAX)))," Expected=",$zwrite(val),! set fl=fl+1
	if $GET(^brandomv(fid,subsMAX))'=valALT write verifail,loop,": ^brandomv(",fid,",",$zwrite(subsMAX),")=",$zwrite($GET(^brandomv(fid,subsMAX)))," Expected=",$zwrite(val),! set fl=fl+1
	if $GET(^crandomva(fid,subsMAX))'=valALT write verifail,loop,": ^crandomva(",fid,",",$zwrite(subsMAX),")=",$zwrite($GET(^crandomva(fid,subsMAX)))," Expected=",$zwrite(val),! set fl=fl+1
	if $GET(^drandomvariable(fid,subs))'=valALT write verifail,loop,": ^drandomvariable(",fid,",",$zwrite(subs),")=",$zwrite($GET(^drandomvariable(fid,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	if $GET(^erandomvariableimptp(fid,subs))'=valALT write verifail,loop,": ^erandomvariableimptp(",fid,",",$zwrite(subs),")=",$zwrite($GET(^erandomvariableimptp(fid,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	if $GET(^frandomvariableinimptp(fid,subs))'=valALT write verifail,loop,": ^frandomvariableinimptp(",fid,",",$zwrite(subs),")=",$zwrite($GET(^frandomvariableinimptp(fid,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	if $GET(^grandomvariableinimptpfill(fid,subs))'=val write verifail,loop,": ^grandomvariableinimptpfill(",fid,",",$zwrite(subs),")=",$zwrite($GET(^grandomvariableinimptpfill(fid,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	if $GET(^hrandomvariableinimptpfilling(fid,subs))'=val write verifail,loop,": ^hrandomvariableinimptpfilling(",fid,",",$zwrite(subs),")=",$zwrite($GET(^hrandomvariableinimptpfilling(fid,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	if $GET(^irandomvariableinimptpfillprgrm(fid,subs))'=val write verifail,loop,": ^irandomvariableinimptpfillprgrm(",fid,",",$zwrite(subs),")=",$zwrite($GET(^irandomvariableinimptpfillprgrm(fid,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	if $GET(^jrandomvariableinimptpfillprogram(fid,I))'="" write verifail,loop,": ^jrandomvariableinimptpfillprogram(",fid,",",I,")=",$zwrite($GET(^jrandomvariableinimptpfillprogram(fid,I)))," Expected=null",! set fl=fl+1
	if $GET(^jrandomvariableinimptpfillprogram(fid,I,I))'="" write verifail,loop,": ^jrandomvariableinimptpfillprogram(",fid,",",I,",",I,")=",$zwrite($GET(^jrandomvariableinimptpfillprogram(fid,I,I)))," Expected=null",! set fl=fl+1
	if $GET(^jrandomvariableinimptpfillprogram(fid,I,I,subs))'=val write verifail,loop,": ^jrandomvariableinimptpfillprogram(",fid,",",I,",",I,",",$zwrite(subs),")=",$zwrite($GET(^jrandomvariableinimptpfillprogram(fid,I,I,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	; Continue tp for the second subscripts
	for J=1:1:jobcnt do
	. set valj=valALT_J		; Not killed
	. if J=1 set rval=""
	. else  set rval=valj
	. if $GET(^arandom(fid,subs,J))'=rval write verifail,loop,": ^arandom(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^arandom(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	. if $GET(^brandomv(fid,subs,J))'=rval write verifail,loop,": ^brandomv(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^brandomv(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	. if $GET(^crandomva(fid,subs,J))'=rval write verifail,loop,": ^crandomva(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^crandomva(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	. if $GET(^drandomvariable(fid,subs,J))'=rval write verifail,loop,": ^drandomvariable(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^drandomvariable(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	. if $GET(^erandomvariableimptp(fid,subs,J))'=rval write verifail,loop,": ^erandomvariableimptp(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^erandomvariableimptp(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	. if $GET(^frandomvariableinimptp(fid,subs,J))'=rval write verifail,loop,": ^frandomvariableinimptp(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^frandomvariableinimptp(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	. if $GET(^grandomvariableinimptpfill(fid,subs,J))'=rval write verifail,loop,": ^grandomvariableinimptpfill(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^grandomvariableinimptpfill(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	. if $GET(^hrandomvariableinimptpfilling(fid,subs,J))'=rval write verifail,loop,": ^hrandomvariableinimptpfilling(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^hrandomvariableinimptpfilling(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	. if $GET(^irandomvariableinimptpfillprgrm(fid,subs,J))'=rval write verifail,loop,": ^irandomvariableinimptpfillprgrm(",fid,",",$zwrite(subs),",",J,")=",$zwrite($GET(^irandomvariableinimptpfillprgrm(fid,subs,J)))," Expected=",$zwrite(rval),! set fl=fl+1
	if $DATA(^antp(fid,subs))'=0 write verifail,loop,": ^antp(",fid,",",$zwrite(subs),")=",$zwrite($GET(^antp(fid,subs)))," Expected=null",! set fl=fl+1
	if $DATA(^bntp(fid,subs))'=0 write verifail,loop,": ^bntp(",fid,",",$zwrite(subs),")=",$zwrite($GET(^bntp(fid,subs)))," Expected=null",! set fl=fl+1
	if $DATA(^cntp(fid,subs))'=0 write verifail,loop,": ^cntp(",fid,",",$zwrite(subs),")=",$zwrite($GET(^cntp(fid,subs)))," Expected=null",! set fl=fl+1
	if $DATA(^dntp(fid,subs))'=0 write verifail,loop,": ^dntp(",fid,",",$zwrite(subs),")=",$zwrite($GET(^dntp(fid,subs)))," Expected=null",! set fl=fl+1
	if $GET(^entp(fid,subs))'=val write verifail,loop,": ^entp(",fid,",",$zwrite(subs),")=",$zwrite($GET(^entp(fid,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	if $GET(^fntp(fid,subs))'=val write verifail,loop,": ^fntp(",fid,",",$zwrite(subs),")=",$zwrite($GET(^fntp(fid,subs)))," Expected=",$zwrite(val),! set fl=fl+1
	if $GET(^gntp(fid,subsMAX))'=valMAX write verifail,loop,": ^gntp(",fid,",",$zwrite(subsMAX),")=",$zwrite($GET(^gntp(fid,subsMAX)))," Expected=",$zwrite($tr(valMAX," ","")),! set fl=fl+1
	if $GET(^hntp(fid,subsMAX))'=valMAX write verifail,loop,": ^hntp(",fid,",",$zwrite(subsMAX),")=",$zwrite($GET(^hntp(fid,subsMAX)))," Expected=",$zwrite($tr(valMAX," ","")),! set fl=fl+1
	if $GET(^intp(fid,subsMAX))'=valMAX write verifail,loop,": ^intp(",fid,",",$zwrite(subsMAX),")=",$zwrite($GET(^intp(fid,subsMAX)))," Expected=",$zwrite($tr(valMAX," ","")),! set fl=fl+1
	if $GET(^aspan(fid,I))'=valPIECE do
	.	write verifail,loop,!
	.	write "^aspan(",fid,",",I,")",?32,$zwrite($tr($GET(^aspan(fid,I))," ","")),!
	.	write " Expected=",?32,$zwrite($tr(valPIECE," ","")),! set fl=fl+1
	if $GET(^bspan(fid,I))'=$tr(valPIECE," ","") do
	.	write verifail,loop,!
	.	write "^bspan(",fid,",",I,")",?32,$zwrite($GET(^bspan(fid,I))),!
	.	write " Expected=",?32,$zwrite($tr(valPIECE," ","")),! set fl=fl+1
	if $piece($GET(^espan(fid,I)),"|",targetpiece)'=$piece(valPIECE,"|",targetpiece) do
	.	write verifail,loop,!
	.	write "^espan(",fid,",",I,")",?32,$zwrite($GET(^espan(fid,I))),!
	.	write " Expected=",?32,$zwrite($tr(valPIECE," ","")),! set fl=fl+1
	q
ERROR	ZSHOW "*"
	h
