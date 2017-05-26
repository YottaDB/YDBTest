;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2010, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inspectISV
	new $ETrap
	if $ztlevel<1 new $ZTrap
	do expectederrors
	; using DO I need to use $zlevel-1
	; using GOTO, I stay at the current $zlevel
	set backlevel=$random(2),etrap=$select(0=backlevel:"goto",1:"do")_" etrapAndGo^inspectISV"
save
	; save data in case something that should not change did change
	; and to be a good neighbor, resetting back to normal
	set save("reference")=$Reference
	set save("test")=$Test
	set save("gtm_trigger_etrap")=$ztrnlnm("gtm_trigger_etrap")
	set save("$etrap")=$ETrap
	set save("$ztrap")=$ZTrap
	set save("ztriggerop")=$ZTRI
	set save("ztslate")=$ZTSL
	set save("ztvalue")=$ZTVA
	set save("ztoldvalue")=$ZTOL
	set save("ztdata")=$ZTDA
	set save("ztudpate")=$ZTUP
	set save("ztdelim")=$ZTDE
	set save("ztwormhole")=$ZTWO
	set save("ztlevel")=$ZTLE
	set save("ztcode")=$ZTCO

	; HEADS-UP ; setting $etrap and $ztrap like this can cause problems
	; in normal M is a BAD BAD BAD idea.  However, inside a trigger,
	; setting $ztrap produces and error that we catch in $ETRAP
etrap
ztrap
	set $ETrap=etrap
	if $ZTLEvel>1 set $ZTrap="Break"
ztriggerop
	set $ZTRIggerop="Z"
	set $ZTRI="G"
ztslate
	; need to save the errors save in $ztslate so far
	set save("ztslate")=$ZTSL
	if $ZTLEvel<1  set save("ztslate")="fake slate"
	set $ZTSLate=save("ztslate")
	set $ZTSL=save("ztslate")
ztvalue
	set $ZTVAlue=$ZTVAlue*2
	set $ZTVA=$ZTVA*3
ztoldval
	set $ZTOLdval="old data"
	set $ZTOL=42
ztdata
	set $ZTDAta=101
	set $ZTDA="some text data"
ztupdate
	set $ZTUPdate="1,2,3,4,5,6,100000000"
	set $ZTUP="1,2,3,4,5,6,100000001"
ztdelim
	set $ZTDElim="1,2,3,4,5,6,100000000"
	set $ZTDE="1,2,3,4,5,6,100000001"
ztwormhole
	set $ZTWOrmhole="long ZTWO change"
	set $ZTWO="short ZTWO change"
ztlevel
	set $ZTLEvel=-1
	set $ZTLE=129
ztcode
	set $ZTCOde="w not+4,!"
	set $ZTCO="set x=y"
ztname
	set $ZTNAme="joe#1#"
	set $ZTNA="abcd#"
reset
	;
	; be a good neighbor, don't screw up test data if nothing broke
	if $ZTLEvel>0,'$data(^fail) do
	.	if $ZTRI="S" set $ZTVAlue=save("ztvalue")
	.	set $ZTWOrmhole=save("ztwormhole")
	.	set $ETrap=save("$etrap")
	quit:'$data(^fail)
	; note, we expect some errors, only spill data when something does not match
	write "An unexpected error occured while setting an ISV",!
	write "Inspect Trigger ISVs mode=",save("ztriggerop"),!
	write $char(9,9),"$Reference",$char(9,58),save("reference"),!
	write $char(9,9),"$Test",$char(9,9,58),save("test"),!
	write $char(9,9),"$gtm_trigger_etrap",$char(58),save("gtm_trigger_etrap"),!
	write $char(9,9),"$ETrap",$char(9,9,58),save("$etrap"),!
	write $char(9,9),"$ZTrap",$char(9,9,58),save("$ztrap"),!
	write $char(9,9),"$ZTRIggerop",$char(9,58),save("ztriggerop"),!
	write $char(9,9),"$ZTSLate",$char(9,58),save("ztslate"),!
	write $char(9,9),"$ZTVAlue",$char(9,58),save("ztvalue"),!
	write $char(9,9),"$ZTOLdval",$char(9,58),save("ztoldvalue"),!
	write $char(9,9),"$ZTDAta",$char(9,58),save("ztdata"),!
	write $char(9,9),"$ZTUPdate",$char(9,58),save("ztudpate"),!
	write $char(9,9),"$ZTDElim",$char(9,58),save("ztdelim"),!
	write $char(9,9),"$ZTWOrmhole",$char(9,58),save("ztwormhole"),!
	write $char(9,9),"$ZTLEvel",$char(9,58),save("ztlevel"),!
	write $char(9,9),"$ZTCOde",$char(9,58),save("ztcode"),!

	write $char(9,9,9),"->$ETrap",$char(9,58),$ETrap,!
	write $char(9,9,9),"->$ZTrap",$char(9,58),$ZTrap,!
	write $char(9,9,9),"->$ZTRIggerop",$char(9,58),$ZTRI,!
	write $char(9,9,9),"->$ZTSLate",$char(9,58),$ZTSL,!
	write $char(9,9,9),"->$ZTVAlue",$char(9,58),$ZTVA,!
	write $char(9,9,9),"->$ZTOLdval",$char(9,58),$ZTOL,!
	write $char(9,9,9),"->$ZTDAta",$char(9,58),$ZTDA,!
	write $char(9,9,9),"->$ZTUPdate",$char(9,58),$ZTUP,!
	write $char(9,9,9),"->$ZTDElim",$char(9,58),$ZTDE,!
	write $char(9,9,9),"->$ZTWOrmhole",$char(9,58),$ZTWO,!
	write $char(9,9,9),"->$ZTLEvel",$char(9,58),$ZTLE,!
	write $char(9,9,9),"->$ZTCOde",$char(9,58),$ZTCO,!
	zshow "s"
	zwrite ^fail
	kill ^fail
	quit

incrtrap; ------------------------------------------------------------------------------------------
	;   Error handler. Prints current error and continues processing from the next M-line
	; ------------------------------------------------------------------------------------------
	new savestat,mystat,prog,line,newprog,tab
	if '$data(backlevel) set backlevel=1  ; assume DO
	set tab=$char(9)
	set savestat=$zstatus
	set mystat=$piece(savestat,",",2,100)
	set prog=$piece($zstatus,",",2,2)
	set line=$piece($piece(prog,"+",2,2),"^",1,1)+1
	set newprog=$piece(prog,"+",1)_"+"_line_"^"_$piece(prog,"^",2,3)
	set newprog=($zlevel-backlevel)_":"_newprog
	set $ecode=""
	write "ZSTATUS=",mystat,!
	write newprog,tab,"$ZTLEVEL=",$ZTLEvel,tab,"$ZLEVEL=",$zlevel,!
	zgoto @newprog

	; ------------------------------------------------------------------------------------------
	;   Error handler. Prints current error and continues processing from the next M-line
	; ------------------------------------------------------------------------------------------
etrapAndGo
	new savestat,mystat,prog,line,newprog,destinfo,destp
	if '$data(backlevel) set backlevel=1  ; assume DO
	set savestat=$zstatus
	set mystat=$piece(savestat,",",3)
	set prog=$piece(savestat,",",2,2)
	set line=$piece($piece(prog,"+",2,2),"^",1,1)+1
	set newprog=$piece(prog,"+",1)_"+"_line_"^"_$piece(prog,"^",2,3)
	set newprog=($zlevel-backlevel)_":"_newprog
	set $ecode=""
	set $piece(destinfo,".",$increment(destp))="ETRAP"
	set $piece(destinfo,".",$increment(destp))=newprog
	set $piece(destinfo,".",$increment(destp))="$ZLEVEL="_($zlevel-backlevel) ; weasly move to normalize the output
	set $piece(destinfo,".",$increment(destp))="$TLEVEL="_$tlevel
	set $piece(destinfo,".",$increment(destp))="$ZTLEVEL="_$ZTLEvel
	; be quiet only when told to be
	if '$data(^etrapquiet) do
	.	write "$ZSTATUS=",$piece(savestat,",",2,100),!
	; only count errors when ^expected is set, make sure you kill ^fail once you read it
	if $data(^expected)>1,'$data(^expected(prog,mystat)) set ^fail(prog)=mystat
	if $ZTLEvel set $ztslate=$ztslate_$char(10)_destinfo
	zgoto @newprog

	; setup ^expected errors. you should drop the noise level of etrapAndGo
expectederrors
	for i=1:1  set line=$text(expected+i^inspectISV) quit:line=""  do
	.	set pos=$piece(line,";",2)
	.	for y=3:1:$length(line,";") set ^expected(pos,$piece(line,";",y))=1
	quit

	; these are the expected errors for the lines above
	; note that ztvalue has two error types :(
expected
	;ztcode+2^inspectISV;%GTM-E-SVNOSET
	;ztcode+1^inspectISV;%GTM-E-SVNOSET
	;ztdata+2^inspectISV;%GTM-E-SVNOSET
	;ztdata+1^inspectISV;%GTM-E-SVNOSET
	;ztdelim+2^inspectISV;%GTM-E-SVNOSET
	;ztdelim+1^inspectISV;%GTM-E-SVNOSET
	;ztlevel+2^inspectISV;%GTM-E-SVNOSET
	;ztlevel+1^inspectISV;%GTM-E-SVNOSET
	;ztname+2^inspectISV;%GTM-E-SVNOSET
	;ztname+1^inspectISV;%GTM-E-SVNOSET
	;ztoldval+2^inspectISV;%GTM-E-SVNOSET
	;ztoldval+1^inspectISV;%GTM-E-SVNOSET
	;ztriggerop+2^inspectISV;%GTM-E-SVNOSET
	;ztriggerop+1^inspectISV;%GTM-E-SVNOSET
	;ztslate+4^inspectISV;%GTM-E-SETINTRIGONLY
	;ztslate+5^inspectISV;%GTM-E-SETINTRIGONLY
	;ztupdate+2^inspectISV;%GTM-E-SVNOSET
	;ztupdate+1^inspectISV;%GTM-E-SVNOSET
	;ztvalue+2^inspectISV;%GTM-E-SETINTRIGONLY;%GTM-E-SETINSETTRIGONLY
	;ztvalue+1^inspectISV;%GTM-E-SETINTRIGONLY;%GTM-E-SETINSETTRIGONLY
	;ztrap+2^inspectISV;%GTM-E-NOZTRAPINTRIG
