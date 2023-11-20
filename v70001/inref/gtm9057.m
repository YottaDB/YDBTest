;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; v70001/gtm9057 - Utility program for this test. We open a fifo named 'fifo.input' and copy everything we see
;                  presented to it to 'jnl_extract.txt' and then close the input/output when we get a special
;                  value on the pipe of "doneDoneDONE".
gtm9057
	set infile="fifo.input"				; Input file (fifo attached to by a MUPIP JOURNAL -EXTRACT command)
	set outfile1="jnl_extract.txt"			; Output file (copy of extract)
	set outfile2="jnl_extract_match.txt"		; Modified version of outfile1 with ##FILTERED## tags
	open infile:fifo
	open outfile1:new
	open outfile2:new
	set done=0
	;
	; We don't bother to check for EOF on this device as it isn't ever presented so we rely on a special
	; value that we recognize here to shutdown this process.
	;
	; While reading the records, write the original records to outfile1 and the modified (filtered) records
	; to outfile2 with the following changes to the records:
	;
	; - All records - set time, transid, and pid values (pieces 2, 3, and 4) to "##FILTERED##"
	; - Type 1 records, set system name and userid values (pieces 5 and 6) to "##FILTERED##"
	;
	; Then write the modified record to outfile2.
	;
	for linec=1:1 do  quit:done
	. use infile
	. read record
	. ;
	. ; Check for special exit flag
	. ;
	. if "doneDoneDONE"=record set done=1 quit	; Exit loop, close up and exit
	. use outfile1
	. write record,!				; Write original unmodified record out
	. if 1'=linec do
	. . set $zpiece(record,"\",2,4)="##FILTERED##\##FILTERED##\##FILTERED##"
	. . set:("01"=$zpiece(record,"\",1)) $zpiece(record,"\",5,6)="##FILTERED##\##FILTERED##"
	. use outfile2
	. write record,!
	close infile
	close outfile1
	close outfile2
	use $p
	;
	; Note the linec counter is larger than the actual count by 1 items so correct it via
	; decrementing the counter once. This is because the iteration that locates the end of file
	; should have its count removed.
	;
	set linec=linec-1
	write "  Total of ",linec," lines read through fifo",!
	quit
