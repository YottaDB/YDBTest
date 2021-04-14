;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb717	;
	quit

dataload;
	; This entryref creates a database that has more than 64KiB blocks (needed to exercise the YDB#717 issue).
	; It assumes a database block size of 512 bytes which means 2 records of 200 bytes each is enough to fill up 1 block.
	; And therefore, 200,000 records would fill up 100,000 blocks. Lot higher than the needed 64KiB number of blocks.
	;
	for i=1:1:200000 set ^x(i)=$j(i,200)
	quit

