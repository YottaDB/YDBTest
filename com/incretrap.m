;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
incretrap
	; ------------------------------------------------------------------------------------------
	;   $ETrap Error handler. Either prints current error or saves it to
	;   $ZTSLate in a trigger and, by default, continues processing from the next M-line.
	;
	;   Usage:
	;     new $estack[,$etrap]
	;     set $etrap="do ^incretrap"
	;     except for %SAVESTAT, which is a cumlative list of errors this uses upper-case % names and kills them on its return
	;
	;   the following values can be stored as [^]incretrap(name) with the local taking precedence over a global
	;   PRE, INTRA and POST condition handlers let you add instrumentation,
	;   for instance, whether or not to issue a TROLLBACK or to capture
	;   failure information somewhere other than to a file.
	;   ACTION only takes place if a display is made - i.e. never inside a trigger; preexisting tests may use act
	;   EXPECT indicates an expected error mnemonic and implies NODISP if it is delivered; preexisting tests may use expect
	;   NODISP instructs the error handler to not print information
	;   PLACE is a location to resume execution after the error; if only a routine, incretrap adds an offset from the error line
	;   SAMELINE is an adjustment from the error line which defaults to 1; 0 causes re-xecution of the error line
	;
	;   Note - if handling errors in a TP environment, use of PRE condition handler to
	;   include a TROLLBACK is recommended in order to avoid TPRESTNESTERR which
	;   can be signaled if a trigger or spanning node containing an implicit
	;   transaction fence is part of the test using incretrap.
	;
	; ------------------------------------------------------------------------------------------
	; HP-UX PARISC does not support triggers and therefore does not support trigger related ISVs.
	set %ZTLEVEL=$select($ztrnlnm("gtm_test_os_machtype")="HOST_HP-UX_PA_RISC":0,1:$ztlevel)
	; save zstatus in case some external action, e.g. online rollback, causes incretrap to hit an error
	if %ZTLEVEL set %ZTSLATE=$ztslate,$ztslate="%ZLEVEL="_$zlevel_",%ZSTATUS="_$zwrite($zstatus),%ZLEVEL=$zlevel
	else  set %ZLEVEL=$zlevel,(%ZSTATUS,%SAVESTAT($increment(%SAVESTAT)))=$zstatus,%MCODE=$stack($stack-1,"MCODE")
	goto:$text(+0)=$piece($piece($zstatus,"^",2),",") fail	; cannot trap a failure in incretrap !
	set $ecode=""					; let incretrap report it's own errors rather than dumping more stack
	set %PRE=$select($data(incretrap("PRE")):incretrap("PRE"),1:$get(^incretrap("PRE")))
	xecute:$length(%PRE) %PRE					; execute any PRE condition handler
	set %MYSTAT=$piece($ZSTATUS,",",2,100)
	set %PLACE=$select($data(incretrap("PLACE")):incretrap("PLACE"),1:$get(^incretrap("PLACE")))
	set:'$length(%PLACE) %PLACE=$piece($piece($ZSTATUS,"^",2),",")	;default to the routine where the error occurred
	set:(%PLACE'["^") %PLACE="^"_%PLACE
	; do we go to the next or the current line?
	set:"^"=$e(%PLACE) %PLACE=$p($p($ZSTATUS,"+"),",",2)_"+"_($p($ZSTATUS,"+",2)+$s($d(incretrap("SAMELINE")):incretrap("SAMELINE"),1:$g(^incretrap("SAMELINE"),1)))_%PLACE
	if %PLACE[":",%PLACE>$ZLEVEL set %PLACE=$piece(%PLACE,":",2)	;if ZGOTO style make sure its in range
	; if not ZGOTO style, strip back to $estack, but fail if we hit the bottom of the stack; if leaving trigger, fixup $ZTSLATE
	if $estack,%PLACE'[":" set:1=$ZTLEVEL $ZTSLATE=$ZTSLATE_$char(10)_%ZTSLATE zgoto:$stack @($zlevel-1_":"_$zposition) goto fail
	; if we dropped out of a trigger get things back out of $ZTSLATE
	set:("%ZLEVEL"=$p($ZTSLATE,"="))&'$ZTLEVEL @$p($ZTSLATE,","),@$p($ZTSLATE,",",2,9999),%SAVESTAT($i(%SAVESTAT))=%ZSTATUS
	; find out if we are mouthing off
	set %NODISP=$select($data(incretrap("NODISP")):incretrap("NODISP"),1:$get(^incretrap("NODISP"),0))
	; if the error is expected, do not display it
	set %EXPECT=$select($data(expect):expect,$data(incretrap("EXPECT")):incretrap("EXPECT"),1:$get(^incretrap("EXPECT")))
	if $length(%EXPECT),$zstatus[%EXPECT set %NODISP=1
	set %ACTION=$select($data(act):act,$data(incretrap("ACTION")):incretrap("ACTION"),1:$get(^incretrap("ACTION")))
	set %INTRA=$select($data(incretrap("INTRA")):incretrap("INTRA"),1:$get(^incretrap("INTRA")))
	xecute:$length(%INTRA) %INTRA			; execute any INTRA condition handler here so it can mess with prior setup
	; handle error information
	if '%NODISP do
	.	if '%ZTLEVEL do	; when not in a trigger write out the error information
	.	.	xecute:$length(%ACTION) %ACTION
	.	.	write %MCODE,!
	.	.	write "ETRAP"
	.	.	write ".ZSTATUS=",%MYSTAT
	.	.	write ".Destination=",%PLACE
	.	.	write ".$ZLEVEL=",%ZLEVEL,".$TLEVEL=",$tlevel,".$ZTLEVEL=",%ZTLEVEL,!
	.	else  do; when inside a trigger push the error information into $ZTSLate
	.	.	new destinfo,destp
	.	.	set $piece(destinfo,".",$increment(destp))="ETRAP"
	.	.	set $piece(destinfo,".",$increment(destp))=%PLACE
	.	.	set $piece(destinfo,".",$increment(destp))="$ZLEVEL="_%ZLEVEL
	.	.	set $piece(destinfo,".",$increment(destp))="$TLEVEL="_$tlevel
	.	.	set $piece(destinfo,".",$increment(destp))="$ZTLEVEL="_%ZTLEVEL
	.	.	set $ztslate=%ZTSLATE_$char(10)_destinfo
	set %POST=$select($data(incretrap("POST")):incretrap("POST"),1:$get(^incretrap("POST")))
	xecute:$length(%POST) %POST					; execute any POST condition handler
	; do wo print out where we are going to?
	write:$select($data(incretrap("SHOWDEST")):incretrap("SHOWDEST"),1:$get(^incretrap("SHOWDEST"))) "TEST-I-INFO : ^incretrap Going to ",%PLACE,!
	kill %ACTION,%EXPECT,%INTRA,%MCODE,%MYSTAT,%NODISP,%POST,%PRE,%ZLEVEL,%ZTLEVEL,%ZTSLATE	; %PLACE gets left behind
	zgoto:%PLACE[":" @%PLACE goto @%PLACE
	; should not get here
	write "TEST-F-FAIL : incretrap [z]goto failed",!
	quit

	; we cannot fail from incretrap back into incretrap
	; errors like STACKCRIT or malformed destinations drop us in here
fail
	; XECUTE expected problems for incretrap and quit
	set err=$piece($zstatus,",",2)
	if ""'=$get(incretrap("expected",err)) xecute incretrap("expected",err) quit
	if '$data(incretrap("expected")),""'=$get(^incretrap("expected",err)) xecute ^incretrap("expected",err) quit
	; unexpected problems for incretrap
	write !,!,"VvvvvvvvvvvvvvvvvvvvvvvvvvvvvvV",!
	write "Cannot trap back to ^incretrap",!
	write "$tlevel=",$tlevel,?16,"$zlevel=",$zlevel,?48,!
	write "-------------------------------",!
	zshow "*"
	if $tlevel  trollback
	write !,"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^",!,!
	zhalt 4

nogbls	new i			; routine that sets up default local values so incretrap never makes a global reference
	for i="expected","ACTION","EXPECT","INTRA","NODISP","PLACE","POST","PRE","SHOWDEST" set incretrap(i)=""
	set incretrap("SAMELINE")=1
