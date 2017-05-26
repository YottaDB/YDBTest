;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to demonstrate that SET $PIECE() and $PIECE() references still give appropriate errors
; when separator strings contain invalid UTF8 values. All of these lines should generate errors
; but only the ones with literal piece separators give compile errors. All should give runtime
; errors except the last one of each set which has a (FALSE) postconditional.
;
start
	set lvl=$ZLEVEL
	set $ETRAP="Do nextline"
	set pcmdseen=""
	;
	; Variations of SET $PIECE() invocations
	;
	set x="This is a sour"_$ZCH(252)_"e line" set $PIECE(x,"O"_$ZCH(252),1)="*"
	set x="This is a source line" set $PIECE(x,$ZCH(128),1)="*"
	set x="This"_$ZCH(253)_"is a source line" set $PIECE(x,$ZCH(252),1)="*"
	;
	; Note this is same as previous line but has a post-conditional on the errant set statement and a following command
	; that should execute.
	;
	set x="This"_$ZCH(253)_"is a source line" set:0 $PIECE(x,$ZCH(252),1)="*" set pcmdseen="*1*"
	;
	; Variations of $PIECE() function references
	;
	set x=$PIECE("This is a source lin"_$ZCH(214),"U"_$ZCH(190),1)
	set x=$PIECE("This is a source line",$ZCH(128),1)
	set x=$PIECE("This is a source"_$ZCH(137)_"line",$ZCH(135),1)
	;
	; Note this is same as previous line but has a post-conditional on the errant set statement and a following command
	; that should execute.
	;
	set:0 x=$PIECE("This is a source"_$ZCH(137)_"line",$ZCH(135),1) set pcmdseen=pcmdseen_" *2*"
	zwrite pcmdseen
	quit

;
; Error handling routine to drive the next line
;
nextline
	set $ECODE=""
	write "Error handler: $ZSTATUS=",$ZSTATUS,!
	set eref=$ZPIECE($ZSTATUS,",",2)
	set lbl=$ZPIECE(eref,"^",1)
	set rtn=$ZPIECE(eref,"^",2)
	set offset=$ZPIECE(lbl,"+",2)
	set lbl=$ZPIECE(lbl,"+",1)
	set zgotoarg=lvl_":"_lbl_"+"_(offset+1)_"^"_rtn
	zgoto @zgotoarg
