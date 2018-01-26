;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test that $ZEOF is correctly set after READ commands on procfs files (e.g. /proc/$J/io)
;
zeofprocfs	;
	new file
	set file="/proc/"_$J_"/io"
	open file:(READONLY:REWIND)
	use file
	; Previously, $zeof used to return 1 after reading just one line.
	; But this file is guaranteed to have more than one line and we expect all those lines in the output
	new x,i,lines
	for  read x  quit:$zeof  do
	. set x=$translate(x,"0123456789","..........")	; remove the variable part of the output for reference file comparison
	. set lines($incr(i))=x
	close file
	zwrite lines
	quit

