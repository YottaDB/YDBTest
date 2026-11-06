;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
;
; A string pool expansion that copies a contiguous block of more than 2GiB of live strings, for
; r208/stp_expand_4gib-ydb1101. 4.4 million strings of 1000 bytes are 4.4GB of live data.
;
ydb1101stp	;
	new i,n,v,live
	set n=4400000,live=n*1000
	write "# Set x(1) to x(4400000) each to a string of 1000 bytes, then write $VIEW(""SPSIZE"")",!
	write "#   expect the process to complete, with piece 2 (bytes in use) at least 4.4 billion",!
	for i=1:1:n set x(i)=$justify(0,1000)
	set v=$view("SPSIZE")
	write $select($piece(v,",",2)'<live:"PASS",1:"FAIL")," : piece 2 of $VIEW(""SPSIZE"") is at least 4.4 billion"
	write:$piece(v,",",2)<live " (got ",v,")"
	write !
	quit
