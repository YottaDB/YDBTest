;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;
	write "This routine has no main entry point - recode to drive the correct entry point",!
	zhalt 1
;
; This routine is a verification routine for gtm7987. We're looking for the following in the receiver server log
; being passed into us:
;   1 - See a WBTEST_REPL_TLS_RECONN induced message.
;   2 - See an immediate connecion reset message.
;   4 - See a Connected to secondary message.
; These 4 messages must preceed any "REPL INFO" or "Received" message.
; Note - there is a WBTEST_REPL_TLS_RECONN that occurs as the servers are being shutdown but verifying #4 message above
; proves this is not THAT case.
;
verify
	set debug=0		; Set to 1 to enable line by line debugging of receiver server log
	set inputfn=$zcmdline
	set $etrap="use $p write $zstatus,!,! zshow ""*"" zhalt 1"
	open inputfn:readonly
	write $$findmsg("WBTEST_REPL_TLS_RECONN",0),!		; Locate line and write to reference file (sans timestamp information)
	;
	; At this point, we've found the triggering white box test line. Now find lines 2-4 but with less than 4 reads
	;
	write $$findmsg("Connection reset. Status = 104",4),!
	write $$findmsg("Connection established",4),!
	write !,"Success",!
	quit

;
; Routine read the open file until we find a given message. Second parm is the maximum reads we should do. For example, when
; looking for the first message in a series, the limit would be 0 meaning unlimited reads. Finding successive lines though
; should be done in just a few reads (likely sequential lines but give it a few in case something inserts itself).
;
findmsg(msg,maxreads)
	new line,sline,i,saveio,found
	set saveio=$io
	use inputfn
	set found=0
	;
	; Parse each line stripping the timestamp off of it first. Here is an example line from the receiver server:
	;
	;   Tue Nov  1 11:03:46 2022 : WBTEST_REPL_TLS_RECONN induced
	;
	; So our parse is on the ' : ' that separates the timestamp from the actual line of log output.
	;
	for i=1:1 read line quit:$zeof  do  quit:found
	. set sline=$zpiece(line," : ",2,99)			; Strip off the timestamp type information
	. set:(msg=$zextract(sline,1,$length(msg))) found=1	; Looking for our trigger (white box test notification)
	. do:debug
	. . use $p
	. . zwrite msg,line,sline,found
	. . write !
	. . use inputfn
	if $zeof do
	. use $p
	. write "Premature end-of-file encountered looking for our trigger text (",msg,") - terminating",!
	. zhalt 1
	if (0<maxreads)&(i>maxreads) do
	. use $p
	. write "Exceeded maximum reads (",maxreads,") to find text: ",i,!
	. zhalt 1
	use saveio
	quit sline
