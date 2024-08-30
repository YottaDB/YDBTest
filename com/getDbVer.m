;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Get the DB version of the specified .dat file
; Entry points:
; - print: print the version number (6, 7, or error)
; - get: entry point for calling from other M program

print	; Print the version number or error
	;
	write $$get(),!
	quit

get(file) ; Get the version (or error) of the specified database file
	; Parameter - file:
	; - the path to the file to be examined (*.dat)
	; - if not specified (or empty), fall back to first CLI arg
	; - if CLI arg is not specified, return error
	; Return value:
	; - upon success, returns "6" or "7"
	; - on error, returns error message, $LENGTH(result)>1
	;   (so the result should just printed as-is)
	;
	new pre,file,content,n,ver
	set pre="TEST-E-GETDBVER "
	;
	if '$data(file) set file=$zcmdline
	if file="" quit pre_"Filename Not Specified"
	;
	open file:(readonly:exception="goto error")
	use file
	read content#16
	close file
	set n=$zextract(content,11)
	set ver=$select(n=3:6,n=4:7,1:pre_"Unknown Header Signature: "_content)
	quit ver
	;
error	;
	quit pre_"File Open Error: "_$zstatus
