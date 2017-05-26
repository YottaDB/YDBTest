;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
twork
	use $IO:(filter="characters")	; this is an ugly hack until C9K08-003313 gets fixed
	do operation
	do traps
	do common
	do levels
	do extdata
	do flatstack
	use $IO:(nofilter)		; this is an ugly hack until C9K08-003313 gets fixed
	quit

operation
	if $ZTRI'="" do
	.	set ztname=$ZTName,$piece(ztname,"#",$length(ztname,"#"))=""  ; nullify region disambigurator
	.	write "The trigger ",ztname," is doing ",$ZTRIggerop,!
	else  do ^echoline write "Not in a trigger operation",! do ^echoline
	write $$tabornltab(),"$Reference",$char(58),$R
	write $$tabornltab(),"$Test",$char(58),$T
	quit

traps
	new exttrap
	set exttrap=$ztrnlnm("gtm_trigger_etrap")
	write !
	write:exttrap'="" $$tabornltab(),"$gtm_trigger_etrap",$char(58),exttrap
	if $select(exttrap=$ETrap:0,$ETrap'="":1,1:0) do
	.	write $$tabornltab(),"$ETrap",$char(58),$ET
	write:$ZTrap'="" $$tabornltab(),"$ZTrap",$char(58),$ZT
	quit

common
	new isset,isztr,nottrig
	set isset=($ZTRIggerop="S")
	set isztr=($ZTRIggerop="ZTR")
	set nottrig=($ZTRIggerop="")
	do neednl
	write:$ZTDA'="" $$tabornltab(),"$ZTDAta ",$char(58),$ZTDA
	write:$ZTOL'="" $$tabornltab(),"$ZTOLdval",$char(58),$ZTOLdval
	write:$ZTVA'="" $$tabornltab(),"$ZTVAlue",$char(58),$ZTVAlue
	write:$ZTDE'="" $$tabornltab(),"$ZTDElim",$char(58),$ZTDElim
	if $ZTNA'=$ZTCO write "FAIL? $ZTNAme != $ZTCOde",$char(9),$ZTNAme,$char(58),$ZTCOde
	if 'nottrig do
	.	if isset,$ZTUP'="" write $$tabornltab(),"$ZTUPdate",$char(58),$ZTUPdate
	.	if 'isset,$ZTUP'=0 write $$tabornltab(),"$ZTUPdate",$char(58),$ZTUPdate
	if nottrig do
	.	if $ZTUP'="" write $$tabornltab(),"$ZTUPdate",$char(58),$ZTUPdate

	if isset do
	.	if $select($ZTDA=1:0,$ztda=0:0,1:1)  write !,"FAIL? ztdata is ",$ztdata,nottrig,isset,!
	.	if $ZTVA="" write !,"FAIL? ztvalue not present",nottrig,isset,!
	if 'isset,'nottrig do
	.	if 'isztr,$select($ZTDA=1:0,$ztda=0:0,$ZTDA=11:0,$ztda=10:0,1:1)  write !,"FAIL? ztdata is ",$ZTDAta,nottrig,isset,!
	.	if isztr,$ZTDA'=""  write !,"FAIL? ztdata is ",$ZTDAta,nottrig,isset,!
	.	if $ZTVA'="" write !,"FAIL? ztvalue present",nottrig,isset,!
	.	if $ZTDE'="" write !,"FAIL? ztdelim present",nottrig,isset,!
	.	if $ZTUP'=0 write !,"FAIL? ztupdate present",nottrig,isset,!
	if nottrig do
	.	if $ZTDA'="" write !,"FAIL? ztdata is bad",nottrig,isset,!
	.	if $ZTVA'="" write !,"FAIL? ztvalue present, not in trigger",nottrig,isset,!
	.	if $ZTDE'="" write !,"FAIL? ztdelim present, not in trigger",nottrig,isset,!
	.	if $ZTUP'="" write !,"FAIL? ztupdate present, not in trigger",nottrig,isset,!
	quit

levels
	do neednl
	write $$tabornltab(),"$ZTLEvel",$char(58),$ZTLE
	write $$tabornltab(),"$ZLevel",$char(58),$ZL
	write $$tabornltab(),"$TLevel",$char(58),$TL
	quit

extdata
	if $ZTWOrmhole="",$ZTSLate="" quit
	if $X'=0  write !
	write:$ZTWOrmhole'="" $$tabornltab(),"$ZTWOrmhole has data",!
	; write out the slate only outside of triggers to avoid problems with randomization
	if $ztlevel<1 write:$ZTSLate'="" $$tabornltab(),"$ZTSLate has data",!
	quit

	; print out the M stack horizontally
flatstack
	new stack,p
	zshow "s":stack
	do neednl
	set p=1
	for  set p=$order(stack("S",p))  quit:p=""  do
	.	write $char(9),stack("S",p)
	.	write:p#5=0 !
	do neednl
	quit

	; decide whether or not to write a tab or a newline. This is useful to
	; keep the amount of data written under 80 chars wide, but not consume
	; large amounts of vertical space
	; unfortunately, in UTF-8 mode $char(9), aka tab, does not get counted
	; correctly which causes problems for this.  $X is not set immediately
	; when issuing a SET $X so writing a ! is better.
tabornltab()
	if $X>64 write !
	quit $char(9)

neednl
	if $X'=0  write !
	quit
