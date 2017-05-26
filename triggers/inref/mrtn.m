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
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; generic trigger routine that prints interesting data
mrtn
	set tab=$char(9)
	; the stack currently points to this routine
	; drop down 2 more to get the trigger's name
	zshow "s":stack
	write stack("S",3)
	write ?8,tab,"$reference=",$reference
	if $data(lvn) write tab,"lvn=",lvn
	if $data(lvn2) write tab,"lvn2=",lvn2
	if $data(delim) write tab,"delim=",delim
	write tab,"$ztupdate=",$ztupdate,!
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; use this when passing in a delimiter string
d(delim)
	do ^mrtn
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; even more generic trigger routine that prints interesting data
	; save trigger execution counts in ^fired and $ztvalue in $ztwormhole
	; to help determine if triggers were in fact executed
l(level)
	new stack,x,y,name	; other rtns call this, negates the trigger implicit new
	if '$data(level) set level=2
	zshow "s":stack
	set name=stack("S",level)
	do:$length(name,"#")>1
	.	set $piece(name,"#",$length(name,"#"))=""  ; nullify region disambigurator
	write $char(9),name
	write $char(9),"$reference=",$reference
	set x=$increment(^fired(name))
	write $char(9),"executions=",x
	write $char(9),"$ztvalue=",$ztvalue
	if $trestart>0 write $char(9),"$trestart=",$trestart
	write !
	set y=$ztwormhole  set $piece(y,"|",x)=$ztvalue set $ztwormhole=y
	quit
