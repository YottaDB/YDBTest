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
gtmde533918 ;
	set s="socket"
	open s:::"SOCKET"       ; create a SOCKET device
	open s:(CONNECT="[127.0.0.1]:22:TCP":ATTACH="handle1")::"SOCKET"
	use s:(detach="handle1")                                        ; move connected socket to "socketpool" device
	job child:(INPUT="SOCKET:handle1":OUTPUT="OUTREPLACE":ERROR="ERRREPLACE") ; job a child and make it inherit the connected socket as $P
	set pid=$zjob for  quit:'$zgetjpi(pid,"ISPROCALIVE")  hang 0.1
	write "PASS: Parent routine complete"
	quit

child ;
	do ^sstep
	set $etrap="do trap"
	zshow "d":^handle
	set handle=$piece($piece(^handle("D",2),"=",2)," ",1)
	use $p:(detach=handle)
	break
	quit

trap;
	zwrite $zstatus
	read x
	quit
