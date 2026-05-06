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

etcmtab
	set $etrap="break",io=$io,file="/etc/mtab"
	set lines=$piece($zcmdline," ",1)

	write "# Read from "_file_" until $ZEOF is hit",!
	open file:readonly use file
	for i=1:1 read line quit:$zeof
	close file:destroy use io

	write "# Expect $ZEOF to be set after line "_lines_":",!
	write $select((i-1)=lines:"PASS",1:"FAIL")
	write ": $ZEOF set on line ",i,!
	write "# Run [zshow ""d""]",!
	zshow "d"

	write "# Read from "_file_" until all lines read",!
	open file:readonly use file
	for i=1:1 read line quit:""=line
	close file use io
	set read=i-1
	write "# Expect "_lines_" lines to be read:",!
	write:read=lines "PASS: Read expected "_read_" lines",!
	write:read'=lines "FAIL: Read "_read_" lines, but /etc/mtab contains "_lines_" lines",!

	quit
