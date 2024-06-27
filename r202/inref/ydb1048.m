;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; NOTE: Creating a UTF-8 string will only work if YottaDB is configured with $ydb_chset=UTF-8

ydb1048 ; Call from shell as `yottadb -run ydb1048 <string-length> <charset>`
	new len,charset
	set len=$piece($zcmd," ")
	set charset=$piece($zcmd," ",2)
	;
	do randomString(len,charset)
	;
	quit
	;
randomString(len,charset) ; Create a random testing string for either M or UTF-8 charsets (encoding)
	if $get(len)="" set len=4096
	if $get(charset)="" set charset="M"
	;
	new rndStr,size,rnd,char
	set rndStr=""
	;
	; The Latin-1 extended block of the BMP should be sufficient to test UTF-8 with multi-byte Unicode characters
	set size=$select(charset="UTF-8":591,1:127)
	for i=1:1:len do
	. set rnd=$random(size)
	. ; Convert any control characters to an ASCII number (48-57)
	. if rnd<32!((rnd>127)&(rnd<256)) set rnd=$random(10),rnd=rnd+48
	. set char=$char(rnd)
	. set rndStr=rndStr_char
	;
	use $principal:nowrap
	write rndStr,!
	;
	quit
