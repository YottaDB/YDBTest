;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to read in the JSON text to parse and make it available to the parser's API. Also
; selects which version of the routine we use for the scan (ASCII - aka M mode or UTF8 mode).
;
	set suffix=$zcmdline
	set zl=$zlevel
	set $etrap="use $principal write ""Error encountered: "" zwr $zstatus break:debug  zshow ""*"" zhalt 1"
	set schema("*Date")="Date"
	set schema("is*")="Boolean"
	set f="DTXJSON.txt"
	open f:(readonly:stream:recordsize=100000:exception="set $ecode="""" zgoto:$zeof zl:eof xecute $etrap")
	use f
	for i=1:1 read x(i)  ; Read in JSON text - append to single string
	close f
	write "Shouldn't be here!!",!
	zhalt 1
;
; Entry point where we re-engage after hitting EOF
;
eof
	set $ecode=""
	close f
	use $principal
	write "json read in - starting processing in ",$zchset," mode",!!
	set input=x(1)
	for i=2:1 quit:'$data(x(i))  set input=input_x(i)
	set f="jsonout"_suffix_".txt"
	open f:new
	write "beginning parse",!!
	use f
	do parse^@("ZJSON"_suffix)(.output,input,.schemma)
	use $principal
	write !,"rebuilding json string",!!
	use f
	write $$stringify^@("ZJSON"_suffix)(.output,.schema)
	close f
	use $principal
	write "output complete",!!
	quit
