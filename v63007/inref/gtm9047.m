;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Tests the value of the ISV $ZCSTATUS under several conditions
; Also tests the trigger files that use "xecute" are not added if they contain errors
gtm9047 ;
	set cmds="zcompile zlink"
	set files="cln bad dne"
	for i=1:1:2 do
		. zsystem:i>1 "rm *.o"
		. set cmd=$piece(cmds," ",i) write !,"# Testing cmd: ",cmd,!
		. for k=1:1:3 do
		. . set file=$piece(files," ",k)
		. . write !,"# Testing on file: ",file,!
		. . if (cmd="zlink")&(file="dne") write "# Skipping ""zlink dne"" as it fails with unrelated error",! quit
		. . xecute cmd_" file"
		. . write "$ZCSTATUS: ",$ZCSTATUS,!
		. . zshow "I":a write "zshow ""I"": ",a("I",28),!
		. . write:$ZCSTATUS>1 "$zmessage: ",$zmessage($ZCSTATUS),!
	; triggers are different so do them in a separate loop
	set trgs="cln.trg bad.trg badE.trg"
	write "# Testing cmd: $ZTRIGGER()",!
	for i=1:1:3 do
		. set trg=$piece(trgs," ",i)
		. write !,"# Testing on trigger: ",trg,!
		. set x=$ztrigger("file",trg)
		. write "$ZCSTATUS: ",$ZCSTATUS,!
		. zshow "I":a write "zshow ""I"": ",a("I",28),!
		. write:$ZCSTATUS>1 "$zmessage: ",$zmessage($ZCSTATUS),!
	write !,"# Listing of installed triggers",!,$ztrigger("S"),!
	write !,"# Testing cmd: mupip trigger",!
	zsystem "$gtm_dist/mupip trigger -triggerfile=clnB.trg"
	zsystem "$gtm_dist/mupip trigger -triggerfile=badB.trg"
	zsystem "$gtm_dist/mupip trigger -triggerfile=badEB.trg"
	write !,"# Listing of installed triggers",!,$ztrigger("S"),!
