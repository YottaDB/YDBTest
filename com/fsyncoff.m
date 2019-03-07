;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

fsyncoff(srcfile,outfile,endofdata)
	; Reads a journal extract file and finds latest of the last EPOCH or PBLK records.
	; offset will be reset as endofdata (parsed from journal file header output) if it is higher value.
	; Callers will force corruption only after 'offset' this routine finds.
        ;
	; The format of journal extract is : 0x00000800 [0x00d0]
	; Change the program if detail extract format is different.
	; This program will work even for non-V5.0-000 if detail extract has the format as "hexOffset [hexLength]"
	; However, long variable name is used and so may fail for old GT.M versions
	;if rec'="YDBJDX04" close srcfile  write "TEST-E-",srcfile," is not a valid V5 Detailed EXTRACT file",!  zshow "*" halt
	;
	;
        set $ZT="s $ZT="""" g ERROR"
	write "fsyncoff started",!
        ;
        open srcfile:(READONLY:REC=32000)
	use srcfile
	read rec
        ;
	set epochEndOffset=0
	set pblkEndOffset=0
        for  use srcfile quit:$ZEOF  read rec D
        .       ;
        .	if $find(rec,"EPOCH")'=0 set epochRecord=rec
        .	if $find(rec,"PBLK")'=0 set pblkRecord=rec
	.	;
        close srcfile
	;
	if $data(epochRecord) set epochEndOffset=$$getEndofRecOffset(epochRecord)
	if $data(pblkRecord) set pblkEndOffset=$$getEndofRecOffset(pblkRecord)
	;
	if epochEndOffset>pblkEndOffset set offset=epochEndOffset
	else  set offset=pblkEndOffset
	if offset<endofdata set offset=endofdata
	;
	; Write down the offset in the file name specified in outfile
	;
	open outfile:newversion
	use outfile
	write offset
	close outfile
	use $p
	write "epochEndOffset = ",epochEndOffset," [0x",$$FUNC^%DH(epochEndOffset),"]",!
	write "pblkEndOffset  = ",pblkEndOffset," [0x",$$FUNC^%DH(pblkEndOffset),"]",!
	write "offset         = ",offset," [0x",$$FUNC^%DH(offset),"]",!
        quit
        ;
	; The format of journal extract is : 0x00000800 [0x00d0]
getEndofRecOffset(rec)
	new tmpoff1,rhexoff,recOffset,recLenStr,recLenStrLen,recLen
	set tmpoff1=$find(rec,"0x")	; First Hex
	set rhexoff=$piece(rec," ",1)	; Separated by space
	set recOffset=$$FUNC^%HD($extract(rec,tmpoff1,$length(rhexoff)))
	set recLenStr=$piece(rec," ",2)
	set recLenStrLen=$length(recLenStr)
	set recLen=$$FUNC^%HD($extract(recLenStr,4,recLenStrLen-1))	; number starts from 4th character
	set recOffset=recOffset+recLen
	quit recOffset
	;
        ;----------------------------------------------------------------------
ERROR   ;Log M error
        ;----------------------------------------------------------------------
        ;
	use $p
        ZSHOW "*"
        ZM +$ZS
        quit
	;
