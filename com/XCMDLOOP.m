;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2011 Fidelity Information Services, Inc.    	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XCMDLOOP
	; Perform a given command on every line of input
	;
	; Usage: mumps -run %XCMDLOOP [--before=<string>] [--after=<string>] --xec=<string>
	;
	set $etrap="set $etrap=""use $principal write $zstatus,! zhalt 1"" set tmp1=$piece($ecode,"","",2),tmp2=$text(@tmp1) if $length(tmp2) write $text(+0),@$piece(tmp2,"";"",2),! zhalt +$extract(tmp1,2,$length(tmp1))"
	new %a,%b,%c,%l,%n,%x
	set %c=$zcmdline
	for  quit:'$$trimleadingstr(.%c,"--")  do	; process command line options
	. if $$trimleadingstr(.%c,"after=") set %a=$$trimleadingdelimstr(.%c)
	. else  if $$trimleadingstr(.%c,"before=") set %b=$$trimleadingdelimstr(.%c)
	. else  if $$trimleadingstr(.%c,"xec=") set %x=$$trimleadingdelimstr(.%c)
	. else  set $ecode=",U254,"
	. if $$trimleadingstr(.%c," ")
	set:'$length($get(%x)) $ecode=",U253,"
	set:$length(%c) $ecode=",U252,"
	kill %c
	xecute:$length($get(%b)) %b kill %b
	for %n=1:1 read %l quit:$zeof  xecute %x
	kill %x
	xecute:$length($get(%a)) %a
	quit

trimleadingdelimstr(s) ; Remove and optionally return leading delimited string from s
	new delim,tmp
	set delim=$extract(s,1)
	set tmp=$piece(s,delim,2)
	set s=$extract(s,$length(tmp)+3,$length(s))
	quit:$quit tmp quit

trimleadingpiece(s)    ; Remove and optionally return first piece of s with space as piece separator
	new tmp
	set tmp=$piece(s," ",1)
	set s=$piece(s," ",2,$length(s," "))
	quit:$quit tmp quit

trimleadingstr(s,x)    ; Return s without leading $length(x) characters; return 1/0 if called as function
	if x=$extract(s,1,$length(x)) set s=$extract(s,$length(x)+1,$length(s)) quit:$quit 1 quit
	else  quit:$quit 0 quit

;	Error message texts
U252	;"-F-UNRECCMD Unrecognized commands starting with "_%c
U253	;"-F-EMPTYXEC String to Xecute with --xec is required but not provided"
U254	;"-F-ILLEGALCMD Illegal command line option(s) starting with --"_%c
