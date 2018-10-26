;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.      ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
x	;
	set x="abcd.m"
        for i=1:1:10 do
        . write "i = ",i,!
        . open x:(newversion)
        . set dev="gtmProc"
        . open dev:(command="date":readonly:exception="goto done":stderr=$principal)::"PIPE"
        . close dev
        quit
done	;
	write $zstatus,!
	halt
y	;
	set y="abcd.m"
	open y
	set dev="gtmProc"
	open dev:(command="date":readonly:stderr=$principal)::"PIPE"
	close dev
	use $principal
	quit
z	;
	set z="abcd.m"
	open z
	set dev="gtmProc"
	open dev:(command="date":readonly:stderr=$p)::"PIPE"
	use $p
	write "abcd",!
	quit
