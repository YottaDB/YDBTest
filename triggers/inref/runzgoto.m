;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
runzgoto
	do noref
	do ref
	quit

	;----------------------------------------------------------------
	; $zlevel and $ztlevel are incremented for each trigger
	; invocation. This is a one to one comparison as long as the
	; trigger does not invoke one or more routines.
	;----------------------------------------------------------------

ref
	; In this example, each trigger calls one routine.  That means
	; for every $ztlevel there are twice as many $zlevels.  This is
	; why the $etrap uses '$zlevel-($ztlevel*2)' as the destination
	do ^echoline
	write "$gtm_exe/mumps -run ref^runzgoto",!
	set $ETRAP="ZSHOW ""*"" zgoto $zlevel-($ztlevel*2)"
	write "Testing ZGOTO within a trigger w/o an entryref",!
	set ^b(1)="ref^runzgoto"
	write "Unexpected return from triggers with $ZLEVEL=",$ZLEVEL," and $ZTLEVEL=",$ZTLEVEL,!
	quit

saferef
	write "Expected zgoto return to primary code with $ZLEVEL=",$ZLEVEL," and $ZTLEVEL=",$ZTLEVEL,!
	if $data(^b) zwr ^b
	halt

noref
	do ^echoline
	write "$gtm_exe/mumps -run noref^runzgoto",!
	set $ETRAP="ZSHOW ""*"" zgoto $zlevel-($ztlevel*2)"
	write "Testing ZGOTO within a trigger w/o an entryref",!
	set ^a(1)="noref^runzgoto"
	write "Have expected successful return from triggers with $ZLEVEL=",$ZLEVEL," and $ZTLEVEL=",$ZTLEVEL,!
	zwrite ^a
	quit

	;----------------------------------------------------------------
	; test zgoto -1
minusone
	do ^echoline
	write "$gtm_exe/mumps -run minusone^runzgoto",!
	set $ETRAP="write ""unknown failure"",! halt"
	set ^e(10)=1024
	write "Should get here",!
	quit

	;----------------------------------------------------------------
	; do a controlled zgoto down to the lowest trigger frame
	; note the hardcoded $zlevel in the trigger
controlled
	do ^echoline
	do file^dollarztrigger("update.trg",1)
	set $ETRAP="write $zstatus,""unknown failure"",! halt"
	set ^e(10)=2048
	write "Have expected successful return from triggers with $ZLEVEL=",$ZLEVEL," and $ZTLEVEL=",$ZTLEVEL,!
	quit

	;----------------------------------------------------------------
	; clean out ^fired from both primary and secondary
cleanup
	do file^dollarztrigger("cleanup.trg",1)
	kill ^fired
	quit

cleanuptfile
	;+^fired -command=K -xecute=<<
	;	set file="stackinformation.zwrite"
	;	open file:newversion
	;	use file
	;	zwrite ^fired
	;	close file
	;	quit
	;>>
	quit

	;----------------------------------------------------------------
	; generate trigger files
setup
	do text^dollarztrigger("tfile^runzgoto","runzgoto.trg")
	do text^dollarztrigger("updatetfile^runzgoto","update.trg")
	do text^dollarztrigger("cleanuptfile^runzgoto","cleanup.trg")
	do file^dollarztrigger("runzgoto.trg",1)
	quit

	;----------------------------------------------------------------
	; the test to start all the zwrite+merge problems
	; superseded by assertfail and left here for posterity
mergetest
	do ^echoline
	write "Testing a merge",!
	if $data(^a) zwr ^a
	if $data(^b) zwr ^b
	if $data(^c) zwr ^c
	merge ^a=^c("a")
	do ^echoline
	quit

assertfail
	set ofile="assertfail.out"
	open ofile:newversion
	use ofile
	do ^echoline
	merge ^zwrmerge=^x
	merge ^mergezwr=^x
	do ^echoline
	close ofile
	quit

	;----------------------------------------------------------------
	; embedded trigger files, update.trg and runzgoto.trg, generated
	; by setup^runzgoto
updatetfile
	;; test controlled zgoto'ing between trigger levels
	;-^a(:) -command=S -xecute="do ^norefzgoto" -name=setgotoa
	;-killgotoa
	;+^a(:) -command=S -xecute="do controlled^norefzgoto(6) write ""controlled return to $zlevel="",$zlevel,!" -name=setgotoa
	quit

tfile
	;-*
	;; testing [z]goto inside triggers
	;+^a(:) -command=S -name=setgotoa -xecute="do ^norefzgoto"
	;+^b(:)	-command=S -name=setgotob -xecute="do ^refzgoto"
	;; Loop inside with zgoto
	;+^a	-command=K -name=killgotoa -xecute="do gotoloop^norefzgoto"
	;+^b	-command=K -name=killgotob -xecute="do gotoloop^refzgoto"
	;;
	;+^d(lvn=:) -command=S -xecute=<<
	;	zshow "s"
	;	write !,!
	;	set ^a(lvn)=$ZTVAlue
	;	write $ZTNAme," completed",!
	;>>
	;+^e(lvn=:) -command=S -xecute=<<
	;	zshow "s"
	;	write !,!
	;	set ^d(lvn)=$ZTVAlue
	;	write $ZTNAme," completed",!
	;>>
	;;----------------------------------------------------------------
	;;testing the ASSERT failure caused by interleaving merge and zwrite
	;+^zwrmerge(:) -command=S -xecute="zwrite ^z merge ^y=^x" -name=assertfail1
	;+^mergezwr(:) -command=S -xecute="merge ^y=^x zwrite ^z" -name=assertfail2
