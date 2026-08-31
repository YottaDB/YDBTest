;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; $ORDER and $ZPREVIOUS across GT.CM against a global whose only subscript is long enough that the
; server's answer does not fit in the CM_MSG_BUF_SIZE + CM_BUFFER_OVERHEAD (532) byte message
; buffer. gtcmtr_order() and gtcmtr_zprevious() built their reply straight into that buffer with no
; check that it fits; gtcmtr_query() and gtcmtr_reversequery() have always sized it first.
;
; This is a real client talking to a real server, not the raw socket of inref/gnpfuzz.m: the point
; here is a well formed request whose answer is oversized, which is exactly what a client produces
; on its own and what the raw harness cannot easily construct.
;
; $ZCMDLINE : <expected subscript length>
;
gnpbig	;
	new want
	set want=+$piece($zcmdline," ",1)
	set $etrap="do trap^gnpbig"
	do one("$ORDER",$order(^big("")),want)
	do one("$ZPREVIOUS",$zprevious(^big("zzzzz")),want)
	do namelevel
	quit
	;
namelevel	; a name level $ORDER over a global name of exactly MAX_MIDENT_LEN bytes
	; op_gvorder() applies GVKEY_INCREMENT_ORDER() to the key it sends, which writes a 1 over the
	; <NUL> that ends the global name. A 31 byte name therefore reaches the server with 32 bytes
	; before the first <NUL>, so a server that measures the name at that point sees one byte more
	; than a valid mident and refuses the message.
	new g
	use $principal
	set g=$order(^abcdefghijklmnopqrstuvwxyz01234)
	if g'="^abcdefghijklmnopqrstuvwxyz01235" write "name level $ORDER returned ",$zwrite(g)," - WRONG",! quit
	write "name level $ORDER over a 31 byte global name returned the next name",!
	quit
	;
one(what,got,want)	; report on one oversized reply without printing the subscript itself
	use $principal
	if $length(got)'=want write what," returned ",$length(got)," bytes, expected ",want," - WRONG",! quit
	if got'=$translate($justify("",want)," ","a") write what," returned ",want," bytes but not the ones stored - WRONG",! quit
	write what," returned its ",want," byte subscript intact",!
	quit
	;
trap	; any error here is a failure: these two replies are well formed, just large
	new v
	set v=$zstatus
	set $ecode=""
	use $principal
	write "UNEXPECTED, ",$zpiece(v,",",3)," - WRONG",!
	halt
